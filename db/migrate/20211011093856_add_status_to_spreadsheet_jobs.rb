class AddStatusToSpreadsheetJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :spreadsheet_jobs, :status, :string
  end
end
