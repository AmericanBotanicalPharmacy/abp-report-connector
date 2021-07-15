require 'sheet_wraper'

class SyncSpreadsheetsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    User.find_each do |user|
      i = 0
      user.spreadsheets.find_each do |spreadsheet|
        i += 10
        SyncSpreadsheetWorker.perform_in(i.seconds, spreadsheet.id)
      end
    end
  end
end
