class CreateUserMatches < ActiveRecord::Migration[5.0]
  def change
    create_table :user_matches do |t|
      t.references :user, foreign_key: true, null: false
      t.references :match, foreign_key: true, null: false
      t.integer :vp
      #elo data is from before change
      t.integer :elo_general
      t.integer :elo_general_change, null: false, default: 0
      t.integer :elo_free
      t.integer :elo_free_change, null: false, default: 0
      t.integer :elo_tournament
      t.integer :elo_tournament_change, null: false, default: 0
      t.integer :tournament_point
      t.integer :victory_position
      t.boolean :validated, null: false, default: false

      t.timestamps
    end
  end
end
