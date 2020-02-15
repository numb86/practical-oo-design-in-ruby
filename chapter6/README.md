# 第6章 継承によって振る舞いを獲得する

この章では、継承の適切な使い方を示す。

## 6.1 クラスによる継承を理解する

**継承とは、メッセージを自動委譲する仕組み。**  
あるオブジェクトがメッセージを受け取ったときにそれに応答できなければ、そのメッセージを他のオブジェクトに転送する。  
クラスによる継承においては、サブクラスからスーパークラスへとメッセージが転送される。

## 6.2 継承を使うべき箇所を識別する

最初の課題は、継承を使うことで解決できる課題の存在にどうやって気付くか。  
この節では、例を用いてそれに気付く過程を示す。

まず、ロードバイクを表現するためのクラス`Bicycle`がある。  
整備士（`Mechanic`）は、`spares`メッセージを`Bicycle`に送ることで、必要なスペアパーツを知ることが出来る。

```ruby
# 6_2_1.rb
class Bicycle
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

bike = Bicycle.new(size: 'M', tape_color: 'red')

p bike.size # "M"
p bike.spares # {:chain=>"10-speed", :tire_size=>"23", :tape_color=>"red"}
```

このコードは、それなりに妥当なものである。

その後、マウンテンバイクも扱うようになった。

ロードバイクとマウンテンバイクは異なる点もあるが、かなり似通っている。  
必要な振る舞いの大半は`Bicycle`が持っている。なので、マウンテンバイクも`Bicycle`で表現することにした。  
その結果、次のようなコードになった。

```ruby
# 6_2_2.rb
class Bicycle
  attr_reader :style, :size, :tape_color, :front_shock, :rear_shock

  def initialize(args)
    @style = args[:style]
    @size = args[:size]
    @tape_color = args[:tape_color]
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
  end

  def spares
    if style == :road
      {
        chain: '10-speed',
        tire_size: '23', # milimeters
        tape_color: tape_color
      }
    else
      {
        chain: '10-speed',
        tire_size: '2.1', # inches
        rear_shock: rear_shock
      }
    end
  end
end

bike = Bicycle.new(
  style: :mountain,
  size: 'S',
  front_shock: 'Manitou',
  rear_shock: 'Fox'
)

p bike.spares # {:chain=>"10-speed", :tire_size=>"2.1", :rear_shock=>"Fox"}
p bike.tape_color # nil
p bike.rear_shock # "Fox"
```

このコードは多くの問題を抱えている。  
`style`が増える度に`if`による分岐も増えるし、`if`の両方の節で重複している文字列もある。

メソッドへの信頼も失われた。  
例えば、`Bicycle`のインスタンスを保持するオブジェクトが`tape_color`の値を持っているかどうか、事前には分からない。  
同じ`Bicycle`のインスタンスでも、持っているものもあるし、持っていないものもある。

`spares`メソッドは、[5_1_1.rb](../chapter5/5_1_1.rb)の`prepare`メソッドと同じパターンに陥ってしまっている。  
どちらも、メッセージの送り先の属性ごとに分岐を行い、どのメッセージを送るかを決めている。違いは、`prepare`のパターンではメッセージの送り先が自分以外のオブジェクトであり、`spares`のパターンではメッセージの送り先が自分自身である、ということのみ。

`Bicycle`の中に複数の型（ロードバイクとマウンテンバイク）が埋め込まれているから、このような分岐が発生している。  
**共通の振る舞いを持っており強く関連しているが、異なる面もある、複数の型。それが埋め込まれている。そのようなパターンは、継承によって解決できる。**

*Ruby は多重継承はサポートしていないため、サブクラスは親となるスーパークラスを1つしか持てない。以降の説明は全て、単一継承を前提とする。*

クラスによる継承では、理解できないメッセージを受け取ったオブジェクトは、そのメッセージをスーパークラスに転送する。  
そのため、サブクラスはスーパークラスのパブリックインターフェースを全て持っていると言える。サブクラスはスーパークラスを特化したものである、とも解釈できる。

マウンテンバイクは`Bicycle`を特化したものであると考えられる。そのため、クラスによる継承を使って`Bicycle`の抱える問題を解決することが出来るのである。

## 6.3 継承を不適切に適用する

既存の実装を拡張して継承を実装する場合は、スーパークラスにしようとしているクラスが本当にスーパークラスとして適しているか、よく考える。  
例えば`6_3_1.rb`の`Bicycle`は、一般的な自転車の振る舞いの他にロードバイク固有の振る舞いも持っているため、スーパークラスとして適していない。`Bicycle`を継承した`MountainBike`を作ると、継承すべきでないものまで継承してしまう。

