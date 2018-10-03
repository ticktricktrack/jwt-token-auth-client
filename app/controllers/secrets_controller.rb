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
  token = JWT.decode request.headers["Authorization"], 'foo'
  raise NopeError unless token.first["permissions"].include?(action_name)
end
