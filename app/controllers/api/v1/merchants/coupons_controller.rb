class Api::V1::Merchants::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from StandardError, with: :internal_server_error

  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons
    render json: CouponSerializer.new(coupons), status: :ok
  end

  def show
    coupon = find_coupon
    render json: CouponSerializer.new(coupon), status: :ok
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.new(coupon_params)

    if coupon.save
      render json: CouponSerializer.new(coupon), status: :created
    else
      render json: ErrorSerializer.format_errors(coupon.errors.full_messages), status: :unprocessable_entity
    end
  end

  def activate
    coupon = find_coupon
    coupon.update!(status: :activated)
    render json: CouponSerializer.new(coupon), status: :ok
  end
  
  def deactivate
    coupon = find_coupon
    coupon.update!(status: :deactivated)
    render json: CouponSerializer.new(coupon), status: :ok
  end

  private

  def find_coupon
    Coupon.find(params[:id])
  end

  def coupon_params
    params.permit(:name, :code, :dollars_off, :percentage_off, :merchant_id, :invoice_id)
  end
end
