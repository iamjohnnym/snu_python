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
      # If we're doing an :install or :upgrade, the python_runtime resources
      # need to exist in the resource collection at compile time. Otherwise,
      # the validation in any further python_package resources fails.
      #
      # The python_runtime resource doesn't have an :upgrade action, so we'll
      # handle upgrades using package resources in the :upgrade action.
      #
      def after_created
        return if (%i[install upgrade] && action).empty?

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
      # @param [String] ver the resource name/version
      #
      # @return [PoisePython::Resources::PythonRuntime::Resource] a resource
      #
      def new_python_runtime_resource(ver)
        py = PoisePython::Resources::PythonRuntime::Resource
             .new(ver, run_context)
        py.declared_type = :python_runtime
        py
      end

      #
      # The :install and :upgrade actions should pass themselves on to the
      # python_package resources for the base package sets.
      #
      %i[install upgrade].each do |act|
        action act do
          %w[3 2].each do |p|
            next if new_resource.send("python#{p}_packages").empty?

            python_package new_resource.send("python#{p}_packages") do
              python p
              action act
            end
          end
        end
      end

      #
      # The :remove action should purge all installed Python packages and then
      # Python runtimes.
      #
      action :remove do
        %w[3 2].each do |p|
          python_package "Remove all Python #{p} packages" do
            package_name(
              lazy do
                stdout = shell_out!(
                  "python#{p} -m pip.__main__ list --format=json"
                ).stdout
                JSON.parse(stdout).map { |pkg| pkg['name'] }
              end
            )
            python p
            action :nothing
          end

          python_runtime p do
            action :uninstall
            notifies :remove,
                     "python_package[Remove all Python #{p} packages]",
                     :before
          end
        end
      end
    end
  end
end
