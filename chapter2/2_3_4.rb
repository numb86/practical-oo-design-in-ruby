class RevealingReferences
  attr_reader :wheels
  def initialize(data)
    @wheels = wheelify(data)
  end

  def diameters
    wheels.collect {|wheel|
      # 車輪の直径 = リム + (タイヤの厚み * 2)
      wheel.rim + (wheel.tire * 2)
    }
  end

  Wheel = Struct.new(:rim, :tire)
  def wheelify(data)
    data.collect {|cell|
      # [0]はリム [1]はタイヤ
      Wheel.new(cell[0], cell[1])
    }
  end
end

value = [[622, 20], [622, 23]]
p RevealingReferences.new(value).diameters # [662, 668]
