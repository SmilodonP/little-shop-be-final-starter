class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons
    render json: CouponSerializer.new(coupons)
  end

  def show
    coupon = Coupon.find(params[:id])
    render json: CouponSerializer.new(coupon)
    # Returns a specific coupon and shows a count of how many times that coupon has been used.
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
  
    if merchant.coupons.where(status: 0).count >= 5
      render json: { error: 'Merchant already has 5 active coupons' }, status: :bad_request
    elsif Coupon.exists?(code: params[:code])
      render json: { error: 'Coupon code must be unique' }, status: :bad_request
    else
      coupon = merchant.coupons.create!(coupon_params)
      render json: CouponSerializer.new(coupon)
    end
  end

  def activate
    coupon = Coupon.find(params[:id])
    if coupon.activated?
      render json: { error: 'Coupon is already activated' }, status: :bad_request
    else
      coupon.update!(status: 0)
      render json: CouponSerializer.new(coupon)
    end
  end
  
  def deactivate
    coupon = Coupon.find(params[:id])
    if coupon.deactivated?
      render json: { error: 'Coupon is already deactivated' }, status: :bad_request
    else
      coupon.update!(status: 1)
      render json: CouponSerializer.new(coupon)
    end
  end

  private

  def coupon_params
    params.permit(:name, :code, :dollars_off, :percentage_off, :merchant_id, :invoice_id)
  end
end