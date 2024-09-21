class AddDiscountsToCoupons < ActiveRecord::Migration[7.1]
  def change
    add_column :coupons, :dollars_off, :integer
    add_column :coupons, :percentage_off, :decimal
  end
end
