module Api
  class PingController < BaseController
    skip_before_action :authenticate

    def index
      render json: { ping: true }
    end
  end
end
