#!/usr/bin/env ruby

c = %Q{rails runner 'Environment.default.enable("skip_new_user_email_confirmation")'}
puts c
system c

c = %Q{ rails r " \
u = 'gostoso';\
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
