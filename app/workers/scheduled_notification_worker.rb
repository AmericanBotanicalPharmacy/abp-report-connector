require 'sheet_wraper'
require 'notification_deliverer'

class ScheduledNotificationWorker
  include Sidekiq::Worker

  def perform(scheduled_notification_id)
    notification = ScheduledNotification.find(scheduled_notification_id)
    sw = SheetWraper.new(notification.spreadsheet.user)
    res = sw.get_values(notification.spreadsheet.g_id, notification.spreadsheet_job.target_sheet)
    data = res.first.values || []
    NotificationDeliverer.new({
      notification: notification,
      data_count: data.length,
      data: data
    }).deliver
  end
end
