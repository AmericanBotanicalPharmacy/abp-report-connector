class SpreadsheetJob < ApplicationRecord
  belongs_to :spreadsheet
  has_many :job_notifications

  before_destroy :remove_in_sidekiq_cron
  before_update :remove_old_sideiq_job, if: -> { name_changed? }

  def update_sidekiq_cron
    return if cron.blank?
    Sidekiq::Cron::Job.load_from_hash({
      sidekiq_cron_name(name) => {
        'class' => 'SpreadsheetJobWorker',
        'cron' => cron,
        'args' => [id],
        'description' => sidekiq_description
      }
    })
  end

  def remove_in_sidekiq_cron
    Sidekiq::Cron::Job.destroy sidekiq_cron_name
  end

  def sidekiq_cron_name(_name)
    "user-#{spreadsheet.user_id}-job-#{id}-#{_name}"
  end

  def remove_old_sideiq_job
    job_name = sidekiq_cron_name(name_was)
    old_job = Sidekiq::Cron::Job.find(job_name)
    old_job ||= Sidekiq::Cron::Job.find("user-#{spreadsheet.user_id}-job-#{id}")
    old_job.destroy if old_job
  end

  def cron
    JSON.parse(options)['cron']
  rescue
    nil
  end

  def sidekiq_description
    "Doc: #{target_sheet} \n Job: #{name}"
  end

  def replace_sheet?
    JSON.parse(options)['renderType'] == 'replace'
  rescue
    false
  end
end
