class CreateDeliveryDates < ActiveRecord::Migration
  def change
    create_table :delivery_dates do |t|
      t.datetime :delivery
      t.integer  :event_id

      t.timestamps null: false
    end
  end
end
