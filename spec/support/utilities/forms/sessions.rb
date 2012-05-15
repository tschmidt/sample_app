module Utilities
  module Forms
    module Sessions
      
      def fill_out_sign_up_form
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end
      
      def fill_out_sign_in_form(user)
        fill_in "Email",    with: user.email
        fill_in "Password", with: user.password
      end
      
      def sign_in(user)
        visit signin_path
        fill_out_sign_in_form(user)
        click_button 'Sign in'
        cookies[:remember_token] = user.remember_token
      end
      
    end
  end
end