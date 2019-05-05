class Bicycle
  def initialize(args={})
  end
end

class RoadBike < Bicycle
  attr_reader :size, :tape_color

  def initialize(args)
    @size = args[:size]
    @tape_color = args[:tape_color]
  end

  def spares
    {
      chain: '10-speed',
      tire_size: '23',
      tape_color: tape_color
    }
  end
end

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
    super(args)
  end

  def spares
    super.merge(rear_shock: rear_shock)
  end
end

road_bike = RoadBike.new(size: 'M', tape_color: 'red')
# "M"
p road_bike.size

mountain_bike = MountainBike.new(size: 'S', front_shock: 'Manitou', rear_shock: 'Fox')
# undefined method `size' for #<MountainBike:0x00007f7efe8a0ca8> (NoMethodError)
p mountain_bike.size
