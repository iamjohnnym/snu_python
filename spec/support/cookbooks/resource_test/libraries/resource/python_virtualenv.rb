# frozen_string_literal: true

require 'chef/resource'

class Chef
  class Resource
    # A stub python_virtualenv resource. So much happens at compile time with
    # runtime and virtualenv resources finding each other and Chefspec doesn't
    # play well with it.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class PythonVirtualenv < Resource
      provides :python_virtualenv

      property :path, String, identity: true
      property :python, String
      property :user, String
      property :group, String

      %i[create delete].each do |act|
        action act do
        end
      end
    end
  end
end
