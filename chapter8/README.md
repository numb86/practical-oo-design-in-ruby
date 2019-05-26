# 第8章　コンポジションでオブジェクトを組み合わせる

コンポジションとは、複数のオブジェクトを組み合わせて、より大きな全体を作ること。  
また、そのような行為を行うことを「コンポーズする」という。

コンポジションにおいては、全体が部品を持つ、という構成になる（`has-a`）。  
例えばコンポジションで自転車を作る場合、自転車という全体が、個々の部品を持つことになる。  
そして、ただ持っているだけではなく、部品と情報交換を行う。

## 8.1 自転車をパーツからコンポーズする

第6章で継承によって`Bicycle`を作ったが（[6_5_2.rb](../chapter6/6_5_2.rb)）、それをコンポジションによる実装に置き換える。  
要件は変えず、`Bicycle`は`spares`メッセージと`size`メッセージに応答できるようにする。

自転車は部品を持つので、部品を組み合わせて自転車を構成することにする。  
そのために、部品を全て持つ`Parts`というクラスを作り、`spares`メッセージに応える責務をこのクラスに持たせる。  
`Bicycle`は必ず1つの`Parts`を持つ。

この構成をコードに落とし込むと、以下のようになる。

```ruby
# 8_1_1.rb
class Bicycle
  attr_reader :size, :parts

  def initialize(arg={})
    @size = arg[:size]
    @parts = arg[:parts]
  end

  def spares
    parts.spares
  end
end
```

## 8.2 Parts オブジェクトをコンポーズする

`Parts`は、個々の部品を持つ。つまり、`Parts`も複数の部品によって構成されているコンポジションである。

単一の部品を表すクラスである`Part`を作る。  
`Parts`は、1つ以上の`Part`を持つ。

`Bicycle`のインスタンスが`spares`メッセージを受け取った際の処理の流れは、以下のようにする。  
`Bicycle`は、`self.spares`を`Parts#spares`に委譲する。  
`Parts#spares`は、その`Parts`が持っている各`Part`に`needs_spare`メッセージを送り、`true`が返ってきた`Part`の配列を返り値とする。

以下がその実装。

```ruby
# 8_2_1.rb
class Bicycle
  attr_reader :size, :parts

  def initialize(arg={})
    @size = arg[:size]
    @parts = arg[:parts]
  end

  def spares
    parts.spares
  end
end

class Parts
  attr_reader :parts

  def initialize(parts)
    @parts = parts
  end

  def spares
    parts.select {|part| part.needs_spare}
  end
end

class Part
  attr_reader :name, :description, :needs_spare

  def initialize(arg)
    @name = arg[:name]
    @description = arg[:description]
    @needs_spare = arg.fetch(:needs_spare, true)
  end
end

chain = Part.new(name: 'chain', description: '10-speed')
mountain_tire = Part.new(name: 'mountain_tire', description: '2.1')
rear_shock = Part.new(name: 'rear_shock', description: 'Fox')
front_shock = Part.new(name: 'front_shock', description: 'Manitou', needs_spare: false)

mountain_bike = Bicycle.new(
  size: 'L',
  parts: Parts.new([chain, mountain_tire, rear_shock, front_shock])
)

# "L"
p mountain_bike.size

# [
#   #<Part:0x00007fee558c4768 @name="chain", @description="10-speed", @needs_spare=true>,
#   #<Part:0x00007fee558c4628 @name="mountain_tire", @description="2.1", @needs_spare=true>,
#   #<Part:0x00007fee558c4560 @name="rear_shock", @description="Fox", @needs_spare=true>
# ]
p mountain_bike.spares
```

[6_5_2.rb](../chapter6/6_5_2.rb)とは`spares`の仕様が異なり、ハッシュではなく`Part`の配列を返すようになっている。

