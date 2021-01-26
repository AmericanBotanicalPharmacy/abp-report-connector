module Api
  class MessagesController < BaseController
    def deliver
      res = MessageHandler.new(params).deliver
      if res.status_code.to_i == 202
        render json: { success: true }
      else
        render json: { error: res.body }
      end
    end
  end
end
