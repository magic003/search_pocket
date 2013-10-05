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

  def current_user
    User[:name => session[:uid]]
  end
end
