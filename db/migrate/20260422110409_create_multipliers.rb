class CreateMultipliers < ActiveRecord::Migration[8.1]
  def change
    create_table :multipliers do |t|
      t.string :name, null: false
      t.float :value, null: false, default: 1

      t.timestamps
    end
  end
end
