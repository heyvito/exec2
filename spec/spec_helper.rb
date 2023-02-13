# frozen_string_literal: true

require "simplecov"
require "simplecov_json_formatter"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new [
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start do
  add_filter "/spec/"
end

require 'etc'
require "exec2"
require_relative "./exec_parser"

module Helpers
  def user_shell
    login = Etc.getlogin
    Etc.getpwnam(login).shell
  end
end

RSpec.configure do |config|
  include Helpers

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
