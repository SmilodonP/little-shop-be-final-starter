require "rails_helper"

RSpec.describe Coupon do
  let!(:merchant) { create(:merchant) }
  let!(:coupon) { create(:coupon, merchant: merchant, status: :activated, created_at: 5.days.ago) }

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

  describe "Model Logic:" do
    it "cannot have more than 5 active coupons" do
      4.times { create(:coupon, merchant: merchant, status: :activated) }
      new_coupon = build(:coupon, merchant: merchant, status: :activated)

      expect(new_coupon).to_not be_valid
      expect(new_coupon.errors[:base]).to include("Merchant already has 5 active coupons")
    end

    it "can create new coupon if the merchant has less than 5 active coupons" do
      3.times { create(:coupon, merchant: merchant, status: :activated) }
      new_coupon = build(:coupon, merchant: merchant, status: :activated)
      expect(new_coupon).to be_valid
    end

    it "handles if both dollars_off and percentage_off are present" do
      coupon = build(:coupon, dollars_off: 10, percentage_off: 5, merchant: merchant)
      expect(coupon).not_to be_valid
      expect(coupon.errors[:base]).to include("Enter either a dollar or a percentage discount, not both")
    end

    it "handles if neither dollars_off nor percentage_off are provided" do
      coupon = build(:coupon, dollars_off: nil, percentage_off: nil, merchant: merchant)
      expect(coupon).not_to be_valid
      expect(coupon.errors[:base]).to include("A coupon must have a discount")
    end

    describe "Sort coupons by status:" do
      let!(:activated_coupon1) { create(:coupon, status: 'activated', created_at: 1.day.ago) }
      let!(:activated_coupon2) { create(:coupon, status: 'activated', created_at: 2.days.ago) }
      let!(:deactivated_coupon1) { create(:coupon, status: 'deactivated', created_at: 3.days.ago) }
      let!(:deactivated_coupon2) { create(:coupon, status: 'deactivated', created_at: 4.days.ago) }
  
      it 'returns all coupons sorted by activated first' do
        coupons = Coupon.all
        sorted_coupons = coupons.sort_by_status(coupons, 'activated')
  
        expect(sorted_coupons).to match_array([activated_coupon1, activated_coupon2, coupon, deactivated_coupon1, deactivated_coupon2])

      end
  
      it 'returns all coupons sorted by deactivated first' do
        coupons = Coupon.all
        sorted_coupons = coupons.sort_by_status(coupons, 'deactivated')
  
        expect(sorted_coupons).to match_array([deactivated_coupon1, deactivated_coupon2, activated_coupon1, activated_coupon2, coupon])

      end
  
      it 'returns all coupons if status is nil' do
        coupons = Coupon.all
        sorted_coupons = coupons.sort_by_status(coupons)
  
        expect(sorted_coupons).to match_array([activated_coupon1, activated_coupon2, coupon, deactivated_coupon1, deactivated_coupon2])
      end
    end
  end
end