require "rails_helper"

RSpec.describe Coupon do
  let!(:merchant) { create(:merchant) }
  let!(:coupon) { create(:coupon, merchant: merchant) }

  describe "relationships" do
    it { should belong_to :merchant }
    it { should belong_to(:invoice).optional }
  end

  describe "validations" do
    it { should define_enum_for(:status).with_values([:activated, :deactivated]) }
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :code }
    it { should validate_numericality_of(:dollars_off).is_greater_than(0).allow_nil }
    it { should validate_numericality_of(:percentage_off).is_greater_than(0).allow_nil }
  end

  context "Model Logic:" do
    it "does not allow a merchant to have more than 5 active coupons" do
      4.times { create(:coupon, merchant: merchant, status: :activated) }
      new_coupon = build(:coupon, merchant: merchant, status: :activated)

      expect(new_coupon).to_not be_valid
      expect(new_coupon.errors[:base]).to include("Merchant already has 5 active coupons")
    end

    it "allows coupon creation if the merchant has less than 5 active coupons" do
      3.times { create(:coupon, merchant: merchant, status: :activated) }
      new_coupon = build(:coupon, merchant: merchant, status: :activated)
      expect(new_coupon).to be_valid
    end
    
    it "adds an error if both dollars_off and percentage_off are present" do
      coupon = build(:coupon, dollars_off: 10, percentage_off: 5, merchant: merchant)
      expect(coupon).not_to be_valid
      expect(coupon.errors[:base]).to include("Enter either a dollar or a percentage discount, not both")
    end

    it "adds an error if neither dollars_off nor percentage_off are provided" do
      coupon = build(:coupon, dollars_off: nil, percentage_off: nil, merchant: merchant)
      expect(coupon).not_to be_valid
      expect(coupon.errors[:base]).to include("A coupon must have a discount")
    end
  end
end