class Api::BaseController < ActionController::API
  TOKEN = "150486c440e77501633822a4b"

  before_action :authenticate

  private

  def authenticate
    unless request.headers['Authorization'].present? &&
      ActiveSupport::SecurityUtils.secure_compare(request.headers['Authorization'], "Token token=#{TOKEN}")
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
end
