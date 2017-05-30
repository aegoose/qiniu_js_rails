require 'test_helper'

class QiniuJsRailsStylesTest < ActiveSupport::TestCase

  test "product instance should have sevrial methods" do

    pid = 10
    pimg = "abc.jpg"

    assert(Product.methods.include?(:get_qiniu_styles))
    assert(Product.methods.include?(:init_qiniu_styles))
    assert(Product.methods.include?(:qiniu_url))
    assert(Product.methods.include?(:image_styles))

    p = Product.new
    p.images = "#{pimg}!400x800"
    p.id = pid

    assert_equal(p.images_model_type, "product", "should have images_model_type")

    assert_equal(p.images_model_id, pid, "should have images_model_id")

    assert_equal(p.images_key, "product/#{pid}/#{pimg}", "should have images_key")

    assert_equal(p.images_keys, ["product/#{pid}/#{pimg}"], "should have images_keys")

  end


  test "product instance should have sevrial images thumb methods" do

    # assert_throws(QiniuJsRails::InvalidParameterError) { p.get_qiniu_image_path("product", 1, "") }
    assert_equal(Product.get_qiniu_image_path("product", nil, "test.jpeg"), "product/test.jpg")
    assert_equal(Product.get_qiniu_image_path(nil, nil, "test.jpeg"), "default/test.jpg")
    assert_equal(Product.get_qiniu_image_path("product", 1, "test"), "product/1/test.jpg")
    assert_equal(Product.get_qiniu_image_path("product", 1, "test.png"), "product/1/test.jpg")
    assert_equal(Product.get_qiniu_image_path("product", 1, "test.jpeg"), "product/1/test.jpg")

    pid = 10
    pimg1 = "abc"
    pimg2 = "def.jpg"

    p = Product.new
    p.images = "#{pimg1}!400x800,#{pimg2}!500x800"
    p.id = pid

    assert_equal(p.images_keys, ["product/#{pid}/#{pimg1}.jpg", "product/#{pid}/#{pimg2}"])


    assert_equal(Product.get_qiniu_styles, {big:nil, medium:nil, small:nil})
    base_url = QiniuJsRails.qiniu_protocol + "://" + QiniuJsRails.qiniu_bucket_domain
    Product.get_qiniu_styles.each do|style, value|

      assert_equal(p.send(:"images_#{style}_urls"), p.images_keys.map{|x| "#{base_url}/#{x}-#{style}"})

    end

  end


end






