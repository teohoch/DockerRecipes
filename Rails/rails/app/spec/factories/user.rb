FactoryGirl.define do
  factory :user, class: User do
    name {Faker::Name.name}
    email { Faker::Internet.email(name) }
    password 'password'
    password_confirmation 'password'
  end
end