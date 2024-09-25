cmd = "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U $(whoami) -d little_shop_development db/data/little_shop_development.pgdump"
puts "Loading PostgreSQL Data dump into local database with command:"
puts cmd
system(cmd)

require 'faker'

ActiveRecord::Base.transaction do
  Merchant.all.each do |merchant|
    3.times do
      Coupon.create!(
        name: Faker::Commerce.promotion_code(adjective: true),
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
        name: Faker::Commerce.promotion_code(adjective: true),
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
