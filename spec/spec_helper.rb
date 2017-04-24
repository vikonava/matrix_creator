require 'simplecov'
require 'bundler/setup'
require 'support/wait_until'
require 'support/matrix_protobuf'

SimpleCov.start do
  add_filter 'spec/*'
  add_filter 'lib/protos/*'
end

require 'matrix_creator'
require 'matrix_creator/comm'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.include WaitUntil
  config.extend MatrixProtobuf

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
