module Api
  class SpreadsheetsController < BaseController
    def update
      current_user.spreadsheets.find_or_create_by(g_id: params[:g_id])
      render json: { success: true }
    end
  end
end
