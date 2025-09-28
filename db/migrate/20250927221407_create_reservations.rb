class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :book, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :borrowed_on, null: false
      t.date :due_on
      t.datetime :returned_at

      t.timestamps
    end
  end
end
