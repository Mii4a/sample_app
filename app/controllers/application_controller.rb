class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  render html: "Hello"
end
