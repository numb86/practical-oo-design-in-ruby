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
