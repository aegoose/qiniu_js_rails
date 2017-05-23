module QiniuJsRails
  module Utilities
    def get_image_path(type, par_id, key)

      type = "default" if type.nil?

      raise InvalidParameterError.new("key is null") if key.nil?

      "#{type}/#{key}/" if par_id.nil?

      "#{type}/#{par_id}/#{key}/"

    end
  end
end
