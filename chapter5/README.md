# 第5章 ダックタイピングでコストを削減する

ダックタイプは、特定のクラスと結びつかないパブリックインターフェース。  
クラスをまたぐパブリックインターフェースは、アプリケーションに大きな柔軟性をもたらす。

## 5.1 ダックタイピングを理解する

オブジェクトのクラスではなく振る舞いに着目して設計できるようになれば、変更に強く拡張性の高いコードを書けるようになる。  
**重要なのは、オブジェクトが何であるかではなく、何をするか。**  
具体的には、ダックタイプを使うことで、柔軟なアプリケーションを作れるようになる。

以下の`Trip`クラスの`prepare`メソッドは、具体的なクラスやメソッドに依存しすぎている。  
そのため、変更の影響を受けやすいし、`preparer`が増える度に分岐が増えてしまう。

```ruby
# 5_1_1.rb
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
```

ダックタイプを使って改善したのが、以下のコード。

```ruby
# 5_1_2.rb
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
```

`prepare`メソッドは、具象的なクラスから自由になり、`Preparer`という抽象的なダックタイプに依存するようになった。  
`prepare`メソッドが知らなければならないのは、`Preparer`が持つ`prepare_trip`というパブリックインターフェースのみである。  
この変更で、`prepare`は変更に強く、拡張もしやすいものになった。

## 5.2 ダックを信頼するコードを書く

ダックタイピングする際は、他のオブジェクトを信頼することが大切。  
前節の`prepare`メソッドは、`Preparer`オブジェクトの`prepare_trip`がその役割を果たすことを信頼している。  
信頼しているからこそ、具体的な振る舞いには立ち入らず、ただ`prepare_trip`メッセージを送るだけに留めることが出来る。

常にダックタイピングすればよい、というものではない。  
物差しはあくまでも、変更コストを下げるかどうかであり、それを満たしそうにないのであればダックタイピングするべきではない。  
例えば、ダックタイプを新たに作るために組み込みクラスを拡張する行為は、変更コストの減少につながらない可能性が高い。

## 5.3 ダックタイピングへの恐れを克服する

ダックタイピングは動的型付けの上に成り立っているので、動的型付けを受け入れる必要がある。

## 5.4 まとめ

ダックタイピングは、パブリックインターフェースを特定のクラスから切り離し、仮想の型を作る。  
ダックタイピングによってパブリックインターフェースを抽象化することができ、それはアプリケーションに柔軟性をもたらす。
