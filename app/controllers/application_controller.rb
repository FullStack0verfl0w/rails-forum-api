class ApplicationController < ActionController::API
    def not_found
        render json: {data:[session[:token]]}, status: :not_found
    end
end
