# require 'qiniu_js_rails'
QiniuJsRails.setup do| config |
  unless config.configured?
    config.qiniu_protocol = 'http'
    config.qiniu_bucket_domain = '<your qiniu_bucket_domain>'
    config.qiniu_bucket = '<your qiniu_bucket name>'
    config.qiniu_access_key = '<your qiniu_access_key>'
    config.qiniu_secret_key = '<your qiniu_secret_key>'
    config.qiniu_styles = [ :big, :medium, :small ]
  end
end
