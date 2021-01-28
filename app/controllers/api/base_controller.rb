class Api::BaseController < ActionController::API
  before_action :authenticate

  private

  def authenticate
    unless request.headers['Authorization'].present? &&
      ActiveSupport::SecurityUtils.secure_compare(request.headers['Authorization'], "Token token=#{ENV['TOKEN']}")
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
end
