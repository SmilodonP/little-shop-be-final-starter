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
end