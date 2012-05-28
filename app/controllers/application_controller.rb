class ApplicationController < ActionController::Base
  layout 'admin'
  protect_from_forgery
  before_filter :basic_authenticate ,:except => [:mapa,:index,:show]

  private
  def basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username=="aceitoso" && password=="aceitoso"
    end
  end
end
