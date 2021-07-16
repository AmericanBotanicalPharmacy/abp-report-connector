class CreateScheduledNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :scheduled_notifications do |t|
      t.references :spreadsheet, null: false, foreign_key: true
      t.references :spreadsheet_job, null: false, foreign_key: true
      t.string :emails
      t.string :phones
      t.string :message
      t.string :cron
      t.integer :row_index

      t.timestamps
    end
  end
end
