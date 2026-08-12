class CreateEqiProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :eqi_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :assessment_id
      t.integer :total_eq
      t.boolean :is_valid, default: true
      t.integer :happiness_score
      
      # 15 Subescalas Mapeadas Como Colunas Inteiras (Standard Scores 50-150)
      t.integer :self_regard_score
      t.integer :self_actualization_score
      t.integer :emotional_self_awareness_score
      t.integer :emotional_expression_score
      t.integer :assertiveness_score
      t.integer :independence_score
      t.integer :interpersonal_relationships_score
      t.integer :empathy_score
      t.integer :social_responsibility_score
      t.integer :problem_solving_score
      t.integer :reality_testing_score
      t.integer :impulse_control_score
      t.integer :flexibility_score
      t.integer :stress_tolerance_score
      t.integer :optimism_score
      
      t.datetime :imported_at
      t.timestamps
    end
  end
end
