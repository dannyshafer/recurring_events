class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.datetime :start_date
      t.integer :occurence_frequency
      t.datetime :delivery_date

      t.timestamps null: false
    end
  end
end
