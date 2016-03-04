class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.date :start_date
      t.integer :occurence_frequency

      t.timestamps null: false
    end
  end
end
