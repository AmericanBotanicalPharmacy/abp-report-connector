require 'sheet_wraper'
require 'notification_deliverer'

class SpreadsheetJobWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: 3

  def perform(job_id)
    job = SpreadsheetJob.find_by id: job_id
    return if job.nil?
    return if job.status && job.status.strip.downcase == 'disabled'
    execute_job(job)
  end

  def execute_job(job)
    database_source = job.spreadsheet.user.sources.find_by(name: job.db_config)
    return if database_source.nil?
    database_url = database_source.generate_database_url
    return if database_url.blank?
    origin_result = SqlExecutor.new(database_url, job.sql).execute
    result = origin_result.clone
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
      NotificationDeliverer.new(
        notification: notification,
        data_count: data_count,
        sheet_wraper: sw,
        data: ([origin_result[:columns]] + origin_result[:result])
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
