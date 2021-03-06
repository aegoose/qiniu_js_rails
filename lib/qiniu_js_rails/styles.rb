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
          def #{column}=(split_str)
            olds = #{column}_keys # 取旧的
            super(split_str) # 更新值
            news = #{column}_keys # 取新的
            # 数组的差集操作
            deletes = deleted_images + olds - news
            @deleted_images =  deletes.uniq
            # super(split_str)
          end

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

          def #{column}_path_by_key(key)
            mty = #{column}_model_type
            mid = #{column}_model_id
            self.class.get_qiniu_image_path(mty, mid, key)
          end

          ### 图片删除相关 ###

          def deleted_images
            @deleted_images || []
          end
          def clear_deleted_images
            @deleted_images = nil
          end

          def flush_deleted_images
            paths = deleted_images.map do |key|
               delete_qiniu_image #{column}_path_by_key(key)
            end
            clear_deleted_images
            paths
          end

          def delete_all_images
            # 清除掉更新的
            paths1 = flush_deleted_images
            # 清除掉正在变化的
            paths = #{column}_paths || []
            delete_qiniu_images paths

            paths1 + paths
          end

        RUBY

        init_qiniu_styles(versions)

        get_qiniu_styles.each do |ver, value|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def get_#{column}_#{ver}_url(key)
              imgurl = nil
              if key
                mty = #{column}_model_type
                mid = #{column}_model_id
                imgpath = self.class.get_qiniu_image_path(mty, mid, key)
                imgurl = self.class.qiniu_url(:#{ver}, imgpath)
              end
              imgurl
            end
            def #{column}_#{ver}_urls
              #{column}_keys.map{|key| get_#{column}_#{ver}_url(key) }
            end
            def #{column}_#{ver}_url
              #{column}_#{ver}_urls&.first
            end

          RUBY
        end

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{column}_objects
            mty = #{column}_model_type
            mid = #{column}_model_id
            #{column}_keys.map do |key|
              imgpath = self.class.get_qiniu_image_path(mty, mid, key)
              imgobj = {key:key, path:imgpath}
              self.class.get_qiniu_styles.each do |ver, value|
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
        @@_qiniu_styles || {}
      end

      def init_qiniu_styles(versions=nil)
          _styles = {}
          in_styles = nil
          if versions
            # Set custom styles
            in_styles = versions
          elsif QiniuJsRails.qiniu_styles
            # Set default styles
            in_styles = QiniuJsRails.qiniu_styles
          end

          if in_styles.is_a? Array
            _styles = in_styles.map { |version| [version.to_sym, nil] }.to_h
          elsif in_styles.is_a? Hash
            _styles = in_styles.symbolize_keys
          end
          @@_qiniu_styles = _styles
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

      def delete_qiniu_image(path)
        qiniu_connection.delete(path) if path
        path
      end

      ## 删除云图片
      def delete_qiniu_images(paths)
        paths&.map {|path| delete_qiniu_image(path) }
      end
    end
  end
end
