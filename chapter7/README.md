# 第7章 モジュールでロールの振る舞いを共有する

この章では、複数のオブジェクトにロール（役割）を共有させる方法を学ぶ。  
また、継承やロールによって振る舞いを共有する際の適切な書き方についても触れる。

## 7.1 ロールを理解する

この節では、隠れたロールをどうやって浮かび上がらせるか、そしてロールをオブジェクトにどうやって持たせるかを見ていく。  
単にロールを持たせるだけでなく、依存関係は最小になるように注意を払う。

第5章に出てきた`Preparer`ダックタイプはロールである。`Preparer`として振る舞っているオブジェクトは、どれも同じ役割を共有している。  
だが`Preaprer`というロールを担うために必要なのは`prepare_trip`というメソッドを持つことだけであり、メソッドの中身は関係ない。

`Preparer`のようにメソッド名だけを共有するのではなく、特定の振る舞いを共有するロールも多い。  
振る舞いを共有させるための仕組みは多くのオブジェクト指向言語が持っており、Ruby には「モジュール」という仕組みが用意されている。

モジュールは継承と同じような機能で、あるオブジェクトがメッセージを受け取ったときにそのメッセージに応答することが出来なければ、そのメッセージをモジュール内に定義されたメソッドに委譲する。  
そのため、オブジェクトがモジュールをインクルードすると、オブジェクトはモジュールに定義されたメソッドも使えるようになる。  
これは、複数のオブジェクトに振る舞いを共有させるのに適した仕組みではあるが、上手く使わないと管理が難しくなる。  
オブジェクトが持っている振る舞いが増えることで、設計が複雑さを増していくためである。

例を示しながら、ロールの共有をどのように管理すべきか見ていく。  
最初の実装では、まだロールは発見されていない。  
それを段階的に改善していくことで、ロールを見出し、そのロールをモジュールによって共有させるようにする。

旅行のスケジュールが題材。  
旅行には自転車、整備士、自動車、の3つの要素が必要なので、それぞれのスケジュールを確認する機能を作ろうとしている。  
稼働中かどうかを確認するだけでは不十分で、「リードタイム」も確保しないといけない。「リードタイム」とは休息やメンテナンスのことで、要素によって期間は異なる。  
3つの要素のクラス名とリードタイムは以下の通り。

- Bicycle
  - 1日間
- Mechanic
  - 4日間
- Vehicle
  - 3日間

例えば`Bicycle`は前回の旅行が`5月18日`に終わったとすると、リードタイムを1日置いて、`5月20日`から次の旅行に参加できる。

スケジュールを管理するクラスとして`Schedule`を作り、それは`scheduled?`メソッドを持つ。  
このメソッドに`target`、`starting`、`ending`を渡すことで、`target`が`starting`から`ending`の期間にスケジュールされているかどうかを確認できる。  
この機能は確かに`Schedule`が責任を持つことであり、このメソッドに問題はない。

問題は、`target`がスケジュール可能かどうかを知る機能。
これは、スケジュールされているかどうかの情報だけでは不十分であり、`target`のリードタイムも考慮しないといけない。そしてリードタイムは、クラス毎に異なる。

最初の実装では、リードタイムを把握する責任も`Schedule`に背負わせ、このクラスに`schedulable?`メソッドを持たせた。  
そして、このメソッドがそれぞれのリードタイムを全て知っているようにしてしまった。`schedulable?`の内部で`target.class`をチェックし、クラスごとに正しいリードタイムを返す。

これは、`Schedule`が知識を持ち過ぎている。リードタイムはそれぞれのクラスが持つべき知識であり、`Schedule`クラスはそれらのクラスにメッセージを送る形にすべき。  
つまり`target.class`によってクラスを確認するのではなく、`target.lead_day`というメッセージを送るようにする。

そしてこれは、ダックタイプである。`target`のクラスが`Bicycle`なのか`Mechanic`なのか`Vehicle`なのかは問わない。`target`はただ、`lead_day`というインターフェースさえ持っていればよい。このダックタイプを`schedulable`と呼ぶことにする。  
全ての`target`は`Schedulable`ロールを担っている、とも言える。

`Schedule`が特定のクラスに依存しなくなったことで、コードが改善された。だがまだ不必要な依存が残っている。  
それは、スケジュールについて問い合わせを行うオブジェクトの、`Schedule`クラスへの依存。  
`Bicycle`オブジェクトのスケジュールを確認するのに、`Bicycle`オブジェクトではなく`Schedule`にメッセージを送らなければならない。このことで、`Schedule`クラスについて知っていなければならず、不要な依存が発生してしまっている。  
**オブジェクトは、自身の振る舞いは自身で持つべき。**  
この例でも、`target`がスケジュール可能かどうかは、`Schedule.schedulable?`ではなく`target.schedulable?`で確認できるようにすべき。そうすることで、`target`がスケジュール可能かどうか知りたいオブジェクトは、ただ`target`のことさえ知っていればよく、`Schedule`についての知識という余計な依存を持たずに済む。

