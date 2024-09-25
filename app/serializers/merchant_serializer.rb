class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name

  attribute :item_count, if: Proc.new { |merchant, params|
    params && params[:count] == true
  } do |merchant|
    merchant.item_count
  end

  attribute :coupon_count, if: Proc.new { |merchant, params|
    params && params[:count] == true
  } do |merchant|
    merchant.coupon_count
  end

  attribute :invoices_with_coupons_count, if: Proc.new { |merchant, params|
    params && params[:count] == true
  } do |merchant|
    merchant.invoices_with_coupons_count
  end
end
