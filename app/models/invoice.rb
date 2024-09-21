class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_one :coupon, dependent: :destroy, optional: true

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }
end