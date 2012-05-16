require 'spec_helper'

describe "User pages" do
  subject { page }
  
  shared_examples_for 'a page that redirects signed in users' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      test_action
    end
    
    specify { response.should redirect_to(root_path) }
  end
  
  describe 'index' do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      sign_in user
      visit users_path
    end
    
    it { should have_page_title('All users') }
    
    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }
      
      let(:first_page) { User.order('name ASC').paginate(page: 1) }
      let(:second_page) { User.order('name ASC').paginate(page: 2) }
      
      it { should have_link('Next') }
      its(:html) { should match('>2</a>') }
      
      it "should list the first page of users" do
        first_page.each do |user|
          page.should have_selector('li', text: user.name)
        end
      end

      it "should not list the second page of users" do
        second_page.each do |user|
          page.should_not have_selector('li', text: user.name)
        end
      end

      describe "showing the second page" do
        before { visit users_path(page: 2) }

        it "should list the second page of users" do
          second_page.each do |user|
            page.should have_selector('li', text: user.name)
          end
        end
      end
      
      it "should list each user" do
        User.all[0..2].each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end
    
    describe 'delete links' do
      it { should_not have_link('delete') }
      
      describe 'as an admin' do
        let(:admin) { FactoryGirl.create(:admin) }
        
        before do
          sign_in admin
          visit users_path
        end
        
        it { should have_link('delete', href: user_path(User.first)) }
        
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end # end of 'index'
  
  describe "signup page" do
    before { visit signup_path}
    
    it { should have_main_heading('Sign up') }
    it { should have_page_title(full_title('Sign up')) }
    
    it_should_behave_like 'a page that redirects signed in users' do
      let(:test_action) { get signup_path }
    end
    
    describe 'create' do
      it_should_behave_like 'a page that redirects signed in users' do
        let(:test_action) { post users_path }
      end
    end
  end # end of 'signup'
  
  describe "show page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    
    it { should have_main_heading(user.name) }
    it { should have_page_title(user.name) }
  end # end of 'show'
  
  describe "signup" do
    before { visit signup_path }
    let(:submit) { "Create my account" }
    
    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end
    
    describe "with valid information" do
      before do
        fill_out_sign_up_form
      end
      
      it "should create a user" do
        expect { click_button submit }.to change(User, :count)
      end
      
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }
        
        it { should have_page_title(user.name) }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end # end of 'signup'
  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit signin_path
      sign_in user
      visit edit_user_path(user)
    end
    
    describe "page" do
      it { should have_main_heading("Update your profile") }
      it { should have_page_title("Edit user") }
      it { should have_page_link(title: 'change', href: 'http://gravatar.com/emails') }
    end
    
    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content('error') }
    end
    
    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end
      
      it { should have_page_title(new_name) }
      it { should have_success_message }
      it { should have_page_link(title: "Sign out", href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end # end of 'edit'
  
  describe 'UsersController#destroy' do
    describe 'as an admin' do
      let(:admin) { FactoryGirl.create(:admin) }
      before do
        sign_in admin
        delete user_path(admin)
      end
      
      specify { response.should redirect_to(user_path(admin)) }
    end
  end
end
