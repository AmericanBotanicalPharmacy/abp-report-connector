module Api
  class SourcesController < BaseController
    def create
      @source = DatabaseSource.new(source_params)
      if @source.save
        render json: {
          success: true
        }
      else
        render json: {
          error: @source.errors.full_messages.join(',')
        }, status: :bad_request
      end
    end

    def update
      @source = DatabaseSource.find_by(uuid: params[:id])
      if @source.update(source_params)
        render json: {
          success: true
        }
      else
        render json: {
          error: @source.errors.full_messages.join(',')
        }, status: :bad_request
      end
    end

    def destroy
      @source = DatabaseSource.find_by(uuid: params[:id])
      if @source
        @source.destroy
        render json: { success: true }
      else
        render json: {
          error: 'Source not found'
        }, status: :bad_request
      end
    end

    def source_params
      params.require(:source).permit(:uuid, :host, :username, :password, :port, :database, :db_type)
    end
  end
end
