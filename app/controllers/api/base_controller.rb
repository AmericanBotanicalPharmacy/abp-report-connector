class Api::BaseController < ActionController::API
  before_action :authenticate_auth_token!
  before_action :authenticate_id_token!

  helper_method :current_user

  private

  def authenticate_auth_token!
    unless request.headers['Authorization'].present? &&
      ActiveSupport::SecurityUtils.secure_compare(request.headers['Authorization'], "Token token=#{ENV['TOKEN']}")
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def authenticate_id_token!
    if current_user == nil
      render json: { error: 'Invalid user' }, status: :unauthorized
    end
  end

  def current_user
    @current_user ||= User.find_by_id_token(request.headers['ID_TOKEN'])
  end
end
