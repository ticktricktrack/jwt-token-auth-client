Rails.application.routes.draw do
  get '/mich', to: 'secrets#mich'
  get '/denes', to: 'secrets#denes'
  get '/rainer', to: 'secrets#rainer'
end
