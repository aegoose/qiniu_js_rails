require 'test_helper'

class ProductController
  include QiniuJsRails::Upload
end

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

  test "QiniuJsRails::Storage should have policy method" do

    p = ProductController.new
    mty = "product"
    mid = 1
    new_id = "1.jpg"

    policy = p.generate_image_policy(mty, mid, new_id)

    assert_equal(policy.bucket, QiniuJsRails.qiniu_bucket, "policy should with bucket #{QiniuJsRails.qiniu_bucket}")
    assert_equal(policy.key, "product/#{mid}/#{new_id}", "policy should with key product/#{mid}/#{new_id}")

    token0 = Qiniu::Auth.generate_uptoken(policy)

    token1 = p.generate_image_token(mty, mid, new_id)

    assert_not_empty(token0)

    assert_equal(token0, token1)

  end

  test "QiniuJsRails::Version" do
    assert_equal(QiniuJsRails::VERSION, "0.1.0")
    # puts "---version: #{QiniuJsRails::VERSION}----"
  end

  # test "test require gem" do
  #   require 'bundler'
  #   Bundler.require :default  # <-- I expected this to load dependencies in from the gemspec

  #   puts "Dependency loaded: " + defined?(Rack).inspect
  # end
end
