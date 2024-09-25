class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :dollars_off, :percentage_off, :status, :merchant_id, :invoice_id 
end