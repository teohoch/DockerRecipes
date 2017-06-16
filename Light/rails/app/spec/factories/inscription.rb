FactoryGirl.define do
  factory :inscription, class: Inscription do
    association :user, factory: :user, strategy: :create
    association :tournament, factory: :user, strategy: :create
    present_position 0
    present_round 0
    score 0
  end
end