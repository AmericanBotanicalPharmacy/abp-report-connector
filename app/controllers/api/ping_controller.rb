module Api
  class PingController < BaseController
    def index
      render json: { ping: true }
    end
  end
end
