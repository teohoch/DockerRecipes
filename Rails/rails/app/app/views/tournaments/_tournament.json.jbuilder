json.extract! tournament, :id, :name, :number_players, :price, :entrance_fee, :user_id, :created_at, :updated_at
json.url tournament_url(tournament, format: :json)