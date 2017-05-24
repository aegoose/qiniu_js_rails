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

          def #{column}_keys
            # 将值进行分解 key!wxh,key!wxh
            str = #{column}
            return [] if str.nil?

            # str.split(",").inject([]) {|result,elem| result + e.split('-')}
            arr = str.split(",").map{ |elem| elem.gsub(/!.*$/, '') }
            mty = #{column}_model_type
            mid = #{column}_model_id
            arr.map {|elem| self.class.get_qiniu_image_path(mty, mid, elem) }
          end

          def new_image_policy(new_id)
            mid = #{column}_model_id
            mty = #{column}_model_type
            self.class.new_image_policy(mty, mid, new_id)
          end

          def self.new_image_policy(mty, mid, new_id)
            key = get_qiniu_image_path(mty, mid, new_id)
            Qiniu::Auth::PutPolicy.new(
                QiniuJsRails.qiniu_bucket, # 存储空间
                key,    # 指定上传的资源名，如果传入 nil，就表示不指定资源名，将使用默认的资源名
                3600    # token 过期时间，默认为 3600 秒，即 1 小时
            )

          end

        RUBY

        init_qiniu_styles(versions)

        get_qiniu_styles.each do |ver, value|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{column}_#{ver}_urls
              #{column}_keys.map{|key, v| self.class.qiniu_url(:#{ver}, key) }
            end
            def #{column}_#{ver}_url
              #{column}_#{ver}_urls.first
            end
          RUBY
        end

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
