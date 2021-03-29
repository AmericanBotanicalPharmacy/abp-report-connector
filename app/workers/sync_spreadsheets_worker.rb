require 'sheet_wraper'

class SyncSpreadsheetsWorker
  include Sidekiq::Worker

  def perform
    Spreadsheet.find_each do |spreadsheet|
      sw = SheetWraper.new(spreadsheet.user)
      values = sw.fetch_sheet_data(sw.g_id, 'Jobs!A2:E20')
      puts values.inspect
    end
  end
end
