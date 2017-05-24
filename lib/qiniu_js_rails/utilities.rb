module QiniuJsRails
  module Utilities
    def get_qiniu_image_path(type, par_id, key)

      type = "default" if type.nil?

      newkey = "#{key}"

      raise InvalidParameterError, "url key is null" if newkey.empty?

      newkey = newkey.gsub(/\.(jpg|jpeg|png)$/, "")

      newkey = "#{Time.now.to_i}" if newkey.empty?

      newkey += ".jpg"

      return "#{type}/#{newkey}" if par_id.nil?

      "#{type}/#{par_id}/#{newkey}"

    end


  end
end
