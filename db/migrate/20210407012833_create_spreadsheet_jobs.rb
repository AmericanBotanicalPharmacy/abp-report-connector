class CreateSpreadsheetJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :spreadsheet_jobs do |t|
      t.references :spreadsheet, null: false, foreign_key: true
      t.integer :row_number
      t.text :sql
      t.string :name
      t.string :target_sheet
      t.string :db_config
      t.text :options

      t.timestamps
    end
  end
end
