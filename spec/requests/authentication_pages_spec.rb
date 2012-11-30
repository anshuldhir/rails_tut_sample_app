require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "signin page" do
    before { visit signin_path }
    let(:page_title) { 'Sign in' }

    it { should have_selector('h1', text: page_title) }
    it { should have_selector('title', text: full_title(page_title)) }
  end
end
