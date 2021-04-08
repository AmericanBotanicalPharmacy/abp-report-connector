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
    result = SqlExecutor.new(database_url, job.sql)

    sw = SheetWraper.new(job.spreadsheet.user)
    unless sw.sheet_exists?(job.spreadsheet.g_id, job.target_sheet)
      sw.add_sheet(job.spreadsheet.g_id, job.target_sheet)
    end
    if job.replace_sheet?
      sw.clear_sheet(job.spreadsheet.g_id, job.target_sheet)
    end
    return if result.rows.length == 0
    data = job.replace_sheet? ? ([result.columns] + result.rows) : result.rows
    cw.append_data(data)
  end
end
