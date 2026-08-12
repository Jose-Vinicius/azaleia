class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      
      # Atributos SMART
      t.text :smart_specific
      t.text :smart_measurable
      t.text :smart_achievable
      t.text :smart_relevant
      t.text :smart_timebound
      
      t.integer :status, default: 1, null: false # 0: draft, 1: active, 2: paused, 3: completed
      t.date :target_date
      t.string :psychometric_focus # ex: "reality_testing", "assertiveness"
      
      t.timestamps
    end
  end
end
