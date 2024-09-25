FactoryBot.define do
  factory :coupon do
    name { Faker::Marketing.buzzwords }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 9).upcase } 
    dollars_off { Faker::Number.between(from: 1, to: 50) }
    percentage_off {nil}
    association :merchant
    status { :activated } 
  end

  trait :with_percentage_discount do
    dollars_off { nil }
    percentage_off { Faker::Number.between(from: 1, to: 50) }
  end

  trait :deactivated do
    status { :deactivated }
  end
end

# How to implement in tests:
# create(:coupon)
# create(:coupon, :with_percentage_discount)
# create(:coupon, :deactivated)