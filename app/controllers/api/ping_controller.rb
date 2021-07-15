module Api
  class PingController < BaseController
    skip_before_action :authenticate_auth_token!
    skip_before_action :authenticate_id_token!

    def index
      render json: { ping: true }
    end
  end
end
