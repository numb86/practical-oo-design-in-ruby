class Gear
  def initialize(chainring, cog)
    @chainring = chainring
    @cog = cog
  end

  def chainring
    @chainring
  end

  def cog
    @cog
  end

  def ratio
    chainring / cog.to_f # <- Good
  end
end

p Gear.new(51, 11).ratio # 4.636363636363637
