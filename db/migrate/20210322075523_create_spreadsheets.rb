class CreateSpreadsheets < ActiveRecord::Migration[6.0]
  def change
    create_table :spreadsheets do |t|
      t.string :g_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
