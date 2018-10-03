class NopeError < StandardError;end

class SecretsController < ApplicationController
  before_action :authenticate

  def mich
  end

  def denes
  end

  def rainer
  end
end

private

def authenticate
  # token = request.headers["Authorization"]
  token_string = cookies[:auth]
  token = JWT.decode token_string, 'secret'
  raise NopeError unless token.first["email"].include?(action_name)
rescue
  redirect_to "http://localhost:8000?redirect=#{request.original_url}"
end
