# frozen_string_literal: true

#
# Cookbook:: snu_python
# Library:: resource/snu_python
#
# Copyright:: 2018, Socrata, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'chef/resource'
require 'json'
require_relative 'snu_python_package'

class Chef
  class Resource
    # A Chef resource for managing our Python installs.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class SnuPython < Resource
      property :python3_packages, Array, default: %w[requests]
      property :python2_packages, Array, default: %w[requests awscli]

      default_action :install

      #
      # A python_runtime resource needs to exist at compile time so package
      # resources can find it when they're compiled.
      #
      def after_created
        %w[3 2].each do |p|
          begin
            run_context.resource_collection.find("python_runtime[#{p}]")
          rescue Chef::Exceptions::ResourceNotFound
            run_context.resource_collection
                       .insert(new_python_runtime_resource(p))
          end
        end
      end

      #
      # Instantiate and return a new python_runtime resource.
      #
      # @param [String] python the resource name/version
      #
      # @return [PoisePython::Resources::PythonRuntime::Resource] a resource
      #
      def new_python_runtime_resource(python)
        py = PoisePython::Resources::PythonRuntime::Resource
             .new(python, run_context)
        py.declared_type = :python_runtime
        py.action(:nothing)
        py
      end

      #
      # The :install and :upgrade actions should pass themselves on to the
      # python_package resources for the base package sets. The action on the
      # runtime happens above in after_created.
      #
      %i[install upgrade].each do |act|
        action act do
          %w[3 2].each do |py|
            python_runtime py do
              options package_upgrade: true if act == :upgrade
              action :install
            end

            next if new_resource.send("python#{py}_packages").empty?

            snu_python_package new_resource.send("python#{py}_packages") do
              python py
              action act
            end
          end

          file '/usr/local/bin/pip' do
            src = '/usr/local/bin/pip2'

            owner(lazy { ::File.stat(src).uid })
            group(lazy { ::File.stat(src).gid })
            mode(lazy { ::File.stat(src).mode.to_s(8)[1..-1] })
            content(lazy { ::File.read(src) })
          end
        end
      end

      #
      # The :remove action should purge all installed Python packages and then
      # Python runtimes.
      #
      action :remove do
        %w[3 2].each do |py|
          if ::File.exist?("/usr/bin/python#{py}")
            snu_python_package "Remove all Python #{py} packages" do
              package_name(
                lazy do
                  stdout = shell_out!(
                    "/usr/bin/python#{py} -m pip.__main__ list --format=json"
                  ).stdout
                  JSON.parse(stdout).map { |pkg| pkg['name'] }
                end
              )
              python py
              action :remove
            end
          end

          python_runtime py do
            action :uninstall
          end
        end
      end
    end
  end
end
