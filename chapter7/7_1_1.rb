class Schedule
  # サンプルではそれで十分なので、必ず「スケジュールされていない」と返すようにした
  def scheduled?(schedulable, start_date, end_date)
    puts "This #{schedulable.class} is not scheduled " +
      "between #{start_date} and #{end_date}"
    false
  end
end

class Bicycle
  attr_reader :schedule, :size, :chain, :tire_size

  def initialize(args={})
    @schedule = args[:schedule] || Schedule.new
  end

  def schedulable?(start_date, end_date)
    !scheduled?(start_date - lead_days, end_date)
  end

  def scheduled?(start_date, end_date)
    schedule.scheduled?(self, start_date, end_date)
  end

  def lead_days
    1
  end
end

require 'date'
starting = Date.parse("2018/05/18")
ending = Date.parse("2018/05/25")

# main
p self

# main オブジェクトは Schedule について知っている必要がなく、
# Bicycle と直接やり取りを出来るようになった
b = Bicycle.new
# This Bicycle is not scheduled between 2018-05-17 and 2018-05-25
b.schedulable?(starting, ending)
