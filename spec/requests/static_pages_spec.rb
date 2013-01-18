require 'spec_helper'

describe "Static pages" do

  subject { page }
  
  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }  
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)     { 'Sample App'}
    let(:page_title)  { '' }

    it_should_behave_like "all static pages" 
    
    it { should_not have_selector('title', text: '| Home') }

    it "should have the right links on the page" do
      click_link "Sign up now!"
      current_path.should == signup_path
    end

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        signin user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading)     { 'Help'}
    let(:page_title)  { 'Help' }

    it_should_behave_like "all static pages" 
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)     { 'About Us'}
    let(:page_title)  { 'About Us' }

    it_should_behave_like "all static pages" 
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading)     { 'Contact'}
    let(:page_title)  { 'Contact' }
    
    it_should_behave_like "all static pages" 
  end

  it "should have the right links on the layout" do
    visit root_path

    click_link "About"
    current_path.should == about_path

    click_link "Help"
    current_path.should == help_path

    click_link "Contact"
    current_path.should == contact_path

    click_link "Home"
    current_path.should == root_path

    click_link "sample app"
    current_path.should == root_path

    # click_link "Sign in"
    # current_path.should == signin_path
  end

end