`target`とは`Schedulable`ロールのことなので、このロールのインターフェースに`schedulable?`メソッドを追加する。

`Schedulable`にどのような振る舞いを持たせるのか整理するために、まずは任意の具象クラス（今回は`Bicycle`クラス）に`schedulable?`メソッドを実装する。  
そのあとで、`Schedulable`を担う全てのオブジェクトが`schedulable?`メソッドを使える形に実装し直すことにする。

以下のコードでは、`Bicycle`に`schedulable?`メソッドを持たせることで、`Bicycle`がスケジュール可能かどうかを`Bicycle`に直接聞けるようになった。

```ruby
# 7_1_1.rb
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
```

`Bicycle`がスケジュール可能なのか知りたいオブジェクト（上記の例では「トップレベル＝`main`オブジェクト」）は、`Schedule`について知らなくて済むようになった。不要な依存関係を消すことが出来た。

実装すべき機能が分かったので、次は、`schedulable?`を抽象化して`Mechanic`や`Vehicle`からも利用できるようにする。  
そのために、`Schedulable`モジュールを実装する。

```ruby
# 7_1_2.rb
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
```

`schedulable?`と`scheduled?`を`Schedulable`モジュールに移したことで、このモジュールをインクルードしたオブジェクトなら誰でも、`Schedulable`ロールを担えるようになった。  
コードを複製することなく、ロールを共有できる。

また、`Schedulable`の`schedule`メソッドに、`Schedule`クラスへの依存を隔離することが出来た。  
`Schedule`が`schedulable?`メソッドを持っていた頃は、スケジュールを知りたい全てのオブジェクトが`Schedule`クラスについて知らねばならず、依存が散らばってしまう構成になっていた。  
だが今では、`Schedule`クラスの知識を知らなければならないのは`Schedulable`モジュールだけになった。

そして、`lead_days`についてはテンプレートメソッドパターンを使うことで、各`Schedulable`オブジェクトが`lead_days`を上書きして特化することが出来るようになった。

以下のコードでは、`Mechanic`と`Vehicle`に`Schedulable`をインクルードさせて、`schedulable?`メソッドを使えるようにしている。

```ruby
# 7_1_3.rb
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

m = Mechanic.new
# This Mechanic is not scheduled between 2018-05-14 and 2018-05-25
m.schedulable?(starting, ending)

v = Vehicle.new
# This Vehicle is not scheduled between 2018-05-15 and 2018-05-25
v.schedulable?(starting, ending)
```

## 7.2 継承可能なコードを書く

継承構造を作っていくときに気をつけるべきこと。

抽象を絞り込む際には、細心の注意を払う。  
抽象化に失敗してしまうと、使いづらいオブジェクトになってしまう。  
`A`というスーパークラスを継承するサブクラス`B`があるとき、`B`は、`A`のインターフェースを全て満たしている必要がある。`A`が応答できるメッセージは全て、`B`も応答できなければならない。応答できなかったり、返す値の種類が`A`と違っていたりする場合は、抽象化に失敗している。  
このようなオブジェクトは使いづらいし、扱うために特別な知識が必要になる。「`B`は`A`を継承しているが`A`と同じようには扱えない」という知識を、開発者に要求する。  
`B`はもはや`A`のサブクラスとは言い難いものであり、このようなオブジェクトが混じっていると階層構造全体が疑わしくなり、信頼できなくなってしまう。

テンプレートメソッドパターンを使うことで、抽象と具象を分離しやすくなるし、スーパークラスとサブクラスを疎結合に保ちやすくなる。  
しかし、階層構造が深くなってしまうと、テンプレートメソッドパターンを使うのが難しくなる。  
深い階層構造は他にも、依存するオブジェクトが増えてメンテナンスコストが高くなり、変更に弱くなるという問題を抱えている。  
そのため、階層構造は浅く保つべき。

## 7.3 まとめ

共通のロールを担わせるために振る舞いを共有させたい場合 Ruby では「モジュール」を使う。

クラスにモジュールをインクルードさせると、スーパークラスを継承したとき同じように、応答できるメッセージが増える。  
そのため、テンプレートメソッドパターンのように、継承のときと同じテクニックやパターンを使うことが出来る。

スーパークラスを継承した場合は、スーパークラスのインターフェースを全て満たさなければならない。そうでないサブクラスが発生してしまう場合は、抽象と具象を上手く分離できていない。  
同じように、モジュールをインクルードしたオブジェクトは、モジュールのインターフェースを満たしていないといけない。
つまり、「派生型は上位型と置換可能でなければならない」。この原則を守れていない場合、抽象化に失敗している。
