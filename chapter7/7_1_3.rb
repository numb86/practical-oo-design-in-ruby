class Schedule
  # サンプルではそれで十分なので、必ず「スケジュールされていない」と返すようにした
  def scheduled?(schedulable, start_date, end_date)
    puts "This #{schedulable.class} is not scheduled " +
      "between #{start_date} and #{end_date}"
    false
  end
end

module Schedulable
  attr_writer :schedule

  def schedule
    @schedule ||= ::Schedule.new
  end

  def schedulable?(start_date, end_date)
    !scheduled?(start_date - lead_days, end_date)
  end

  def scheduled?(start_date, end_date)
    schedule.scheduled?(self, start_date, end_date)
  end

  def lead_days
    0
  end
end

class Bicycle
  include Schedulable

  attr_reader :schedule, :size, :chain, :tire_size

  def initialize(args={})
    @schedule = args[:schedule] || Schedule.new
  end

  def lead_days
    1
  end
end

class Mechanic
  include Schedulable

  def lead_days
    4
  end
end

class Vehicle
  include Schedulable

  def lead_days
    3
  end
end

require 'date'
starting = Date.parse("2018/05/18")
ending = Date.parse("2018/05/25")

b = Bicycle.new
# This Bicycle is not scheduled between 2018-05-17 and 2018-05-25
b.schedulable?(starting, ending)

m = Mechanic.new
# This Mechanic is not scheduled between 2018-05-14 and 2018-05-25
m.schedulable?(starting, ending)

v = Vehicle.new
# This Vehicle is not scheduled between 2018-05-15 and 2018-05-25
v.schedulable?(starting, ending)
