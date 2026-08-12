class CreateMbtiProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :mbti_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :assessment_id
      t.string :final_type, null: false # ex: "INTJ"
      t.string :temperament_group       # ex: "Analistas"
      t.string :temperament_code        # ex: "NT"
      
      # Vencedor e Clareza das Dicotomias
      t.string :ei_winner
      t.decimal :ei_pci, precision: 5, scale: 2
      t.string :sn_winner
      t.decimal :sn_pci, precision: 5, scale: 2
      t.string :tf_winner
      t.decimal :tf_pci, precision: 5, scale: 2
      t.string :jp_winner
      t.decimal :jp_pci, precision: 5, scale: 2
      
      # Hierarquia das Funções Cognitivas
      t.string :dominant_function  # ex: "Ni"
      t.string :auxiliary_function # ex: "Te"
      t.string :tertiary_function  # ex: "Fi"
      t.string :inferior_function  # ex: "Ne"
      
      t.datetime :imported_at
      t.timestamps
    end
  end
end
