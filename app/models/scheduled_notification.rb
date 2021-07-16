class ScheduledNotification < ApplicationRecord
  belongs_to :spreadsheet
  belongs_to :spreadsheet_job

  before_destroy :remove_in_sidekiq_cron

  def update_sidekiq_cron
    return if cron.blank?
    Sidekiq::Cron::Job.load_from_hash({
      sidekiq_cron_name => {
        'class' => 'ScheduledNotificationWorker',
        'cron' => cron,
        'args' => [id],
      }
    })
  end

  def sidekiq_cron_name
    "user-#{spreadsheet.user_id}-notification-#{id}"
  end

  def remove_in_sidekiq_cron
    Sidekiq::Cron::Job.destroy sidekiq_cron_name
  end
end
