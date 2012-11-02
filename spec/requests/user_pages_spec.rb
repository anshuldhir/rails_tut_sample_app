require 'spec_helper'

describe "User pages" do  
  subject { page }

  describe "Signup page" do
    before { visit signup_path }
    let(:page_title) { 'Sign up' }

    it { should have_selector('h1', text: 'Sign Up') }
    it { should have_selector('title', text: full_title(page_title)) }    
  end

end
