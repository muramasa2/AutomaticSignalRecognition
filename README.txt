MacBookPro OS Catalinaでは動作確認済み
【注意】
・Dockerの事前インストールが必要(Proxy環境下の場合は、Proxy設定も必要)

Docker for macの場合は
右上のDockerアイコン
⇒Preferences
⇒Resources
からMemory容量を4GB以上に変更しないとImageのbuildでエラーが出る。

・Pyaudioの事前インストールも必要
[Macの場合]
$ brew install portaudio
$ sudo env LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" pip install pyaudio



【使い方】
Mac or Linux環境に、このasr/ディレクトリを配置して、
sudo chmod -R 777 ./asr
で権限を変更した後

$ ./asr.sh <好きなDockerImage名> <好きなDockerContainer名> (これ以降はoptional)<録音ファイルにつける名前(〇〇.wavの〇の部分だけ)> <音声認識したいwavfile(一つでも複数でも可)>

ex1)input_audio/下の音声ファイルをすべて音声認識したい場合：
    ./asr.sh espnet asr_test
ex2)その場で録音した音声データを音声認識したい場合：
    ./asr.sh espnet asr_test example example.wav
ex3)その場で録音した音声データとあらかじめ録音した音声データすべてを音声認識したい場合：
./asr.sh espnet asr_test example (example.wav test1.wav test2.m4a)


で実行する。
すると録音したサンプルの音声の音声認識結果が表示される。

既に録音してある自前の音声データでやりたい場合は、
asr/input_audio/
の下に.wav , .m4a等の好きな音声データを置いてみてください(ほとんどの拡張子のものは問題ないはず)
現状は1文ずつでの認識しか対応していないので、自前のデータを用いる際は1文(「これはテストです」と発話した音声wavfile等)の音声データでお願いします。
(検証の際はinput_audio内にあるすべての音声ファイルを認識する仕様のため、サンプル音声をdir外に出すか削除してから行うことを推奨)