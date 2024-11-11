require 'sinatra'
require 'json'
require_relative 'my_user_model'

set :port, 8080
set :bind, '0.0.0.0'
enable :sessions

user_model = User.new

get '/users' do
  users = user_model.all
  users.to_json
end

post '/users' do
  user_info = {
    firstname: params[:firstname],
    lastname: params[:lastname],
    age: params[:age],
    password: params[:password],
    email: params[:email]
  }
  user_id = user_model.create(user_info)
  user = user_model.find(user_id).reject { |k, _| k == :password }
  user.to_json
end

post '/sign_in' do
  user = user_model.all.find { |u| u[:email] == params[:email] && u[:password] == params[:password] }
  if user
    session[:user_id] = user[:id]
    user.reject { |k, _| k == :password }.to_json
  else
    status 401
    { error: 'Invalid email or password' }.to_json
  end
end

put '/users' do
  halt 401 unless session[:user_id]
  new_password = params[:password]
  user = user_model.update(session[:user_id], 'password', new_password).reject { |k, _| k == :password }
  user.to_json
end

delete '/sign_out' do
  session.clear
  status 204
end

delete '/users' do
  halt 401 unless session[:user_id]
  user_model.destroy(session[:user_id])
  session.clear
  status 204
end

