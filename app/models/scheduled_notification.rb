class ScheduledNotification < ApplicationRecord
  belongs_to :spreadsheet
  belongs_to :spreadsheet_job
end
