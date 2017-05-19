FactoryGirl.define do
  factory :tournament, class: Tournament do
    name {Faker::StarWars.planet + ' Annual Tournament'}
    number_players 9
    prize { Faker::StarWars.vehicle }
    entrance_fee { Faker::Number.number(4) }
    date { Date.today }
    association :officer, factory: :user, strategy: :create
    rounds 0

    transient do
      available_users []
    end

    trait :with_users do
      transient do
        with_users true
      end
    end

    trait :with_inscriptions do
      transient do
        n_registered 0

        after(:create) do |tournament, evaluator|
          evaluator.n_registered.times do
            if evaluator.with_users
              user = evaluator.available_users.pop
            else
              user = create(:user)
            end
            create(:inscription, user_id: user.id, tournament_id: tournament.id)
          end
        end
      end
    end

    trait :free4all do
      mode -1
    end

    trait :pyramidal do
      mode 1
    end

    trait :pyramidal_instant_winner do
      mode 0
    end

    trait :pyramidal_1 do
      mode 1
    end

    trait :pyramidal_2 do
      mode 2
    end

    trait :pyramidal_3 do
      mode 3
    end

    trait :pyramidal_4 do
      mode 4
    end

    trait :pyramidal_5 do
      mode 5
    end

  end
end