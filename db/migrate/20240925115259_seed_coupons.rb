class SeedCoupons < ActiveRecord::Migration[7.1]
  def up
    require 'faker'

    ActiveRecord::Base.transaction do
      Merchant.all.each do |merchant|
        3.times do
          Coupon.create!(
            name: Faker::Company.bs,
            code: Faker::Alphanumeric.unique.alphanumeric(number: 8).upcase,
            merchant_id: merchant.id,
            invoice_id: nil,
            dollars_off: rand(5..50),
            percentage_off: nil,
            status: [0, 1].sample,
            created_at: Faker::Time.backward(days: 30),
            updated_at: Faker::Time.backward(days: 5)
          )
        end

        2.times do
          Coupon.create!(
            name: Faker::Company.bs,
            code: Faker::Alphanumeric.unique.alphanumeric(number: 8).upcase,
            merchant_id: merchant.id,
            invoice_id: nil,
            dollars_off: nil,
            percentage_off: rand(5.00..50.00).round(2),
            status: [0, 1].sample,
            created_at: Faker::Time.backward(days: 30),
            updated_at: Faker::Time.backward(days: 5)
          )
        end
      end
    end
  end

  def down
    Coupon.where(code: Coupon.pluck(:code)).destroy_all
  end
end
