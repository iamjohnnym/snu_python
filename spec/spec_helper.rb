# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'
require 'simplecov'
require 'simplecov-console'

RSpec.configure do |c|
  c.add_setting :supported_platforms, default: {
    debian: %w[9.3 8.10],
    # TODO: Ubuntu 18.04 requires a Chef-DK baked with Fauxhai 6.1.0+.
    ubuntu: %w[16.04 14.04]
  }
end

SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.minimum_coverage(100)
SimpleCov.start
