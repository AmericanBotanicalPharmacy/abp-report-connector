module Api
  class UsersController < BaseController
    def me
      render json: { email: current_user.email, name: current_user.name, sub: current_user.sub }
    end
  end
end
