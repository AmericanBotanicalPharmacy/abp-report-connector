module Api
  class DbController < BaseController
    def run
      database_source = if params[:id]
        DatabaseSource.find_by(uuid: params[:id])
      else
        DatabaseSource.new(database_source_params)
      end
      if database_source.persisted? && params[:source] && database_source_params.present?
        database_source.assign_attributes(database_source_params)
      end
      database_url = database_source.generate_database_url
      if database_url.blank?
        render json: { error: 'DB not available' }, status: :bad_request
        return
      end
      render json: SqlExecutor.new(database_url, params[:sql]).execute
    rescue => e
      render json: {
        error: (database_source.password.present? ? e.message.to_s.gsub("#{database_source.password}", '******') : e.message)
      }, status: :bad_request
    end

    def database_source_params
      params.require(:source).permit(:uuid, :host, :username, :password, :port, :database, :db_type).each {|key, value| value.try(:strip!) }
    end
  end
end
