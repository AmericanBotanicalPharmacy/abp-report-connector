require 'sheet_wraper'

class NotificationDeliverer
  attr_accessor :notification, :job, :spreadsheet, :sheet_wraper, :data_count, :data

  def initialize(attrs={})
    @notification = attrs[:notification]
    @spreadsheet = @notification.spreadsheet
    @data_count = attrs[:data_count]
    @sheet_wraper = attrs[:sheet_wraper] || SheetWraper.new(@spreadsheet.user)
    @data = attrs[:data]
    @job = @notification.spreadsheet_job
  end

  VALUE_REGEX = /\![A-Z]{1,}\d{1,}(?:\:[A-Z]{1,}\d{1,})?/

  def deliver
    return if data_count == 0 && notification.notify_type == 'new_data'
    return if notification.notify_type == 'number_data' && data_count < notification.row_number

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
      data.each do |r|
        csv << r
      end
    end
    MessageHandler.new(
      subject: subject,
      recipients: emails,
      phones: phones,
      content: content,
      ss_id: job.spreadsheet.g_id,
      oauth_token: job.spreadsheet.user.google_token,
      sheet_name: job.target_sheet,
      csv_data: csv_string
    ).deliver
  end
end
