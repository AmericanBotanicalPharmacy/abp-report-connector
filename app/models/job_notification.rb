class JobNotification < ApplicationRecord
  belongs_to :spreadsheet_job
  belongs_to :spreadsheet
end
