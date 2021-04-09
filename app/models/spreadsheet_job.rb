class SpreadsheetJob < ApplicationRecord
  belongs_to :spreadsheet
  has_many :job_notifications

  before_destroy :remove_in_sidekiq_cron

  def update_sidekiq_cron
    return if cron.blank?
    sidekiq_cron_name
    Sidekiq::Cron::Job.load_from_hash({
      sidekiq_cron_name => {
        'class' => 'SpreadsheetJobWorker',
        'cron' => cron,
        'args' => [id]
      }
    })
  end

  def remove_in_sidekiq_cron
    Sidekiq::Cron::Job.destroy sidekiq_cron_name
  end

  def sidekiq_cron_name
    "spreadsheet-#{spreadsheet_id}-job-#{row_number}"
  end

  def cron
    JSON.parse(options)['cron']
  rescue
    nil
  end

  def replace_sheet?
    JSON.parse(options)['renderType'] == 'replace'
  rescue
    false
  end
end
