FactoryGirl.define do
  factory :user_match, class: UserMatch do
    vp 1
    validated false
    association :user, factory: :user, strategy: :create
    association :match, factory: :match, strategy: :create
  end
end