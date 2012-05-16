require 'spec_helper'

describe "Authentication" do
  subject { page }
  
  describe "signin page" do
    before { visit signin_path }
    
    it { should have_main_heading('Sign in') }
    it { should have_page_title('Sign in') }
  end
  
  describe 'page links' do
    describe 'as signed-in user' do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }
      
      it { should have_page_link(text: 'Users', href: users_path) }
      it { should have_page_link(text: "Profile", href: user_path(user)) }
      it { should have_page_link(text: "Settings", href: edit_user_path(user)) }
      it { should have_page_link(text: "Sign out", href: signout_path) }
      it { should_not have_page_link(text: 'Sign in', href: signin_path) }
    end
    
    describe 'as a non-signed-in user' do
      let(:user) { FactoryGirl.create(:user) }
      before { visit root_path }
      
      it { should_not have_page_link(text: 'Users', href: users_path) }
      it { should_not have_page_link(text: "Profile", href: user_path(user)) }
      it { should_not have_page_link(text: "Settings", href: edit_user_path(user)) }
      it { should_not have_page_link(text: "Sign out", href: signout_path) }
      it { should have_page_link(text: 'Sign in', href: signin_path) }
    end
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
      
      before { sign_in user }
      
      it { should have_page_title(user.name) }
      
      describe "followed by signout" do
        before { click_link("Sign out") }
        it { should have_link("Sign in") }
      end
    end
  end
  
  describe 'authorization' do
    describe 'for non-signed-in users' do
      let(:user) { FactoryGirl.create(:user) }
      
      describe 'in the Users controller' do
        describe 'visiting the user index' do
          before { visit users_path }
          it { should have_page_title('Sign in') }
        end
      end
      
      describe 'when attempting to visit a protected page' do
        before do
          visit edit_user_path(user)
          fill_out_sign_in_form(user)
          click_button "Sign in"
        end
        
        describe 'after signing in' do
          it "should render the desired protected page" do
            page.should have_page_title(full_title('Edit user'))
          end
          
          describe 'when signing in again' do
            before do
              visit signin_path
              fill_out_sign_in_form(user)
              click_button 'Sign in'
            end
            
            it 'should render the default (profile) page' do
              page.should have_page_title(user.name)
            end
          end
        end
      end
      
      describe 'as non-admin user' do
        let(:user) { FactoryGirl.create(:user) }
        let(:non_admin) { FactoryGirl.create(:user) }
        
        before { sign_in non_admin }
        
        describe 'submitting a DELETE request to the Users#destroy action' do
          before { delete user_path(user) }
          specify { response.should redirect_to(root_path) }
        end
      end
    end
    
    describe 'as wrong user' do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, name: 'Other User', email: 'wrong@example.com') }
      
      before { sign_in user }
      
      describe 'visiting Users#edit page' do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_page_title(full_title('Edit user')) }
      end
      
      describe 'submitting a PUT request to the Users#update action' do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end
  end
end
