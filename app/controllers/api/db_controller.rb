module Api
  class DbController < BaseController
    def run
      database_source = if params[:id]
        DatabaseSource.find_by(uuid: params[:id])
      else
        DatabaseSource.new(database_source_params)
      end
      conn = DbConnectionFactory.create(database_source.generate_database_url)
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
    rescue => e
      render json: {
        error: e.message.to_s.gsub("#{database_source.password}", '******')
      }, status: :bad_request
    end

    def database_source_params
      params.require(:source).permit(:uuid, :host, :username, :password, :port, :database, :db_type).each {|key, value| value.strip! }
    end
  end
end