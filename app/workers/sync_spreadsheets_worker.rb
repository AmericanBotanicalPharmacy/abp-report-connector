require 'sheet_wraper'

class SyncSpreadsheetsWorker
  include Sidekiq::Worker

  def perform
    User.find_each do |user|
      user.spreadsheets.find_each do |spreadsheet|
        sw = SheetWraper.new(user)
        values = sw.fetch_sheet_data(spreadsheet.g_id, 'Jobs!A2:E20')
        values.each_with_index do |job_row, index|
          job = spreadsheet.spreadsheet_jobs.find_or_initialize_by(row_number: index)
          job.update(
            name: job_row[0],
            sql: job_row[1],
            target_sheet: job_row[2],
            db_config: job_row[3],
            options: job_row[4]
          )
          job.update_sidekiq_cron
        end
        spreadsheet.spreadsheet_jobs.where('row_number > ?', values.count).destroy_all
      end
    end
  end
end
