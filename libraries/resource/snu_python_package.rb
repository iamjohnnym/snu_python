# frozen_string_literal: true

#
# Cookbook:: snu_python
# Library:: resource/snu_python_package
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
    # A Chef resource wrapper around python_package. The only difference
    # between this resource and poise-python's python_package is that we
    # explicitly default to installing in Python 2.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class SnuPythonPackage < PoisePython::Resources::PythonPackage::Resource
      provides :snu_python_package

      attribute :python, kind_of: String, default: 'python2'
    end
  end
end
