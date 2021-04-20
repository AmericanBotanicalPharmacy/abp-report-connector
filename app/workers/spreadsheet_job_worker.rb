require 'sheet_wraper'

class SpreadsheetJobWorker
  include Sidekiq::Worker

  def perform(job_id)
    job = SpreadsheetJob.find_by id: job_id
    return if job.nil?
    execute_job(job)
  end

  VALUE_REGEX = /\![A-Z]{1,}\d{1,}(?:\:[A-Z]{1,}\d{1,})?/

  def execute_job(job)
    database_source = job.spreadsheet.user.sources.find_by(name: job.db_config)
    return if database_source.nil?
    database_url = database_source.generate_database_url
    return if database_url.blank?
    result = SqlExecutor.new(database_url, job.sql).execute
    prepend_timestamp(result)

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
      content = if notification.message.blank?
        "Your sheet (#{job.target_sheet}) have been updated by job: #{job.name}"
      else
        if notification.message =~ VALUE_REGEX
          values = sw.get_values(job.spreadsheet.g_id, notification.message.scan(VALUE_REGEX).map{|range| "#{job.target_sheet}#{range}"})
          _message = notification.message.clone
          values.each do |value_range|
            _values = value_range.values.flatten.join(' ') rescue ''
            _message = _message.gsub("!#{value_range.range.split('!').last}", _values)
          end
          _message
        else
          notification.message
        end
      end
      emails = notification.emails_to_notify
      phones = notification.phones_to_notify
      sheet_name = job.target_sheet
      csv_string = CSV.generate do |csv|
        ([result[:columns]] + result[:result]).each do |r|
          csv << r
        end
      end
      MessageHandler.new(
        subject: subject,
        recipients: emails,
        phones: phones,
        content: content,
        ss_id: job.spreadsheet.g_id,
        sheet_id: sheet_id,
        oauth_token: job.spreadsheet.user.google_token,
        sheet_name: job.target_sheet,
        csv_data: csv_string
      ).deliver
    end
  end

  def prepend_timestamp(result)
    if result[:result].length > 0
      result[:columns] = ['Timstamp'] + result[:columns]
      result[:result].each_with_index do |item, i|
        if i == 0
          item.unshift(Time.zone.now.strftime('%F %H:%M:%S'))
        else
          item.unshift('')
        end
      end
    end
  end
end
