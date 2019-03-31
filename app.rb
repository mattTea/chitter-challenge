require "sinatra/base"
require "./lib/peep"
require "./lib/user"

class Chitter < Sinatra::Base
  get "/" do
    "Welcome to Chitter"
  end

  get "/peeps" do
    @peeps = Peep.all
    erb :"peeps/index"
  end

  get "/peeps/new" do
    erb :"peeps/new"
  end

  post "/peeps/new" do
    Peep.create(message: params[:message])
    redirect "/peeps"
  end

  get "/users" do
    @users = User.all
    erb :"users/index"
  end

  run! if app_file ==$0
end
