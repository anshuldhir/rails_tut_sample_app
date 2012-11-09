# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do

  before { 
    @user = User.new( name: "Example User", email: "user@example.com", 
                      password: "foobar", password_confirmation: "foobar")

    @minimum_name_length    = 2
    @maximum_name_length    = 50
    @minimum_password_length = 6
  }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should be_valid}

  # Validation tests for :name
  describe 'when name is not present' do
    before { @user.name = ' ' }
    it { should_not be_valid }
  end

  describe 'when name is maximum length' do
    before { @user.name = "a" * @maximum_name_length }
    it { should be_valid }
  end

  describe 'when name is more than maximum length' do
    before { @user.name = "a" * (@maximum_name_length + 1) }
    it { should_not be_valid }
  end

  describe 'when name is minimum length' do
    before { @user.name = "a" * @minimum_name_length}
    it { should be_valid }
  end

  describe 'when name is less than minimum length' do
    before { @user.name = "a" * (@minimum_name_length - 1) }
    it { should_not be_valid }
  end

  # validation tests for :email

  describe 'when email is not present' do
    before { @user.email = '  ' }
    it { should_not be_valid }
  end

  describe 'when email format is invalid' do
    it 'should be invalid' do
      addresses =   [
                    'abcexample.com',     # does not contain @ character
                    'abc_at_example.com', # does not contain @ character
                    'abc@examplecom',     # does not contain . character
                    '@example.com',       # does not contain a valid id
                    'abc@.com',           # does not contain a valid domain name
                    'abc@example.',       # does not contain a valid domain suffix
                    '@.',                 # does not contain a valid id, domain name or domain suffix
                    'user@foo,com',
                    'user_at_foo.org',
                    'example.user@foo.',
                    'foo@bar_baz.com',
                    'foo@bar+baz.com'
                    ]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe 'when email format is valid' do
    it 'should be valid' do
      addresses =   [
                    'user@foo.COM',
                    'A_US-ER@f.b.org',
                    'frst.lst@foo.jp',
                    'a+b@baz.cn'
                    ]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end


  describe "when email address is already taken" do
    before do
      @user_with_same_email = @user.dup
      @user_with_same_email.save
    end

    it { should_not be_valid }
  end  

  describe "when a case variant of the email address is already taken" do
    before do
      @user_with_same_email = @user.dup
      @user_with_same_email.email = @user.email.upcase
      @user_with_same_email.save
    end

    it { should_not be_valid }
  end  

  describe "email address with mixed case" do
    let(:mixed_case_email) { "teST@eXaMpLe.CoM"}

    it "should be saved as all lowercase" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end

  # Validation tests for password
  
  describe "when password is not preset" do
    before { @user.password = ' ' }
    it { should_not be_valid }
  end
  
  describe "when password is nil" do
    before { @user.password = nil }
    it { should_not be_valid }
  end


  # Validation tests for password_confirmation

  describe "when password_confirmation is not preset" do
    before { @user.password_confirmation = ' ' }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = 'mismatch' }
    it { should_not be_valid }
  end

  describe "when password is minimum length" do
    before { @user.password = @user.password_confirmation = "a" * @minimum_password_length }
    it { should be_valid }
  end  
  
  describe "when password is too short" do
    before { @user.password = @user.password_confirmation = "a" * (@minimum_password_length - 1) }
    it { should_not be_valid }
  end  


  # Validation of authenticate

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password } 
      specify { user_for_invalid_password.should be_false }
    end
  end

end
