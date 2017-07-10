# qiniu_js_rails
integrate qiniu form upload (js-sdk, plupload-rails) and qiniu-ruby-sdk for qiniu upload

## Usage

- init configure setup

Initialize on the config/initializes/qiniu_js_rails.rb

```shell
rails generate qiniu_js_rails:install
```

```ruby
QiniuJsRails.setup do| config |
  unless config.configured?
    config.qiniu_protocol = 'http'
    config.qiniu_bucket_domain = '<your qiniu_bucket_domain>'
    config.qiniu_bucket = '<your qiniu_bucket name>'
    config.qiniu_access_key = '<your qiniu_access_key>'
    config.qiniu_secret_key = '<your qiniu_secret_key>'
    config.qiniu_styles = [ :big, :medium, :small ]
  end
end
```

- include QiniuJsRails::Styles to model

```ruby
class Product < ApplicationRecord

  include ::QiniuJsRails::Styles

  image_styles :images, model_type_method: :product_dir, model_id_method: :id

  def product_dir
    "product"
  end

end

```

- invoke in model
```ruby
p = Product.new
p.images = "image_key_xxx.jpg!400x500"
p.id = pid

p.images_key
p.images_path
p.images_path(key)
p.images_keys

p.images_small_urls
p.images_small_url
p.images_big_urls
p.images_big_url
p.images_small_url(key)
p.images_big_url(key)

# key will delete after save
p.deleted_images
p.clear_deleted_images

# [{key:xxx,path:/product/1/xxx.jpg,small:http://..., big:http://...}]
p.images_objects

# for token in controller
policy = p.new_image_policy("new_id")
```


## Installation
Add this line to your application's Gemfile:

```ruby
# gem 'qiniu_js_rails'
gem 'qiniu_js_rails', git: 'https://github.com/aegoose/qiniu_js_rails.git'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install qiniu_js_rails
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
