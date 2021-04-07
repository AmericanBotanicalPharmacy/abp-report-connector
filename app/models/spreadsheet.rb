class Spreadsheet < ApplicationRecord
  belongs_to :user

  has_many :spreadsheet_jobs
end
