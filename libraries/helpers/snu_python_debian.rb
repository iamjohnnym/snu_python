# frozen_string_literal: true

#
# Cookbook:: snu_python
# Library:: helpers/snu_python_debian
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

module SnuPythonCookbook
  module Helpers
    # Helper methods for dealing with Python packages on Debian platforms.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    module SnuPythonDebian
      #
      # Return a list of all the Python 2 packages that python_runtime's
      # :uninstall action doesn't remove.
      #
      # @return [Array<String>] an array of package names
      #
      def python2_packages
        %W[
          python-minimal
          python#{python2_version}-minimal
          libpython#{python2_version}
          libpython-stdlib
          libpython#{python2_version}-stdlib
          libpython#{python2_version}-minimal
          libpython-dev
          libpython#{python2_version}-dev
        ]
      end

      #
      # Return a list of all the Python 3 packages that python_runtime's
      # :uninstall action doesn't remove.
      #
      # @return [Array<String>] an array of package names
      #
      def python3_packages
        %W[
          python3-minimal
          python#{python3_version}-minimal
          libpython#{python3_version}
          libpython3-stdlib
          libpython#{python3_version}-stdlib
          libpython#{python3_version}-minimal
          libpython3-dev
          libpython#{python3_version}-dev
        ]
      end

      #
      # Check the APT cache to find the exact version of Python 3 on this
      # platform.
      #
      # @return [String] the Python 3 major+minor version
      #
      def python3_version
        @python3_version ||= begin
          line = shell_out!('apt-cache show python3').stdout.lines.find do |l|
            l.split(':')[0] == 'Depends'
          end
          line.split[1].gsub(/^python/, '').strip
        end
      end

      #
      # Check the APT cache to find the exact version of Python 2 on this
      # platform.
      #
      # @return [String] the Python 2 major+minor version
      #
      def python2_version
        @python2_version ||= begin
          line = shell_out!('apt-cache show python').stdout.lines.find do |l|
            l.split(':')[0] == 'Depends'
          end
          line.split[1].gsub(/^python/, '').strip
        end
      end
    end
  end
end
