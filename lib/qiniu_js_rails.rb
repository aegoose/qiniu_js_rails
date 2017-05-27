# encoding: utf-8
# require "qiniu_js_rails/qiniu/configuration"
# require "qiniu_js_rails/qiniu/style"
# require "carrierwave/qiniu/railtie" if defined?(Rails)

require 'qiniu_js_rails/engine' if defined? Rails::Engine
require "plupload/rails" if defined? Rails::Engine

module QiniuJsRails
  extend ActiveSupport::Autoload

  autoload :Utilities
  autoload :Storage
  # autoload :Engine
  # autoload :Connection
  # autoload :Styles

  eager_autoload do
    autoload :Connection
    autoload :Styles
  end

  def self.eager_load!
    super
    # QiniuJsRails::Styles.eager_load!
  end

    # 定义一些异常
  class QiniuJsRailsError < StandardError; end
  class UnknowMethodError < QiniuJsRailsError; end
  class InvalidParameterError < QiniuJsRailsError; end
  class ProcessingError < QiniuJsRailsError; end
  class UploadError < QiniuJsRailsError; end
  class DownloadError < QiniuJsRailsError; end
  class UnknownStorageError < QiniuJsRailsError; end


  @@configured = false
  def self.configured? #:nodoc:
    @@configured
  end

  # 七牛图片域名
  mattr_accessor :qiniu_bucket_domain
  @@qiniu_bucket_domain = nil

  # 图片空间
  mattr_accessor :qiniu_bucket
  @@qiniu_bucket = nil

  # 空间是否隐私
  mattr_accessor :qiniu_bucket_private
  @@qiniu_bucket_private = false

  # 访问access_key
  mattr_accessor :qiniu_access_key
  @@qiniu_access_key = nil

  # 访问secret_key
  mattr_accessor :qiniu_secret_key
  @@qiniu_secret_key = nil

  # 分页的大小
  mattr_accessor :qiniu_block_size
  @@qiniu_block_size = 1024*1024*4

  # 域名启动的协议
  mattr_accessor :qiniu_protocol
  @@qiniu_protocol = 'http'

  # 非空则启动一个异步数据处理任务
  mattr_accessor :qiniu_async_ops
  @@qiniu_async_ops = ''

  # 异步处理任务完成后的回调
  mattr_accessor :qiniu_persistent_notify_url
  @@qiniu_persistent_notify_url = ''

  # 上传成功的回调地址，七牛云向业务服务器发送POST请求的URL。
  mattr_accessor :qiniu_callback_url
  @@qiniu_callback_url = ''

  # 上传成功后的回调信息格式，如：key=$(key)&hash=$(etag)&w=$(imageInfo.width)&h=$(imageInfo.height)
  # 可以传七牛的变量，也可以传当前系统的变量
  # https://developer.qiniu.com/kodo/manual/1235/vars#magicvar
  mattr_accessor :qiniu_callback_body
  @@qiniu_callback_body = ''

  # 是否覆盖原有图片
  mattr_accessor :qiniu_can_overwrite
  @@qiniu_can_overwrite = false

  # 图片上传的失效时间
  mattr_accessor :qiniu_expires_in
  @@qiniu_expires_in = nil

  # 上传的域名
  mattr_accessor :qiniu_up_host
  @@qiniu_up_host = nil


  # 若是私有空间，指定图片访问过期时间
  mattr_accessor :qiniu_private_url_expires_in
  @@qiniu_private_url_expires_in = 3600

  # 图片缩略图访问的分隔线
  mattr_accessor :qiniu_style_separator
  @@qiniu_style_separator = '-'

  # 缩略图的风格
  mattr_accessor :qiniu_styles
  @@qiniu_styles = nil

  # 数据处理connection, 七牛的图片操作业务
  mattr_accessor :qiniu_connection
  @@qiniu_connection = nil

  def self.setup
    yield self
    @@configured = true
    @@qiniu_connection = Connection.new
  end

end

# QiniuJsRails.setup do| config |
#   unless config.configured?
#     config.qiniu_protocol = 'http'
#     config.qiniu_bucket_domain = 'on6fxghvm.bkt.clouddn.com'
#     config.qiniu_bucket = 'manabook'
#     config.qiniu_access_key = '6Hlx_esyOGtSbyjg7pVMeguB2UImM8Hyzwj58Etr'
#     config.qiniu_secret_key = 'Na4j29VQjdVA07TXnVrdtj0KC-NDJ_QbyenxQvgz'
#     config.qiniu_styles = [ :big, :medium, :small ]
#   end
# end



