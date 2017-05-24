# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

Rails::TestUnitReporter.executable = 'bin/test'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

# require 'redgreen/autotest'
# require "minitest/autorun"

Test_qiniu_bucket_domain = 'on6fxghvm.bkt.clouddn.com'
Test_qiniu_protocol = 'http'
Test_qiniu_bucket = 'manabook'
Test_qiniu_access_key = '6Hlx_esyOGtSbyjg7pVMeguB2UImM8Hyzwj58Etr'
Test_qiniu_secret_key = 'Na4j29VQjdVA07TXnVrdtj0KC-NDJ_QbyenxQvgz'
Test_qiniu_styles = [ :big, :medium, :small ]

QiniuJsRails.setup do| config |
  unless config.configured?
    config.qiniu_protocol = Test_qiniu_protocol
    config.qiniu_bucket_domain = Test_qiniu_bucket_domain
    config.qiniu_bucket = Test_qiniu_bucket
    config.qiniu_access_key = Test_qiniu_access_key
    config.qiniu_secret_key = Test_qiniu_secret_key
    config.qiniu_styles = Test_qiniu_styles
  end
end