```ruby
# 6_3_1.rb
class Bicycle
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

mountain_bike = MountainBike.new(size: 'S', front_shock: 'Manitou', rear_shock: 'Fox')

# "S"
p mountain_bike.size

# tire_size は間違っているし、tape_color は持っていてはいけない
# {:chain=>"10-speed", :tire_size=>"23", :tape_color=>nil, :rear_shock=>"Fox"}
p mountain_bike.spares
```

## 6.4 抽象を見つける

`6_3_1.rb`の`Bicycle`は、一般的な自転車のコードとロードバイク固有のコードの、両方を含んでいる。  
このアプリケーションにおける自転車が全てロードバイクであったなら、それで問題なかった。  
だが今やこのアプリケーションには、ロードバイクとマウンテンバイクの両方が存在する。

ロードバイク固有のコードは`Bicycle`から取り出して、`RoadBike`というサブクラスに入れることにする。

新しい`Bicycle`クラスは抽象クラスであり、抽象クラスは、サブクラスを作るためだけに存在する。  
全ての自転車に共通の性質を持つだけであり、具体的な自転車のことは表現しない。だから、抽象クラスのインスタンスが作られることはない。

継承関係を作るときは、抽象を取り出してそれをスーパークラスに持たせる。具象はサブクラスに持たせる。  
そのため、いかにして正しい抽象を見つけるかが問題であり、そのための情報は多いほうがいい。  
継承関係を作るのを遅らせて、十分な情報が揃うのを待ったほうがいいかもしれない。  
遅らせれば遅らせるほど重複するコードを許容することになるので、これはトレードオフである。  
今回は、継承関係を作るべきだと判断したと仮定して、先に進む。

最初の一歩として、`Bicycle`を`RoadBike`にリネームし、新しく空の`Bicycle`クラスを作る。  
これで、空のスーパークラスを継承した2つのサブクラス（`RoadBike`と`MountainBike`）が存在する状態になった。

```ruby
# 6_4_1.rb
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
```

ここから始めて、抽象的な振る舞いだけをスーパークラスである`Bicycle`に移動させるのが、最終的な目標。

`Bicycle`のようにまずスーパークラスを空にして、抽象を探し出して移していくのが望ましい。  
なぜなら、抽象を見逃してサブクラスに残ったままになってしまっても、そのような失敗は発見が容易で、修正も簡単に出来ることが多い。  
全ての振る舞いをスーパークラスに持たせておき、そこから具象を探し出してサブクラスに移そうとすると、具象をスーパークラスに残してしまうという事態が発生する恐れがある。そしてそのような失敗は、影響が広範囲に及び、深刻なものになりやすい。  
だから、「抽象を探してスーパークラスに移す」というアプローチを取るべき。

以下のコードでは、`size`,`chain`,`tire_size`をスーパークラスに移した。  
`chain`と`tire_size`については、全ての自転車が共通の`chain`の初期値を持ち、サブクラスが各自で`tire_size`の初期値を持つ、という要件のため、**テンプレートメソッドパターン**を採用した。  
テンプレートメソッドパターンとは、固有の処理をサブクラスに持たせ、スーパークラスでそれを利用した処理の流れを定義するパターンのこと。

```ruby
# 6_4_2.rb
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args={})
    @size = args[:size]
    @chain = args[:chain] || default_chain
    @tire_size = args[:tire_size] || default_tire_size
  end

  def default_chain
    '10-speed'
  end

  def default_tire_size
    raise NotImplementedError
  end
end

class RoadBike < Bicycle
  attr_reader :tape_color

  def initialize(args)
    @tape_color = args[:tape_color]
    super(args)
  end

  def default_tire_size
    '23'
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

  def default_tire_size
    '2.1'
  end

  def spares
    super.merge(rear_shock: rear_shock)
  end
end

road_bike = RoadBike.new(size: 'M', tape_color: 'red')
p road_bike.size # "M"
p road_bike.chain # "10-speed"

mountain_bike = MountainBike.new(size: 'S', front_shock: 'Manitou', rear_shock: 'Fox')
p mountain_bike.size # "S"
p mountain_bike.chain # "10-speed"
```

`default_tire_size`はサブクラスで定義する仕様になっているが、スーパークラスでも定義しておき、それが呼ばれた場合は例外を投げるようにした。  
このようにしておくことで、仕様を理解していない開発者が`default_tire_size`のないサブクラスを作ってしまった際に、適切なエラーメッセージが表示される。

```ruby
class RecumbentBike < Bicycle
  def default_chain
    '9-speed'
  end
end

# `default_tire_size': NotImplementedError (NotImplementedError)
bent = RecumbentBike.new
```

また、このような実装は仕様のドキュメントの役割も果たす。

## 6.5 スーパークラスとサブクラス間の結合度を管理する

あとは`spares`を`Bicycle`に移動させれば、`Bicycle`への抽象の移動は全て完了となる。  
[`6_5_1.rb`](./6_5_1.rb)と[`6_5_2.rb`](./6_5_1.rb)はどちらも`spares`を`Bicycle`を移動させており、どちらも同じように動く。  
だが前者はオブジェクト間の結合が強く、後者は弱い。当然、結合は弱いほうが望ましい。

まず`6_5_1.rb`を見てみる。

```ruby
# 6_5_1.rb
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args={})
    @size = args[:size]
    @chain = args[:chain] || default_chain
    @tire_size = args[:tire_size] || default_tire_size
  end

  def spares
    {chain: chain, tire_size: tire_size}
  end

  def default_chain
    '10-speed'
  end

  def default_tire_size
    raise NotImplementedError
  end
