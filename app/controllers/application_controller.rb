class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :http_basic_authenticate

  def http_basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "user" && password == "password"
    end
  end

end
