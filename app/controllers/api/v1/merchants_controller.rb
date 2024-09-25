class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all

    if params[:sorted].present? && params[:sorted] == "age"
      merchants = merchants.sorted_by_creation
    elsif params[:status].present?
      merchants = Merchant.filter_by_status(params[:status])
    end

    include_count = params[:count].present? && params[:count] == "true"
    render json: MerchantSerializer.new(merchants, { params: { count: include_count }})

    # ADD - Update the merchants index endpoint to include a count of coupons for each merchant and a count of invoices with coupons applied for each merchant.
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  def create
    merchant = Merchant.create!(merchant_params) 
    render json: MerchantSerializer.new(merchant), status: :created
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update!(merchant_params)

    render json: MerchantSerializer.new(merchant)
  end

  def destroy
    merchant = Merchant.find(params[:id])
    merchant.destroy
  end

  private

  def merchant_params
    params.permit(:name)
  end
end
