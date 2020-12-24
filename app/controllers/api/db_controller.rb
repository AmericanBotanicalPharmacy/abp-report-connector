module Api
  class DbController < BaseController
    def run
      conn = DbConnectionFactory.create(params[:database_url])
      result = conn.exec_query(params[:sql])
      render json: {
        result: result.rows,
        columns: result.columns
      }
    end
  end
end