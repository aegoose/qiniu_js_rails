require "qiniu"

module QiniuJsRails
  class Connection
    def initialize()
      @qiniu_bucket_domain          = QiniuJsRails.qiniu_bucket_domain
      @qiniu_bucket                 = QiniuJsRails.qiniu_bucket
      @qiniu_bucket_private         = QiniuJsRails.qiniu_bucket_private
      @qiniu_access_key             = QiniuJsRails.qiniu_access_key
      @qiniu_secret_key             = QiniuJsRails.qiniu_secret_key
      @qiniu_block_size             = QiniuJsRails.qiniu_block_size
      @qiniu_protocol               = QiniuJsRails.qiniu_protocol
      @qiniu_async_ops              = QiniuJsRails.qiniu_async_ops
      @qiniu_can_overwrite          = QiniuJsRails.qiniu_can_overwrite
      @qiniu_expires_in             = QiniuJsRails.qiniu_expires_in || 3600
      @qiniu_up_host                = QiniuJsRails.qiniu_up_host
      @qiniu_private_url_expires_in = QiniuJsRails.qiniu_private_url_expires_in
      @qiniu_callback_url           = QiniuJsRails.qiniu_callback_url
      @qiniu_callback_body          = QiniuJsRails.qiniu_callback_body
      @qiniu_persistent_notify_url  = QiniuJsRails.qiniu_persistent_notify_url
      @qiniu_style_separator        = QiniuJsRails.qiniu_style_separator

      init
    end

    ## 上传图片
    #
    def store(file_path, key)
      overwrite_file = nil
      overwrite_file = key if @qiniu_can_overwrite

      put_policy = ::Qiniu::Auth::PutPolicy.new(
        @qiniu_bucket,
        overwrite_file,
        @qiniu_expires_in,
        nil
      )
      put_policy.callback_url          = @qiniu_callback_url if @qiniu_callback_url.present?
      put_policy.callback_body         = @qiniu_callback_body if @qiniu_callback_body.present?

      put_policy.persistent_ops        = @qiniu_async_ops
      put_policy.persistent_notify_url = @qiniu_persistent_notify_url if @qiniu_persistent_notify_url.present?

      resp_code, resp_body, resp_headers =
        ::Qiniu::Storage.upload_with_put_policy(
          put_policy,
          file_path,
          key,
          nil,
          bucket: @qiniu_bucket
        )

      if resp_code < 200 or resp_code >= 300
        raise ::QiniuJsRails::UploadError, "Upload failed, status code: #{resp_code}, response: #{resp_body}"
      end
    end

    #
    # @note 复制远程图片
    # @param origin [String]
    # @param target [String]
    # @return [Boolean]
    #
    def copy(origin, target)
      resp_code, resp_body, _ = ::Qiniu::Storage.copy(@qiniu_bucket, origin, @qiniu_bucket, target)
      if resp_code < 200 or resp_code >= 300
        raise ::QiniuJsRails::ProcessingError, "Copy failed, status code: #{resp_code}, response: #{resp_body}"
      end
    end

    # 删除远程图片
    def delete(key)
      ::Qiniu::Storage.delete(@qiniu_bucket, key) rescue nil
    end

    def stat(key)
      code, result, _ = ::Qiniu::Storage.stat(@qiniu_bucket, key)
      code == 200 ? result : {}
    end

    def get(path)
      code, result, _ = ::Qiniu::HTTP.get( download_url(path) )
      code == 200 ? result : nil
    end

    # 可下载的url
    def download_url(path)
      encode_path = URI.escape(path) #fix chinese file name, same as encodeURIComponent in js but preserve slash '/'
      primitive_url = "#{@qiniu_protocol}://#{@qiniu_bucket_domain}/#{encode_path}"
      @qiniu_bucket_private ? \
        ::Qiniu::Auth.authorize_download_url(primitive_url, :expires_in => @qiniu_private_url_expires_in) \
        : \
        primitive_url

    end

    private

    def init
      init_qiniu_rs_connection
    end

    UserAgent = "QiniuJsRails-Qiniu/#{QiniuJsRails::VERSION} (#{RUBY_PLATFORM}) Ruby/#{RUBY_VERSION}".freeze

    def init_qiniu_rs_connection
      options = {
        :access_key => @qiniu_access_key,
        :secret_key => @qiniu_secret_key,
        :user_agent => UserAgent
      }
      options[:block_size] = @qiniu_block_size if @qiniu_block_size
      options[:up_host]    = @qiniu_up_host if @qiniu_up_host

      ::Qiniu.establish_connection! options

    end

  end
end

