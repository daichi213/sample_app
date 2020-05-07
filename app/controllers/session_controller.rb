class SessionController < ApplicationController
  def new
    # debugger
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      # paramsに格納されている値はstring型なので、条件式は引用符をつけることを忘れない
      # 数字で比較してしまうと、trueのときの処理が実行されない
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      redirect_back_or @user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
