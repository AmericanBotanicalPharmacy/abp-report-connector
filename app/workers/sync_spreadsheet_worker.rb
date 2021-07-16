require 'sheet_wraper'

class SyncSpreadsheetWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(spreadsheet_id)
    spreadsheet = Spreadsheet.find(spreadsheet_id)
    sync(spreadsheet)
  end

  def sync(spreadsheet)
    user = spreadsheet.user
    sw = SheetWraper.new(user)
    values = sw.fetch_sheet_data(spreadsheet.g_id, 'Jobs!A1:E20')
    transform_values(values).each_with_index do |job_row, index|
      job = spreadsheet.spreadsheet_jobs.find_or_initialize_by(row_number: index)
      job.update(
        name: job_row['NAME'],
        sql: job_row['SQL'],
        target_sheet: job_row['TARGET SHEET'],
        db_config: job_row['DB_CONFIG'],
        options: job_row['OPTIONS']
      )
      job.update_sidekiq_cron
    end
    spreadsheet.spreadsheet_jobs.where('row_number > ?', values.count).destroy_all

    notification_values = sw.fetch_sheet_data(spreadsheet.g_id, 'Notifications!A1:F20')
    transform_values(notification_values).each_with_index do |notification_row, index|
      job_notification = spreadsheet.job_notifications.find_or_initialize_by(row_index: index)
      job = spreadsheet.spreadsheet_jobs.find_by(name: notification_row['JOB'])
      next if job.nil?
      job_notification.update(
        spreadsheet_job: job,
        notify_type: notification_row['NOTIFY_TYPE'],
        row_number: notification_row['ROW_NUMBER'],
        emails: notification_row['EMAILs'],
        phones: notification_row['PHONEs'],
        message: notification_row['MESSAGE']
      )
    end
    spreadsheet.job_notifications.where('row_index > ?', notification_values.count).destroy_all

    scheduled_notification_values = sw.fetch_sheet_data(spreadsheet.g_id, 'Scheduled Notifications!A1:E20')
    transform_values(scheduled_notification_values).each_with_index do |scheduled_notification_row, index|
      scheduled_notification = spreadsheet.scheduled_notifications.find_or_initialize_by(row_index: index)
      job = spreadsheet.spreadsheet_jobs.find_by(name: scheduled_notification_row['JOB'])
      next if job.nil?
      scheduled_notification.update(
        spreadsheet_job: job,
        emails: scheduled_notification_row['EMAILs'],
        phones: scheduled_notification_row['PHONEs'],
        message: scheduled_notification_row['MESSAGE']
      )
    end
    spreadsheet.scheduled_notifications.where('row_index > ?', scheduled_notification_values.count).destroy_all
  end

  def transform_values(values)
    headers = values[0]
    transformed_values = []
    values[1..-1].each do |v|
      datum = {}
      headers.each_with_index do |header, index|
        datum[header] = v[index]
      end
      transformed_values << datum
    end
    transformed_values
  end
end