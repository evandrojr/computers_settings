#!/usr/bin/env ruby

environment=ARGV[0]
environment ||= "development"

c = %Q{rails runner -e #{environment} 'Environment.default.enable("skip_new_user_email_confirmation")'}
puts c
system c

c = %Q{ rails r -e #{environment} " \
u = 'evandrojr';\
n = 'e';\
user = User.create(:login => u, :email => n + '@evandro.org', :password => 'llll', :password_confirmation => 'llll', :environment => Environment.default);\
user.save!;\
Environment.default.add_admin user.person;\
user.activated_at = Time.new;\
user.save!;\
user.update_column(:login, n); " \
}

puts c
system c
