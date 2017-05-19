class CreateInscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :inscriptions do |t|
      t.references :user, foreign_key: true
      t.references :tournament, foreign_key: true
      t.integer :present_position
      t.integer :present_round
      t.integer :score

      t.timestamps
    end
  end
end
