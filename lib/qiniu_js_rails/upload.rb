module QiniuJsRails
  module Upload
    include ::QiniuJsRails::Utilities

    def new_image_policy(model_type, model_id, new_id)
        # new_id = nil
        # case model_type.to_sym
        # when :product, :product_sku, :product_content
        #   new_id = Snowflake::SnowflakeFactory.next_product_image
        # when :user
        #   new_id = Snowflake::SnowflakeFactory.next_user_avatar
        # end
        return nil if new_id.nil?
        key = get_qiniu_image_path(model_type, model_id, new_id)
        Qiniu::Auth::PutPolicy.new(
            QiniuJsRails.qiniu_bucket, # 存储空间
            key,    # 指定上传的资源名，如果传入 nil，就表示不指定资源名，将使用默认的资源名
            3600    # token 过期时间，默认为 3600 秒，即 1 小时
        )

    end
  end
end
