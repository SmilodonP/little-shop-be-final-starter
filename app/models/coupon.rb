class Coupon < ApplicationRecord
  belongs_to :merchant
  belongs_to :invoice, optional: true

  validates_presence_of :name, :code
  validates :code, uniqueness: true
  validate :dollars_or_percentage
  validate :merchant_has_active_coupons, on: :create

  enum :status, { activated: 0, deactivated: 1 }, validate: true

  private

  def dollars_or_percentage
    if dollars_off.blank? && percentage_off.blank?
      errors.add(:base, "A coupon must have a discount")
    elsif dollars_off.present? && percentage_off.present?
      errors.add(:base, "Enter either a dollar or a percentage discount, not both")
    end
  end

  def merchant_has_active_coupons
    if merchant.coupons.where(status: :activated).count >= 5
      errors.add(:base, "Merchant already has 5 active coupons")
    end
  end
end
