# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


fuser = User.new(:email => 'teohoch2@gmail.com',
                 :name => 'Teodoro Hochfärber',
                 :password => 'password',
                 :password_confirmation => 'password')

fuser.save

fuser2 = User.new(:email => 'teodoro.hochfarber@gmail.com',
                  :name => 'Teo2',
                  :password => 'password',
                  :password_confirmation => 'password')

fuser2.save

users = [fuser, fuser2].concat(FactoryGirl.create_list(:user, 10))

tournament1 = FactoryGirl.create(:tournament, :pyramidal_1, :with_inscriptions, :with_users, available_users: users.slice(0..7), number_players: 8, n_registered: 8, officer: fuser)
tournament2 = FactoryGirl.create(:tournament, :pyramidal_1, :with_inscriptions, :with_users, available_users: users.slice(0..8), number_players: 9, n_registered: 9, officer: fuser)
tournament3 = FactoryGirl.create(:tournament, :free4all, :with_inscriptions, :with_users, available_users: users.slice(0..8), number_players: 9, n_registered: 9, officer: fuser, rounds: 2)