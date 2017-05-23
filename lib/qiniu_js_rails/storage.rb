module QiniuJsRails
  module storage
    # include :Utilities

    # def new_image_policy(type, id)
    #     path = nil
    #     imgkey = Snowflake::SnowflakeFactory.next_product_image
    #     type = "default" if type.nil?

    #     case type.to_sym
    #     when :Product
    #       path = "#{type}/#{id}/"
    #     when :User
    #       path = "#{type}/#{id}/"
    #     else
    #       path = "#{type}/"
    #       # path
    #     end

    #     key = path + imgkey

    #     Qiniu::Auth::PutPolicy.new(
    #         bucket, # 存储空间
    #         key,    # 指定上传的资源名，如果传入 nil，就表示不指定资源名，将使用默认的资源名
    #         3600    # token 过期时间，默认为 3600 秒，即 1 小时
    #     )
    # end
  end
end
