module Api
  class SpreadsheetsController < BaseController
    def update
      current_user.spreadsheets.find_or_create_by(g_id: params[:g_id])
      render json: { success: true }
    end

    def sync
      spreadsheet = current_user.spreadsheets.find_or_initialize_by(g_id: params[:g_id])
      if spreadsheet.update(name: params[:name])
        SyncSpreadsheetWorker.new.perform(spreadsheet.id)
        render json: { success: true }
      else
        render json: { error: spreadsheet.errors.full_messages.join(', ') }
      end
    end
  end
end