```ruby
# 6_5_2.rb
# {:chain=>"10-speed", :tire_size=>"2.1", :rear_shock=>"Fox"}

# 8_2_1.rb
# [
#   #<Part:0x00007fee558c4768 @name="chain", @description="10-speed", @needs_spare=true>,
#   #<Part:0x00007fee558c4628 @name="mountain_tire", @description="2.1", @needs_spare=true>,
#   #<Part:0x00007fee558c4560 @name="rear_shock", @description="Fox", @needs_spare=true>
# ]
```

コンポジションの考え方では、この`Part`は、`Part`というロールである。  
そのため、そのロールに期待される責務を果たしてさえいれば、`Part`クラスのインスタンスである必要もない。

使い勝手をよくするため、`Parts`を改良する。  
現状では、`Bicycle#spares`と`Bicycle#parts`の返り値のケースが異なる。前者は`Part`の配列を返すが、後者は`Parts`インスタンスを返す。

```ruby
p mountain_bike.spares.class #Array
p mountain_bike.parts.class # Parts
```

このような状態は望ましくない。どちらも配列のように扱えるようにしたい。

対応策はいくつかあるが、今回は、以下のように対応した。

```diff
@@ -11,15 +11,18 @@ class Bicycle
   end
 end

+require 'forwardable'
 class Parts
-  attr_reader :parts
+  extend Forwardable
+  def_delegators :@parts, :size, :each
+  include Enumerable

   def initialize(parts)
     @parts = parts
   end

     @parts = parts
   end

   def spares
-    parts.select {|part| part.needs_spare}
+    select {|part| part.needs_spare}
   end
 end
```

これで、`Bicycle#parts`の返り値も`size`メッセージなどに対応できるようになった。

```ruby
p mountain_bike.spares.size #Array
p mountain_bike.parts.size # Parts
```

## 8.3 Parts を製造する

前節までの設計には、問題がある。  
それは、`Part`オブジェクトの作り方についての知識と、それぞれの自転車毎にどの部品を必要とするかについての知識が、一箇所にまとまっていないこと。  
このままではこの知識がアプリケーション全体に漏れ出てしまい、管理が困難になる。

そのため、一箇所にまとめていく。

まず、それぞれの自転車についての情報を、2次元配列として記述する。

```ruby
road_config = [
  ['chain', '10-speed'],
  ['tire_size', '23'],
  ['tape_color', 'red']
]

mountain_config = [
  ['chain', '10-speed'],
  ['tire_size', '2.1'],
  ['front_shock', 'Manitou', false],
  ['rear_shock', 'Fox']
]
```

次に、`Parts`オブジェクトを作成するためのオブジェクトである`PartsFactory`を定義する。  
`PartsFactory`は先程の2次元配列（`config`）を受け取ることで、その中身に基づいて`Parts`を作る。

そして、`Part`オブジェクト作成のための知識は`PartsFactory`が持つことになるので、`Part`クラスとの重複が生まれる。  
必要なのは`Part`ロールを担うオブジェクトであり、それを`PartsFactory`が作れるようになった以上、`Part`クラスは不要になる。

```ruby
# 8_3_1.rb
require 'ostruct'
module PartsFactory
  def self.build(config, parts_class = Parts)
    parts_class.new(
      config.collect {|part_config| create_part(part_config)}
    )
  end

  def self.create_part(part_config)
    OpenStruct.new(
      name: part_config[0],
      description: part_config[1],
      needs_spare: part_config.fetch(2, true)
    )
  end
end

# #<Parts:0x00007ff91508fac8
#   @parts=[
#     #<OpenStruct name="chain", description="10-speed", needs_spare=true> ,
#     #<OpenStruct name="tire_size", description="2.1", needs_spare=true>,
#     #<OpenStruct name="front_shock", description="Manitou", needs_spare=false>,
#     #<OpenStruct name="rear_shock", description="Fox", needs_spare=true>
#   ]
# >
p PartsFactory.build(mountain_config)
```

`PartsFactory`は`config`の構造についての知識（最初の要素が名前である、など）を持っているが、そのことで、`config`を簡潔に記述できる。ハッシュではなく配列で表現することが出来る。
