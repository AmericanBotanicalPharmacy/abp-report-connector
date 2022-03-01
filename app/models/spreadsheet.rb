class Spreadsheet < ApplicationRecord
  belongs_to :user

  has_many :spreadsheet_jobs
  has_many :job_notifications
  has_many :scheduled_notifications

  validates_presence_of :g_id, :name
end
