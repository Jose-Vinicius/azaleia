class CreateOkrsAndKeyResults < ActiveRecord::Migration[8.1]
  def change
    create_table :okrs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :quarter, null: false, default: "Q3 2026"
      t.integer :status, null: false, default: 1

      t.timestamps
    end

    create_table :key_results do |t|
      t.references :okr, null: false, foreign_key: true
      t.text :title, null: false

      t.timestamps
    end

    add_reference :tasks, :key_result, foreign_key: true
  end
end