end

class RoadBike < Bicycle
  attr_reader :tape_color

  def initialize(args)
    @tape_color = args[:tape_color]
    super(args)
  end

  def spares
    super.merge(tape_color: tape_color)
  end

  def default_tire_size
    '23'
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

  def default_tire_size
    '2.1'
  end
end

road_bike = RoadBike.new(size: 'M', tape_color: 'red')
p road_bike.size # "M"
p road_bike.spares # {:chain=>"10-speed", :tire_size=>"23", :tape_color=>"red"}

mountain_bike = MountainBike.new(size: 'S', front_shock: 'Manitou', rear_shock: 'Fox')
p mountain_bike.size # "S"
p mountain_bike.spares # {:chain=>"10-speed", :tire_size=>"2.1", :rear_shock=>"Fox"}
```

この構造では、それぞれのサブクラスが`initialize`と`spares`で明示的に`super`を送っている。  
これは、サブクラスがロジックを持ってしまっていることを意味する。スーパークラスの`initialize`や`spares`がどのように動作して何を返すのかを知っており、その知識に依存している。  
もしロジックに変更があった場合、サブクラスにその影響が及ぶ可能性が高い。  
例えば、全てのサブクラスが`super`を送っているので、スーパークラスの`initialize`や`spares`の挙動が変われば、その影響は全てのサブクラスに及ぶ。スーパークラスとサブクラスが分かちがたく結びついており、ひとつのオブジェクトのようになってしまっている。

ロジックをスーパークラスに持たせて結合を弱めたのが、`6_5_2.rb`。  
サブクラスに`initialize`や`spares`を定義するの止めている。  
そのため、サブクラスのインスタンスにそれらのメッセージを送ったときは、スーパークラスのメソッドが応答する。  
そしてそのスーパークラスのメソッドが、必要に応じてサブクラスにメッセージ（`post_initialize`や`local_spares`）を送ることで、サブクラス固有の情報を取得するようになっている。

```ruby
# 6_5_2.rb
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args={})
    @size = args[:size]
    @chain = args[:chain] || default_chain
    @tire_size = args[:tire_size] || default_tire_size
    post_initialize(args)
  end

  def spares
    {chain: chain, tire_size: tire_size}.merge(local_spares)
  end

  def default_tire_size
    raise NotImplementedError
  end

  # subclasses may override

  def post_initialize(args)
    nil
  end

  def local_spares
    {}
  end

  def default_chain
    '10-speed'
  end
end

class RoadBike < Bicycle
  attr_reader :tape_color

  def post_initialize(args)
    @tape_color = args[:tape_color]
  end

  def local_spares
    {tape_color: tape_color}
  end

  def default_tire_size
    '23'
  end
end

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def post_initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
  end

  def local_spares
    {rear_shock: rear_shock}
  end

  def default_tire_size
    '2.1'
  end
end

road_bike = RoadBike.new(size: 'M', tape_color: 'red')
p road_bike.size # "M"
p road_bike.spares # {:chain=>"10-speed", :tire_size=>"23", :tape_color=>"red"}

mountain_bike = MountainBike.new(size: 'S', front_shock: 'Manitou', rear_shock: 'Fox')
p mountain_bike.size # "S"
p mountain_bike.spares # {:chain=>"10-speed", :tire_size=>"2.1", :rear_shock=>"Fox"}
```

この構造なら、サブクラスはスーパークラスの詳細について知らずに済む。サブクラスは自身の情報をスーパークラスに渡すだけであり、ロジックには関知しないし、スーパークラスがどのようなメソッドを持っているのかも知らない。スーパークラスからメッセージを送られたときに、それに応答すればよい。  
いつメッセージを送るのか、どのように使うのかは、スーパークラスだけが知っている。

サブクラスが何をするのかが分かりやすくなり、新しいサブクラスを作るのも簡単になった。

## 6.6 まとめ

継承によって、共通点と相違点の両方を持った複数の型を、上手く扱えるようになる。

具象クラスが3つ以上あると、抽象を特定しやすくなる。状況が許すなら、3つの具象クラスが出来るまでは、継承関係を作るのは待ったほうがよい。

適切に設計された継承は、仕様についての理解が浅い開発者でも、簡単にサブクラスを追加することが出来る。
この拡張性の高さが、継承の強み。
