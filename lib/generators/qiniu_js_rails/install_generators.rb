module QiniuJsRails
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc "Copy Qiniu js rails initializers files"

      def copy_config_file
        template 'qiniu_js_rails.rb', 'config/initializers/qiniu_js_rails.rb'
      end

    end
  end
end
