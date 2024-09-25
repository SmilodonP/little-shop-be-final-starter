class UpdateCouponsSchema < ActiveRecord::Migration[7.1]
  def change
        change_column_null :coupons, :invoice_id, true
        change_column :coupons, :percentage_off, :decimal, precision: 5, scale: 2
        add_index :coupons, :code, unique: true
  end
end
