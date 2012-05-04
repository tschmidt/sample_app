require 'spec_helper'

describe "Authentication" do
  subject { page }
  
  describe "signin page" do
    before { visit signin_path }
    
    it { should have_main_heading('Sign in') }
    it { should have_page_title('Sign in') }
  end
  
  describe "signin" do
    before { visit signin_path }
    
    describe "with invalid information" do
      before { click_button "Sign in" }
      
      it { should have_page_title('Sign in') }
      it { should have_error_message }
      
      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_error_message }
      end
    end
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      
      before do
        fill_out_sign_in_form(user)
        click_button "Sign in"
      end
      
      it { should have_page_title(user.name) }
      it { should have_page_link(text: "Profile", href: user_path(user)) }
      it { should have_page_link(text: "Sign out", href: signout_path) }
      it { should_not have_page_link(text: 'Sign in', href: signin_path) }
      
      describe "followed by signout" do
        before { click_link("Sign out") }
        it { should have_link("Sign in") }
      end
    end
  end
end
