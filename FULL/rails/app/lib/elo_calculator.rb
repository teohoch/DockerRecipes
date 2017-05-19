class Elo_Calculator

  def initialize(attributes={})
    @users = attributes
    @size = @users.count

  end

  def calculate_rating
    results = []

    @users.each do |user|
      add = 0.0
      volatility_constant = 32.0
      current_position = 0
      if user[:winner]
        add=1.0
      end
      if user[:provisional]
        volatility_constant = 64.0
      end
      result = volatility_constant * (add - win_expectancy(user[:rating], get_average_rating(current_position)))
      results.push(result)
    end
    results
  end

  def get_average_rating(position)
    sum = 0.0
    @users.each do |user|
      sum = sum + user[:rating]
    end
    total = sum - @users[position][:rating]
    (total / (@size - 1.0))
  end

  def win_expectancy(rating, opp_rating)
    exponent = (-1.0 * (rating - opp_rating)) / 400.0
    denominator = (10**exponent) + 1.0
    ((1.0 / denominator) * (2.0 / @size))
  end
end