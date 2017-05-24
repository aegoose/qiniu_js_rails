class Product < ApplicationRecord

  include ::QiniuJsRails::Styles

  image_styles :images, model_type_method: :product_dir, model_id_method: :id

  def product_dir
    "product"
  end

end
