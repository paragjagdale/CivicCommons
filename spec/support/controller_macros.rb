module ControllerMacros
  def login_admin
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in Factory.create(:admin)
  end

  def login_user
    @request.env["devise.mapping"] = Devise.mappings[:person]
    @user = Factory.create(:registered_user)
    sign_in @user
  end
end