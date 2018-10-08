# frozen_string_literal: true

require 'chef/resource'

class Chef
  class Resource
    # A stub python_runtime resource. So much happens at compile time with
    # runtime and package resources finding each other and Chefspec doesn't
    # play well with it.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class PythonRuntime < Resource
      provides :python_runtime

      property :options, Hash

      %i[install uninstall].each do |act|
        action act do
        end
      end
    end
  end
end
