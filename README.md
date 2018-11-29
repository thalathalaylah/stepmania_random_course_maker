# stepmania_random_course_maker
stepmaniaの難度指定ランダムコースを作成します
このコースは各曲ごとに倍速指定を計算し、適用します

#　動作が確認できた環境
- Mac OS High Sierra
- ruby 2.0 以上
- Stepmania 5.0.12

# How to use
1. git clone <this repository>
1. cd 
1. bundle install
1. .env.templateのSTEPMANIA_APPLICATION_DIRECTORYを設定
1. .env.templateを.envにリネーム
1. bundle exec ruby entry_point.rb course_example.rb

# コース設定方法
course_example.rbを参考にして設定してください
```course_example.rb
[
    {
        target_level: 10,
        sample_number: 8,
        target_bpm_ranges: [[400, 430], [380, 400], [300, 380]],
        course_name: 'RandomCourseMakerTestFor10',
        meter: 'Medium:10',
        scripter: 'Thalathalaylah'
    },
    {
        target_level: 11,
        sample_number: 4,
        target_bpm_ranges: [[400, 430], [380, 400], [300, 380]],
        course_name: 'RandomCourseMakerTestFor11',
        meter: 'Medium:11',
        scripter: 'Thalathalaylah'
    }
]

```
このファイルはコース情報を記述したハッシュの配列として構築されています。  
コース情報を記述するハッシュは以下の内容を含んでいる必要があります。

|key|type|value|
----|----|---- 
|target_level|int|コースを構成する曲の難易度を決定する|
|sample_number|int|コースがいくつの曲で構成されるかを決定する（8なら8曲）|
|target_bpm_ranges|Array[Array[Int]]|各曲の倍速設定を決定する|
|course_name|string|コース名|
|meter|string|コース難易度表記|
|scripter|string|コース作成者表記|

target_bpm_rangesは曲の設定bpmに1.0〜5.0の値を0.25刻みでかけた値のどれかが最初のレンジ(例では400〜430)に含まれていればその値を選び、含まれていなければ次の
レンジ(380〜400)に含まれている値、そこにも無ければ次のレンジ(300〜380)と見ていきます。

作成したコース情報ファイルを `bundle exec ruby entry_point.rb <作成したファイル名>` として読み込むことでコースを作成することができます。
