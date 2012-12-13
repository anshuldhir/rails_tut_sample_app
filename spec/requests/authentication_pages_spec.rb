require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "signin page" do
    before { visit signin_path }
    let(:page_title) { 'Sign in' }
    let(:sign_in) { 'Sign in' }

    it { should have_selector('h1', text: page_title) }
    it { should have_selector('title', text: full_title(page_title)) }

    describe "with invalid information" do
      describe "after submission" do
        before { click_button sign_in }

        it { should have_selector('title', text: page_title) }
        it { should have_error_message('Invalid') }
        
        describe "after visiting another page" do
          before { click_link 'Home' }

          it { should_not have_selector('div.alert.alert-error') }
        end        
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        valid_signin(user)
      end

      it { should have_selector('title', text: user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link 'Sign out' }

        it { should have_link('Sign in') }
      end
    end    
  end
end
