
class App < Sinatra::Application
  get '/protect/protect' do
    env['warden'].authenticate!
    @user = User.get(params[:id])
    erb :'protect/protect'
  end

  get '/protect/protected' do
    env['warden'].authenticate!
    erb :'protect/protected'
  end


end
