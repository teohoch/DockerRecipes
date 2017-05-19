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

users = [fuser, fuser2]

10.times do
  users.push(FactoryGirl.create(:user))
end


tournament1 = Tournament.new(
    :name => 'Torneo1',
    :officer_id => fuser.id,
    :number_players => 8,
    :prize => 'Something Shiny',
    :entrance_fee => 10500,
    :date => Date.tomorrow,
    :rounds => 2,
    :mode => 0)
tournament1.save

aval_users = users.dup.to_a

8.times do
  user = aval_users.slice!(rand(aval_users.count))
  inscription = Inscription.new({:user_id => user[:id], :tournament_id => tournament1.id})
  inscription.save
end

tournament3 = Tournament.new(
    :name => 'Torneo1',
    :officer_id => fuser.id,
    :number_players => 9,
    :prize => Faker::StarWars.vehicle,
    :entrance_fee => 10500,
    :date => Date.tomorrow,
    :rounds => 2,
    :mode => 0)
tournament3.save

aval_users = users.dup.to_a

9.times do
  user = aval_users.slice!(rand(aval_users.count))
  inscription = Inscription.new({:user_id => user[:id], :tournament_id => tournament3.id})
  inscription.save
end

tournament2 = Tournament.new(
    :name => 'Torneo2',
    :officer_id => fuser.id,
    :number_players => 8,
    :prize => 'Something opaque',
    :entrance_fee => 10500,
    :date => Date.tomorrow,
    :rounds => 0,
    :mode => 2)

tournament2.save

aval_users = users.dup.to_a

9.times do
  user = aval_users.slice!(rand(aval_users.count))
  inscription = Inscription.new({:user_id => user[:id], :tournament_id => tournament2.id})
  inscription.save
end


5.times do
  Match.new_with_child(:date => Faker::Date.between(Date.today, 1.month.from_now),
                       :location => Faker::Address.city,
                       :user_matches_attributes => {
                           0 => {
                               :user_id => '4',
                               :validated => 'true',
                               :vp => Faker::Number.between(1, 10)},
                           1487648543682 => {
                               :user_id => '2',
                               :_destroy => 'false',
                               :vp => Faker::Number.between(1, 10)},
                           1487648544163 => {
                               :user_id => '3',
                               :_destroy => 'false',
                               :vp => Faker::Number.between(1, 10)},
                           1487648544636 => {
                               :user_id => '1',
                               :_destroy => 'false',
                               :vp => Faker::Number.between(1, 10)}
                       })
end


