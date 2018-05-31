# frozen_string_literal: true

#
# Cookbook:: snu_python
# Library:: resource/snu_python_virtualenv
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
    # An extremely light wrapper around the python_virtualenv resource to
    # explicitly set a default of installing under Python 2.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class SnuPythonVirtualenv < Resource
      provides :snu_python_virtualenv

      property :path, String, name_property: true
      property :python, String, default: '2'
      property :user, String
      property :group, String

      default_action :create

      #
      # Every supported action should just be passed on to an underlying
      # python_virtualenv resource.
      #
      %i[create delete].each do |act|
        action act do
          with_run_context new_resource.run_context do
            python_virtualenv new_resource.name do
              %i[path python user group].each do |prop|
                unless new_resource.send(prop).nil?
                  send(prop, new_resource.send(prop))
                end
              end
              action act
            end
          end
        end
      end
    end
  end
end
