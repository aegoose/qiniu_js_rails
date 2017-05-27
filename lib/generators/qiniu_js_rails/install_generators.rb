require 'rails/generators/base'

module QiniuJsRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc "Copy Qiniu js rails initializers files"
    end
  end
end
