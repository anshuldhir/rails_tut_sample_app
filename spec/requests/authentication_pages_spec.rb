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
      
      it { should have_link('Users', href: users_path) }      
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link 'Sign out' }

        it { should have_link('Sign in') }
      end
    end    
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "when attempting to visit a protected page" do
          before do 
            visit edit_user_path(user)    # should take the unsigned user to signin page
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            click_button "Sign in"
          end

          describe "after signing in" do
            it "should render the desired protected page" do
              page.should have_selector('title', text: 'Edit user')
            end
          
            describe "when signing in again" do
              before do
                visit signin_path
                fill_in "Email", with: user.email
                fill_in "Password", with: user.password
                click_button "Sign in"
              end

              it "should render the default (profile) page" do
                page.should have_selector('title', text: user.name)
              end
            end 
          end
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before do 
            visit users_path    # should take the unsigned user to signin page
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            click_button "Sign in"
          end

          describe "after signing in" do
            it { should have_selector('title', text: 'All users') }
          end
        end

        describe "in the Microposts controller" do
          describe "submitting to the create action" do
            before { post microposts_path }
            specify { response.should redirect_to(signin_path) }
          end

          describe "submitting to the destroy action" do
            before { delete micropost_path(FactoryGirl.create(:micropost)) }
            specify { response.should redirect_to(signin_path) }
          end
        end
      end

      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { response.should redirect_to(signin_path) }
        end

        # There is no relationship with index 1 in the relationships table.
        # But, it doesn't matter. The controller should redirect before 
        # any attempt is made to retrieve the relationship.
        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { response.should redirect_to(signin_path) }
        end
      end

    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }

      before { signin user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }

        it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to Users#Update action" do
        before { put user_path(wrong_user) }

        specify { response.should redirect_to(root_path) }
      end

      describe "manipulating other user's relationships" do
        let(:other_user) { FactoryGirl.create(:user) }
        
        describe "make wrong_user follow other_user" do
          let(:relationship) {wrong_user.relationships.build(followed_id: other_user.id)}

          it "should not increment wrong_user's followed users count" do
            expect do
              post relationship_path(relationship)
            end.to change(wrong_user.followed_users, :count).by(0)
          end
        end

        describe "make wrong_user unfollow other_user" do
          before { wrong_user.follow!(other_user) }
          let!(:relationship) { wrong_user.relationships.find_by_followed_id(other_user.id) }

          it "should not decrement wrong_user's followed users count" do
            expect do
              delete relationship_path(relationship.id)
            end.to change(wrong_user.followed_users, :count).by(0)
          end
        end
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { signin non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }

        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as admin user" do
      let(:admin) { FactoryGirl.create(:admin) }

      before { signin admin }

      describe "submitting a DELETE request to delete admin user" do
        before { delete user_path(admin) }

        specify { response.should redirect_to(root_path) }
      end
    end
  end
end
