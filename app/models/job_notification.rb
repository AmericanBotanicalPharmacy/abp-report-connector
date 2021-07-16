class JobNotification < ApplicationRecord
  belongs_to :spreadsheet_job
  belongs_to :spreadsheet

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
end
