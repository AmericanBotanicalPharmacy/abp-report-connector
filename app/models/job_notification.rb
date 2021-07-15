class JobNotification < ApplicationRecord
  belongs_to :spreadsheet_job
  belongs_to :spreadsheet

  before_destroy :remove_in_sidekiq_cron

  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  def emails_to_notify
    _emails = emails || ''
    _emails_array = _emails.split(',').map(&:strip)

    _emails_array.select{ |e| e =~ EMAIL_REGEX }
  end

  def phones_to_notify
    _phones = phones || ''
    _phones.split(',').map(&:strip)
  end

  def update_sidekiq_cron
    return if cron.blank?
    Sidekiq::Cron::Job.load_from_hash({
      sidekiq_cron_name(name) => {
        'class' => 'JobNotificationWorker',
        'cron' => cron,
        'args' => [id]
      }
    })
  end

  def remove_in_sidekiq_cron
    Sidekiq::Cron::Job.destroy sidekiq_cron_name
  end

  def sidekiq_cron_name
    "job-#{spreadsheet_job.id}-notification-#{id}"
  end
end
