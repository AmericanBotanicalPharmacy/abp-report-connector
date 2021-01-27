module Api
  class MessagesController < BaseController
    def deliver
      MessageHandler.new(params).deliver
      render json: { success: true }
    end
  end
end
