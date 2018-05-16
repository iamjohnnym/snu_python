# frozen_string_literal: true

#
# Cookbook:: snu_python
# Library:: resource/snu_python_debian
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

require_relative 'snu_python'

class Chef
  class Resource
    # A Chef resource for managing our Python installs on Debian/Ubuntu.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class SnuPythonDebian < SnuPython
      provides :snu_python, platform_family: 'debian'

      #
      # Ensure the APT cache is fresh before trying to do anything with a
      # python_runtime resource.
      #
      # (see Chef::Resource::SnuPython#after_created)
      #
      def after_created
        unless (%i[install upgrade] && action).empty?
          begin
            run_context.resource_collection.find('apt_update[default]')
          rescue Chef::Exceptions::ResourceNotFound
            apt = Chef::Resource::AptUpdate.new('default', run_context)
            apt.declared_type = :apt_update
            run_context.resource_collection.insert(apt)
          end
        end

        super
      end

      # Installupgrade the additional packages that manage
      # `/usr/local/bin/python2` etc.
      #
      %i[install upgrade].each do |act|
        action act do
          super()

          package(%w[python3 python3-dev python python-dev]) { action act }
        end
      end

      #
      # Remove the packages that were brought in as deps by `python_runtime` but
      # that its `:uninstall` action won't take back out.
      #
      action :remove do
        super()

        package(python3_packages + python2_packages) { action :purge }
      end

      action_class do
        include SnuPythonCookbook::Helpers::SnuPythonDebian
      end
    end
  end
end
