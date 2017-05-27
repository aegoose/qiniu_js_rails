require 'test_helper'

class QiniuJsRailsTest < ActiveSupport::TestCase

  test "QiniuJsRails should have mattr_accessor values" do
    assert_equal(QiniuJsRails.qiniu_bucket_domain, Test_qiniu_bucket_domain)
    assert_equal(QiniuJsRails.qiniu_protocol, Test_qiniu_protocol)
    assert_equal(QiniuJsRails.qiniu_bucket, Test_qiniu_bucket)
    assert_equal(QiniuJsRails.qiniu_access_key, Test_qiniu_access_key)
    assert_equal(QiniuJsRails.qiniu_secret_key, Test_qiniu_secret_key)
  end

  test "QiniuJsRails.qiniu_connection should have download_url" do
    assert_not_empty(QiniuJsRails.qiniu_connection.download_url("test_path"))
  end

  # test "test require gem" do
  #   require 'bundler'
  #   Bundler.require :default  # <-- I expected this to load dependencies in from the gemspec

  #   puts "Dependency loaded: " + defined?(Rack).inspect
  # end
end
