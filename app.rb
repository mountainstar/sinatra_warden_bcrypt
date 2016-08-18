require 'bundler'
require 'sinatra'
require 'sinatra/reloader'
require 'dm-core'
require 'dm-migrations'
require 'json'
require 'dm-validations'
require 'dm-types'
Bundler.require


#models
require_relative 'models/signup.rb'

#routes
require_relative 'routes/signup.rb'
require_relative 'routes/proteced.rb'






  Warden::Strategies.add(:password) do
    def valid?
      params['user'] && params['user']['username'] && params['user']['password']
    end

    def authenticate!
      user = User.first(username: params['user']['username'])

      if user.nil?
        throw(:warden, message: "The username you entered does not exist.")
      elsif user.authenticate(params['user']['password'])
        success!(user)
      else
        throw(:warden, message: "The username and password combination ")
      end
    end

  end

  Warden::Strategies.add(:admin) do

  def valid?
    params['admin']
  end


    def authenticate!
      u = User.get(admin: params['admin'])

     if u.nil?
         throw(:warden, message: "You do not have access to this page" )
     elsif u.authenticate(params['admin'])
       success!(u)
    end


    end

end

  class App < Sinatra::Application

    configure do
      enable :sessions
    end

      register Sinatra::Flash
      set :session_secret, "supersecret"

      use Warden::Manager do |config|
        # Tell Warden how to save our User info into a session.
        # Sessions can only take strings, not Ruby code, we'll store
        # the User's `id`
        config.serialize_into_session{|user| user.id  }
        # Now tell Warden how to take what we've stored in the session
        # and get a User from that information.
        config.serialize_from_session{|id| User.get(id) }

        config.scope_defaults :default,
                              # "strategies" is an array of named methods with which to
                              # attempt authentication. We have to define this later.
                              strategies: [:password],
                              # The action is a route to send the user to when
                              # warden.authenticate! returns a false answer. We'll show
                              # this route below.
                              action: 'auth/unauthenticated'


        # When a user tries to log in and cannot, this specifies the
        # app to send the user to.
        config.failure_app = self

        config.scope_defaults :admin, :strategies => [:admin]
      end

      Warden::Manager.before_failure do |env,opts|
        # Because authentication failure can happen on any request but
        # we handle it only under "post '/auth/unauthenticated'", we need
        # to change request to POST
        env['REQUEST_METHOD'] = 'POST'
        # And we need to do the following to work with  Rack::MethodOverride
        env.each do |key, value|
          env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
        end
      end


      get '/' do
        @user = User.find(session[:id])
        @admin = User.find(session[:admin])
        redirect '/auth/login'
      end

      helpers do
        def admin?
          env['warden'].user.admin
        end
        def user?
          env['warden'].authenticate
        end
      end


end




