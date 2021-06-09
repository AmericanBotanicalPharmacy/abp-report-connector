require 'sheet_wraper'

class SyncSpreadsheetsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    User.find_each do |user|
      user.spreadsheets.find_each do |spreadsheet|
        SyncSpreadsheetWorker.new.sync(spreadsheet)
      end
    end
  end
end
