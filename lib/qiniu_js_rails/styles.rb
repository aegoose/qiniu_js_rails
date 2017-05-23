# require 'active_support/concern'
module QiniuJsRails
  module Styles
    extend ActiveSupport::Concern
    include ::QiniuJsRails::Utilities

    included do
      # init_id_columns
    end

    module ClassMethods

      # options = { styles=>{} }
      def image_styles(column, options={})

        versions = options[:versions]
        model_type_method = options[:model_type_method]
        model_id_method = options[:model_id_method]
        is_list = column.to_s.pluralize == column.to_s

        class_eval <<-RUBY, __FILE__, __LINE__+1

          def #{column}; super; end
          def #{column}=(image_keys); super(image_key); end

          def get_model_type
            raise UnknowMethodError.new unless defined? #{model_type_method}
            send(:#{model_type_method})
          end

          def get_model_id
            unless UnknowMethodError.new defined? #{model_id_method}
            send :#{model_id_method}
          end

          def is_image_list?
            #{is_list}
          end

          def image_key
            image_keys.first
          end

          def image_keys
            # 将值进行分解 key!wxh,key!wxh
            str = #{column}
            # str.split(",").inject([]) {|result,elem| result + e.split('-')}
            arr = str.split(",").map{ |elem| elem.gsub(/!.*$/, '') }

            mty = get_model_type
            mid = get_model_id
            arr.map {|elem| get_image_path(mty, mid, elem) }

          end

        RUBY

        @_qiniu_styles = {}
        if versions
          # Set custom styles
          @_qiniu_styles = parse_qiniu_styles(versions)
        elsif QiniuJsRails.qiniu_styles
          # Set default styles
          @_qiniu_styles = parse_qiniu_styles(QiniuJsRails.qiniu_styles)
        end

        @_qiniu_styles.each do |ver, val|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def image_#{ver}_url
            image_#{ver}_urls.first
          end

          def image_#{ver}_urls
            image_keys.map{|key| qiniu_url(ver, key)}
          end
        RUBY
        end
      end

      ## 删除云图片
      def delete_images
        image_keys.each do | key |
          qiniu_connection.delete(key)
        end
      end

      ##
      def qiniu_connection
        QiniuJsRails.qiniu_connection
      end

      private
      def parse_qiniu_styles(styles)
        if styles.is_a? Array
          styles.map { |version| [version.to_sym, nil] }.to_h
        elsif styles.is_a? Hash
          styles.symbolize_keys
        end
      end

      private
      def get_qiniu_styles
        @_qiniu_styles
      end

      # === Examples:
      #
      #     avatar.url(:big, key)
      #     avatar.url(:small, key)
      #
      private
      def qiniu_url(ver, key_path)
        return super if args.empty?

        base_url = QiniuJsRails.qiniu_protocol + "://" + QiniuJsRails.qiniu_bucket_domain
        if ver.to_s == "org"
          # todo: 可以访问原图
          return "#{base_url}#{key_path}"
        end

        sep = QiniuJsRails.qiniu_style_separator
        styles = get_qiniu_styles
        curr_style = styles[ver]

        if curr_style.nil?
          return "#{base_url}#{key_path}#{sep}#{ver}"
        end

        return "#{base_url}#{key_path}?#{curr_style}"

      end
    end
  end
end
