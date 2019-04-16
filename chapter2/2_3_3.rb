class ObscuringReferences
  attr_reader :data
  def initialize(data)
    @data = data
  end

  def diameters
    data.collect {|cell|
      # [0]はリム [1]はタイヤ
      # 車輪の直径 = リム + (タイヤの厚み * 2)
      cell[0] + (cell[1] *2)
    }
  end
end

value = [[622, 20], [622, 23]]
p ObscuringReferences.new(value).diameters # [662, 668]
