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

class Chef
  class Resource
    # A Chef resource for managing our Python installs.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class SnuPython < Resource
      default_action :install

      action :install do
        with_run_context new_resource.run_context do
          %w[3 2].each do |p|
            python_runtime p
          end
        end
      end

      action :remove do
        with_run_context new_resource.run_context do
          %w[3 2].each do |p|
            python_runtime(p) { action :uninstall }
          end
        end
      end
    end
  end
end
