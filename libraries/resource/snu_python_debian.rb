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
      # Ensure the APT cache is fresh before trying to install Python.
      # Install the additional packages that manage `/usr/local/bin/python2`
      # etc.
      #
      action :install do
        apt_update 'default'

        super()

        package %w[python3 python3-dev python python-dev]
      end

      #
      # Remove the packages that were brought in as deps by `python_runtime` but
      # that its `:uninstall` action won't take back out.
      #
      action :remove do
        apt_update 'default'

        super()

        package(python3_packages + python2_packages) { action :purge }

        %W[
          pip pip3 pip#{python3_version} pip2 pip#{python2_version}
        ].each do |f|
          file(::File.join('/usr/local/bin', f)) { action :delete }
        end

        %W[python#{python3_version} python#{python2_version}].each do |d|
          directory ::File.join('/usr/local/lib', d) do
            recursive true
            action :delete
          end
        end
      end

      action_class do
        include SnuPythonCookbook::Helpers::SnuPythonDebian
      end
    end
  end
end
