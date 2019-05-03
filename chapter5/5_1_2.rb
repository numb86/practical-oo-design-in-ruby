class Trip
  attr_reader :bicycles, :customers, :vehicle

  def initialize(bicycles, customers, vehicle)
    @bicycles = bicycles
    @customers = customers
    @vehicle = vehicle
  end

  def prepare(preparers)
    preparers.each do |preparer|
      preparer.prepare_trip(self)
    end
  end
end

class Mechanic
  def prepare_trip(trip)
    trip.bicycles.each do |bicycle|
      prepare_bicycle(bicycle)
    end
  end

  def prepare_bicycle(bicycle)
    p "#{bicycle} の準備が完了しました。"
  end
end

class TripCoordinator
  def prepare_trip(trip)
    buy_food(trip.customers)
  end

  def buy_food(customers)
    p "#{customers} の食料を購入しました。"
  end
end

class Driver
  def prepare_trip(trip)
    vehicle = trip.vehicle
    gas_up(vehicle)
    fill_water_tank(vehicle)
  end

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
