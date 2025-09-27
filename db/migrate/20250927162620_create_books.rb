class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title, null: false, index: true
      t.string :author, null: false, index: true
      t.integer :genre, null: false, index: true
      t.string :isbn, null: false, index: { unique: true }
      t.integer :total_copies, null: false, default: 1

      t.timestamps
    end
  end
end
