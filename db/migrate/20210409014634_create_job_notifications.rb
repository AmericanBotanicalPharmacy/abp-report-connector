class CreateJobNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :job_notifications do |t|
      t.references :spreadsheet, null: false, foreign_key: true
      t.references :spreadsheet_job, null: false, foreign_key: true
      t.string :notify_type
      t.integer :row_index
      t.integer :row_number
      t.string :emails
      t.string :phones
      t.string :message

      t.timestamps
    end
  end
end
