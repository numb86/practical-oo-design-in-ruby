class Trip
  attr_reader :bicycles, :customers, :vehicle

  def initialize(bicycles, customers, vehicle)
    @bicycles = bicycles
    @customers = customers
    @vehicle = vehicle
  end

  def prepare(preparers)
    preparers.each do |preparer|
      case preparer

      when Mechanic
        preparer.prepare_bicycles(bicycles)

      when TripCoordinator
        preparer.buy_food(customers)

      when Driver
        preparer.gas_up(vehicle)
        preparer.fill_water_tank(vehicle)
      end
    end
  end
end

class Mechanic
  def prepare_bicycles(bicycles)
    bicycles.each {|bicycle| prepare_bicycle(bicycle)}
  end

  def prepare_bicycle(bicycle)
    p "#{bicycle} の準備が完了しました。"
  end
end

class TripCoordinator
  def buy_food(customers)
    p "#{customers} の食料を購入しました。"
  end
end

class Driver
  def gas_up(vehicle)
    p "#{vehicle} のガソリンを満タンにしました。"
  end

  def fill_water_tank(vehicle)
    p "#{vehicle} のタンクを満水にしました。"
  end
end

Trip.new(['自転車A', '自転車B'], '顧客', 'オートバイ')
  .prepare([Mechanic.new, Driver.new, TripCoordinator.new])
# "自転車A の準備が完了しました。"
# "自転車B の準備が完了しました。"
# "オートバイ のガソリンを満タンにしました。"
# "オートバイ のタンクを満水にしました。"
# "顧客 の食料を購入しました。"
