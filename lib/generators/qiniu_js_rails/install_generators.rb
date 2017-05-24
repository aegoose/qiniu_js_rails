module QiniuJsRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy Qiniu js rails initializers files"
      source_root File.expand_path('../templates', __FILE__)

      def copy_config
        template "config/initializers/qiniu_js_rails.rb"
      end

      def show_readme
        readme "README"
      end

    end
  end
end
