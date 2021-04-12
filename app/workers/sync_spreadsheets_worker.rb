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

        notification_values = sw.fetch_sheet_data(spreadsheet.g_id, 'Notifications!A2:F20')
        notification_values.each_with_index do |notification_row, index|
          job_notification = spreadsheet.job_notifications.find_or_initialize_by(row_index: index)
          job = spreadsheet.spreadsheet_jobs.find_by(name: notification_row[0])
          next if job.nil?
          job_notification.update(
            spreadsheet_job: job,
            notify_type: notification_row[1],
            row_number: notification_row[2],
            emails: notification_row[3],
            phones: notification_row[4],
            message: notification_row[5]
          )
        end
        spreadsheet.job_notifications.where('row_index > ?', notification_values.count).destroy_all
      end
    end
  end
end
