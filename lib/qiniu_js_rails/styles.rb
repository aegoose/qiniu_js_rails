# require 'active_support/concern'
module QiniuJsRails
  module Styles
    extend ActiveSupport::Concern
    # include ::QiniuJsRails::Utilities # add instance method

    included do
      # init_id_columns
    end

    module ClassMethods
      include ::QiniuJsRails::Utilities # add class method

      ## 七牛图片配置
      def image_styles(column, options={})

        versions = options[:versions]
        model_type_method = options[:model_type_method]
        model_id_method = options[:model_id_method]

        class_eval <<-RUBY, __FILE__, __LINE__+1

          def #{column}; super; end
          def #{column}=(image_keys); super(image_keys); end

          def #{column}_model_type
            raise UnknowMethodError.new unless self.methods.include? :#{model_type_method}
            send(:#{model_type_method})
          end

          def #{column}_model_id
            raise UnknowMethodError.new unless self.methods.include? :#{model_id_method}
            send(:#{model_id_method})
          end

          def #{column}_key
            #{column}_keys.first
          end

          # [imgkey!100x200,imgkey!300x200]
          def #{column}_keys
            # 将值进行分解 key!wxh,key!wxh
            str = #{column}
            return [] if str.nil?

            # str.split(",").inject([]) {|result,elem| result + e.split('-')}
            str.split(",").map{ |elem| elem.gsub(/!.*$/, '') }

          end

          def #{column}_path
            #{column}_paths.first
          end

          def #{column}_paths
            mty = #{column}_model_type
            mid = #{column}_model_id
            #{column}_keys.map {|elem| self.class.get_qiniu_image_path(mty, mid, elem) }
          end

        RUBY

        init_qiniu_styles(versions)

        get_qiniu_styles.each do |ver, value|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{column}_#{ver}_urls
              #{column}_keys.map{|key, v| #{column}_#{ver}_url(key) }
            end
            def #{column}_#{ver}_url
              #{column}_#{ver}_urls.first
            end
            def #{column}_#{ver}_url(key)
              mty = #{column}_model_type
              mid = #{column}_model_id
              imgpath = self.class.get_qiniu_image_path(mty, mid, key)
              self.class.qiniu_url(:#{ver}, imgpath)
            end
          RUBY
        end

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{column}_objects
            mty = #{column}_model_type
            mid = #{column}_model_id
            #{column}_keys.map do |key|
              imgobj = {key:key}
              self.class.get_qiniu_styles.each do |ver, value|
                imgpath = self.class.get_qiniu_image_path(mty, mid, key)
                imgobj[ver] = self.class.qiniu_url(ver, imgpath)
              end
              imgobj
            end

          end
        RUBY

        include ::QiniuJsRails::Styles::LocalInstanceMethods

      end

      # private
      def get_qiniu_styles
        @_qiniu_styles
      end

      def init_qiniu_styles(versions=nil)
          @_qiniu_styles = {}
          in_styles = nil
          if versions
            # Set custom styles
            in_styles = versions
          elsif QiniuJsRails.qiniu_styles
            # Set default styles
            in_styles = QiniuJsRails.qiniu_styles
          end

          if in_styles.is_a? Array
            @_qiniu_styles = in_styles.map { |version| [version.to_sym, nil] }.to_h
          elsif in_styles.is_a? Hash
            @_qiniu_styles = in_styles.symbolize_keys
          end

      end

      def qiniu_url(ver, key_path)

        base_url = QiniuJsRails.qiniu_protocol + "://" + QiniuJsRails.qiniu_bucket_domain
        if ver.to_s == "org"
          # todo: 可以访问原图
          return "#{base_url}/#{key_path}"
        end

        sep = QiniuJsRails.qiniu_style_separator
        styles = get_qiniu_styles
        curr_style = styles[ver]

        if curr_style.nil?
          return "#{base_url}/#{key_path}#{sep}#{ver}"
        end

        return "#{base_url}/#{key_path}?#{curr_style}"

      end

    end

    module LocalInstanceMethods
      def qiniu_connection
        QiniuJsRails.qiniu_connection
      end

      ## 删除云图片
      def delete_images
        image_keys.each do | key |
          self.class.qiniu_connection.delete(key)
        end
      end
    end
  end
end
