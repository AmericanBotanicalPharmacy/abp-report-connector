module Api
  class SourcesController < BaseController
    def index
      user = find_user
      if user.nil?
        render json: {
          sources: []
        }
      else
        render json: [
          sources: user.sources.map(&:as_json)
        ]
      end
    end

    def create
      @source = DatabaseSource.new(source_params.merge(user: find_user))
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
      @source = DatabaseSource.find_or_initialize_by(uuid: params[:id])
      if @source.update(source_params.merge(user: find_user))
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
      params.require(:source).permit(:uuid, :host, :username, :password, :port, :database, :db_type).each {|key, value| value.try(:strip!) }
    end

    def find_user
      return nil if params[:email].blank?
      User.find_or_create_by(email: params[:email])
    end
  end
end
