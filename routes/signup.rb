


class App < Sinatra::Application
  def find_users
    @users = User.all
  end

  def find_user
    User.get(params[:id])
  end

  def create_user
    @user = User.create(params[:user])
    @user.save!
  end

  def delete_user
    User.delete
  end


  get '/users/home' do
    erb :'users/home'
  end


  get '/registrations/signup' do
    @user = User.new
    erb :'registrations/signup'
  end


  post '/registrations' do
    create_user
    if @user.save
    env['warden'].authenticate!
    flash[:success] = "Successfully created account"
    redirect '/protect/protected'
    else
      flash[:error] =  "something went wrong"
      redirect '/registrations/signup'
    end

  end

  get '/auth/login' do
    erb :'users/login'
  end

  post '/auth/login' do
    env['warden'].authenticate!
    flash[:success] = "Successfully logged in"
    redirect '/users/home'
    if session[:return_to].nil?
    else
      redirect session[:return_to]
    end
  end

  get '/auth/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash[:success] = 'Successfully logged out'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?

    # Set the error and use a fallback if the message is not defined
    flash[:error] = env['warden.options'][:message] || "You must log in"
    redirect '/auth/login'
  end

  get '/protected' do
    env['warden'].authenticate!
    erb :protected
  end



  get '/sessions/users' do
     permission = env['warden'].user.admin
    if permission == false
      flash[:error] = "You do not have permission to view this page"
      redirect '/protect/protected'
    elsif
    users = User.all
      erb :'sessions/users', :local => { :users => users }
    end
  end

  get '/sessions/user/:id' do
    user = find_user
    if user.nil?
      flash[:success] = 'There are no users'
      redirect '/'
      else

    erb :'/sessions/user/:id', :local => { :user => user }
    end
  end

 delete '/sessions/user/:id' do
   if find_user.destroy
     env['warden'].raw_session.inspect
     env['warden'].logout
     flash[:success] = "User deleted Successfully"
   end
   redirect :'/sessions/users'
 end
end

