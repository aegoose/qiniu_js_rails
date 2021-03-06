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

    assert_equal(p.images_key, "#{pimg}", "should have images_key")

    assert_equal(p.images_keys, ["#{pimg}"], "should have images_keys")
    assert_equal(p.images_path, "product/#{pid}/#{pimg}", "should have images_path")
    assert_equal(p.images_path_by_key("#{pimg}"), "product/#{pid}/#{pimg}", "should have images_path_by_key")
    assert_equal(p.images_paths, ["product/#{pid}/#{pimg}"], "should have images_paths")

  end

  test "product should not raise error when empty" do
    p = Product.new
    assert_nil(p.images_key)
    assert_equal(p.images_keys, [])

    assert_nil(p.images_path)
    assert_equal(p.images_paths, [])

    assert_nil(p.images_medium_url)
    assert_equal(p.images_medium_urls, [])

    assert_nil(p.images_big_url)
    assert_equal(p.images_big_urls, [])

    assert_nil(p.images_small_url)
    assert_equal(p.images_small_urls, [])
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

    assert_equal(p.images_paths, ["product/#{pid}/#{pimg1}.jpg", "product/#{pid}/#{pimg2}"])

    assert_equal(Product.get_qiniu_styles, {big:nil, medium:nil, small:nil})
    base_url = QiniuJsRails.qiniu_protocol + "://" + QiniuJsRails.qiniu_bucket_domain
    Product.get_qiniu_styles.each do|style, value|
        assert_equal(p.send(:"images_#{style}_urls"), p.images_paths.map{|x| "#{base_url}/#{x}-#{style}"})
    end

  end

  test "product instance should have images_objects methods" do
    pid = 10
    pimg1 = "abc"
    pimg2 = "def.jpg"
    p = Product.new
    p.images = "#{pimg1}!400x800,#{pimg2}!500x800"
    p.id = pid

    imgs =  p.images_objects
    assert_equal(imgs.size, 2)
    assert_equal(imgs[0].keys, [:key, :path, :big, :medium, :small])
    assert_equal(imgs[1].keys, [:key, :path, :big, :medium, :small])
    # puts "---images_objects: #{p.images_objects}----"
  end

  test 'product sub model should have get_qiniu_styles' do
    class P1 < Product; end
    assert_not_nil(P1.get_qiniu_styles)
    assert_not_empty(P1.get_qiniu_styles)
    assert_equal(P1.get_qiniu_styles.keys, [:big, :medium, :small])
  end

  test 'product should have deleted_images' do
    pid = 10
    pimg1 = "abc"
    pimg2 = "def.jpg"

    p = Product.new
    p.id = pid
    p.images = "#{pimg1},#{pimg2}"
    assert_equal p.deleted_images, []
    p.images = "#{pimg1}"
    assert_equal p.deleted_images, [pimg2]
    p.images = nil
    assert_equal p.deleted_images, [pimg2, pimg1]

    p.clear_deleted_images
    assert_equal p.deleted_images, []
  end

  test 'product should have delete_qiniu_image methods' do
    Product.class_eval do
      def delete_qiniu_image(path)
        return path if path
      end
    end

    p = Product.new
    p.images = "abc"
    p.id = 1
    assert(p.methods.include?(:delete_qiniu_image))
    assert(p.methods.include?(:delete_qiniu_images))
    path = p.images_path_by_key('abc')
    assert_equal(path, p.delete_qiniu_image(path))

    p.images = "kkk!100x200,mmm!300x400"
    path2 = [p.images_path_by_key('kkk'), p.images_path_by_key('mmm')]
    assert_equal(path2, p.delete_qiniu_images(p.images_paths))

  end

  test 'product should have flush_deleted_images and delete_all_images' do
    Product.class_eval do
      def delete_qiniu_image(path)
        return path if path
      end
    end

    p = Product.new
    p.id = 1
    assert(p.methods.include?(:flush_deleted_images))
    assert(p.methods.include?(:delete_all_images))

    p.images = "abc"
    p.images = "ddd!800x800,ccc"
    assert_equal [p.images_path_by_key('abc'), p.images_path_by_key('ddd'), p.images_path_by_key('ccc')], p.delete_all_images

    p.images = "mmm"
    p.clear_deleted_images
    p.images = "nnn"
    assert_equal [p.images_path_by_key('mmm')], p.flush_deleted_images

  end

end



