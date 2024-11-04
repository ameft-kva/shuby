class Madmin::User::ImpersonatesController < Madmin::ApplicationController
  def create
    user = ::User.find(params[:user_id])
    impersonate_user(user)
    redirect_to root_path
  end

  def destroy
    user = current_user
    stop_impersonating_user
    redirect_to madmin_user_path(user)
  end
end
