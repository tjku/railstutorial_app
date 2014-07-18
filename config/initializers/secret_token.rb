# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
# RailstutorialApp::Application.config.secret_key_base = '1433c72545535216904bb2208a16b07e0140e5b09e939eae2c339e134f75df2ef2adda933819615a3a4460d759420db68afb27d4153f957e21625f2033f48315'

require 'securerandom'


def secure_token
  token_file = Rails.root.join('.secret')

  if File.exists? token_file
    # Use the existing token.
    File.read(token_file).chomp
  else
    # Generate a new token and store it in token_file
    token = SecureRandom.hex(64)
    File.write(token_file, token)

    token
  end
end

RailstutorialApp::Application.config.secret_key_base = secure_token

