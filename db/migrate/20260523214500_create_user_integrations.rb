class CreateUserIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_integrations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps
    end

    add_index :user_integrations, [ :provider, :uid ], unique: true
    add_index :user_integrations, [ :user_id, :provider ], unique: true
  end
end
