module QiniuJsRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy Qiniu Sdk initializers files"
      source_root File.expand_path('../templates', __FILE__)

      def copy_config
        template "config/initializers/qiniu_sdk.rb"
      end

    end
  end
end
