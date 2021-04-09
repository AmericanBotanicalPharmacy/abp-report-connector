require 'sheet_wraper'

class SpreadsheetJobWorker
  include Sidekiq::Worker

  def perform(job_id)
    job = SpreadsheetJob.find_by id: job_id
    return if job.nil?
    execute_job(job)
  end

  def execute_job(job)
    database_source = job.spreadsheet.user.sources.find_by(name: job.db_config)
    return if database_source.nil?
    database_url = database_source.generate_database_url
    return if database_url.blank?
    result = SqlExecutor.new(database_url, job.sql).execute

    sw = SheetWraper.new(job.spreadsheet.user)
    sheet_id = sw.sheet_id(job.spreadsheet.g_id, job.target_sheet)
    unless sheet_id
      sheet_id = sw.add_sheet(job.spreadsheet.g_id, job.target_sheet)
    end
    if job.replace_sheet?
      sw.clear_sheet(job.spreadsheet.g_id, job.target_sheet)
    end
    if result[:result].length > 0
      data = job.replace_sheet? ? ([result[:columns]] + result[:result]) : result[:result]
      sw.append_data(job.spreadsheet.g_id, "#{job.target_sheet}!A1", data)
    end

    data_count = result[:result].length
    job.job_notifications.each do |notification|
      next if data_count == 0 && notification.notify_type == 'new_data'
      next if notification.notify_type == 'number_data' && data_count < notification.row_number

      subject = "Sheet #{job.target_sheet} updated."
      content = "Your sheet (#{job.target_sheet}) have been updated by job: #{job.name}"
      emails = notification.emails_to_notify
      phones = notification.phones_to_notify
      sheet_name = job.target_sheet

      MessageHandler.new(
        subject: subject,
        recipients: emails,
        phones: phones,
        content: content,
        ss_id: job.spreadsheet.g_id,
        sheet_id: sheet_id,
        oauth_token: job.spreadsheet.user.google_token,
        sheet_name: job.target_sheet
      ).deliver
    end
  end

end
