require 'spec_helper'



describe "User pages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_content("Sign up") }
    it { should have_title(full_title("Sign up")) }
  end

  describe "signup" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title("Sign up") }
        it { should have_content("error") }
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name", with: "Example User"
        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirm Password", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by email: "user@example.com" }

        it { should have_link("Sign out") }
        it { should have_title(user.name) }
        it { should have_selector("div.alert.alert-success", text: "Welcome") }

        describe "when attempting to another sign up" do
          before { sign_in user, no_capybara: true }

          describe "by submitting GET request to Users#new controller" do
            before { get signup_path }

            it { should_not have_title("Sign up") }
            specify { expect(response).to redirect_to(root_url) }
          end

          describe "by submitting POST request to Users#create controller" do
            let(:params) do
              { user: { name: user.name, email: user.email,
                        password: user.password, password_confirmation: user.password }
              }
            end
            before { post users_path, params }

            specify { expect(response).to redirect_to(root_url) }
          end
        end
      end
    end
  end # signup

  describe "profile page" do
    let(:user) { FactoryGirl.create :user }
    let!(:m1) { FactoryGirl.create :micropost, user: user, content: "Foo" }
    let!(:m2) { FactoryGirl.create :micropost, user: user, content: "Bar" }
    before  { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end # microposts

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create :user }
      before { sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }

          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end # following a user

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }

          it { should have_xpath("//input[@value='Follow']") }
        end
      end # unfollowing a user
    end # follow/unfollow buttons
  end # profile page

  describe "edit" do
    let(:user) { FactoryGirl.create :user }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end

      specify { expect(user.reload).not_to be_admin }
    end

    describe "with invalid information" do
      before { click_button "Save change" }

      it { should have_content("error") }
    end

    describe "with valid information" do
      let(:new_name) { "New name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector("div.alert.alert-success") }
      it { should have_link("Sign out", href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end # edit

  describe "index" do
    before do
      sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
      FactoryGirl.create(:user, name: "Rob", email: "rob@example.com")
      visit users_path
    end

    it { should have_title("All users") }
    it { should have_content("All users") }

    it "should list each user" do
      User.all.each do |user|
        expect(page).to have_selector("li", text: user.name)
      end
    end

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create :user } }
      after(:all) { User.delete_all }

      it { should have_selector("div.pagination") }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector("li", text: user.name)
        end
      end
    end # pagination

    describe "delete links" do
      it { should_not have_link("delete") }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create :admin }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link("delete", href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link("delete", match: :first) # we don't care which one link will be clicked
          end.to change(User, :count).by(-1)
        end

        describe "should not be able to delete himself" do
          it { should_not have_link("delete", href: user_path(admin)) }

          describe "by submitting DELETE request to the Users#destroy controller" do
            # I don't know, why admin must sign in again, this time without Capybara.
            # I assume, because this is "controller spec", not integration test.
            before { sign_in admin, no_capybara: true }

            specify { expect { delete user_path(admin) }.not_to change(User, :count) }
          end
        end
      end # as an admin user
    end # delete links
  end # index

  describe "following/followers" do
    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create :user }
    before { user.follow!(other_user) }

    describe "followerd users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title(full_title("Following")) }
      it { should have_selector("h3", text: "Following") }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title(full_title("Followers")) }
      it { should have_selector("h3", text: "Followers") }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end # following/followers

end

