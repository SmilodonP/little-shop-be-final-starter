class Coupon < ApplicationRecord
  validates_presence_of :name, :code
  validates :code, uniqueness: true
  validates :dollars_off, presence: true :unless => proc{|obj| obj.dollars_off.blank?}
  validates :percentage_off, presence: true :unless => proc{|obj| obj.percentage_off.blank?}
  validate :dollars_or_percentage
  belongs_to :merchant
  belongs_to :invoice, optional: true, 
  
  enum :status, { deactivated: 0, activated; 1 }, validate: true


  private

  def dollars_or_percentage
    if !(dollars_off.blank? ^ percentage_off.blank?)
      errors[:base] << "Enter either a dollar or percentage discount, not both"
    end
  end
end