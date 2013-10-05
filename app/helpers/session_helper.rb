module SessionHelper
  def signed_in?
    !session[:uid].nil?
  end

  def sign_in(uid) 
    session[:uid] = uid
  end

  def sign_out
    session[:uid] = nil
  end

  def save_current_user(user) 
    session[:user] = user
  end

  def current_user
    session[:user]
  end
end
