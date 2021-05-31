require 'sheet_wraper'

class SyncSpreadsheetsWorker
  include Sidekiq::Worker

  def perform
    User.find_each do |user|
      user.spreadsheets.find_each do |spreadsheet|
        SyncSpreadsheetWorker.new.sync(spreadsheet)
      end
    end
  end
end
