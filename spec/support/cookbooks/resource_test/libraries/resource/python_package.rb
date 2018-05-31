# frozen_string_literal: true

require 'chef/resource'

class Chef
  class Resource
    # A stub python_package resource. So much happens at compile time with
    # runtime and package resources finding each other and Chefspec doesn't
    # play well with it.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class PythonPackage < Resource
      provides :python_package

      property :package_name, [String, Array], identity: true
      property :python, String
      property :version, String
      property :virtualenv, String

      %i[install upgrade remove].each do |act|
        action act do
        end
      end
    end
  end
end
