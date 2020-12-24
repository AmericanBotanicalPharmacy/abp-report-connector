module Api
  class DbController < BaseController
    def run
      conn = DbConnectionFactory.create(params[:database_url])
      result = conn.exec_query(params[:sql])
      if conn.is_a?(ActiveRecord::ConnectionAdapters::SQLServerAdapter)
        if result.count > 0
          columns = result[0].keys
          result = result.map { |r| columns.map { |c| r[c]} }
          render json: {
            result: result,
            columns: columns
          }
        else
          render json: {
            result: [],
            columns: []
          }
        end
      else
        render json: {
          result: result.rows,
          columns: result.columns
        }
      end
    end
  end
end