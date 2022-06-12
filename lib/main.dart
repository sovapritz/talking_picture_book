import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'ずかん'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<CardEntry> cardList = [];

  Future getData() async {
    http.Response response = await http.get(Uri.parse(
        "https://sovapritz.github.io/talking_picture_book/data.json"));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);

      for (var i = 0; i < data["entries"].length; i++) {
        var entry = data["entries"][i];
        CardEntry cardEntry = CardEntry(
          imageUrl: entry["imageUrl"],
          title: entry["title"],
          description: entry["description"],
          isAsset: false,
        );
        entries.add(cardEntry);
      }
      setState(() {
        cardList = entries;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getNetworkData();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: GridView.count(
                        crossAxisCount: 2,
                        primary: false,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
        childAspectRatio: 1.2,
                        shrinkWrap: true,
        //physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (var i = 0; i < cardList.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, bottom: 5.0, left: 5.0, right: 5.0),
              child: TopGridImageCard(
                cardEntry: cardList[i],
                cardList: cardList,
                index: i,
              ),
                            ),
                        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getNetworkData();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ), // This trailing comma
    );
  }
}

class CardEntry {
  final String imageUrl, title, description;
  final bool isAsset;
  CardEntry({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.isAsset,
  });
}

class TopGridImageCard extends StatelessWidget {
  final CardEntry cardEntry;
  final List<CardEntry> cardList;
  final int index;

  const TopGridImageCard({
    Key? key,
    required this.cardEntry,
    required this.cardList,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PagableDetailScreen(
                    cardEntry: cardEntry,
                    cardList: cardList,
                    index: index,
                  )),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3.0,
              blurRadius: 5.0,
            ),
          ],
          color: Theme.of(context).cardColor,
        ),
        child: Stack(
          children: <Widget>[
            FractionallySizedBox(
              // 親widgetのサイズから子widgetのサイズを指定できる
              heightFactor: 0.7, // 親widgetの半分のheightに
              widthFactor: 1, // 親widgetのwidthに合わせる
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                    ),
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: cardEntry.isAsset
                          ? AssetImage(cardEntry.imageUrl) as ImageProvider
                          : NetworkImage(cardEntry.imageUrl),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft, // 親widgetのbottomに合わせて配置
              child: FractionallySizedBox(
                heightFactor: 0.3,
                widthFactor: 1,
                child: Column(
                  children: [
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(12).copyWith(bottom: 0),
                      child: Text(
                        cardEntry.title,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PagableDetailScreen extends StatelessWidget {
  final CardEntry cardEntry;
  final List<CardEntry> cardList;
  final int index;
  final FlutterTts flutterTts = FlutterTts();

  PagableDetailScreen({
    Key? key,
    required this.cardEntry,
    required this.cardList,
    required this.index,
  }) : super(key: key);

  Future<void> _speak(CardEntry entry) async {
    await flutterTts.stop();
    await Future.delayed(const Duration(milliseconds: 400));
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(entry.title + "。。" + entry.description);
  }

  Future<void> _stop() async {
    await flutterTts.stop();
  }

  Widget _detailCard(BuildContext context, CardEntry entry) {
    return Card(
      margin: EdgeInsets.only(
        top: 10, //上
        right: 5, //右
        bottom: 50, //下
        left: 5, //左
      ),
      child: Column(
        children: [
        InteractiveViewer(
            panEnabled: false, // Set it to false
          boundaryMargin: EdgeInsets.all(100),
          minScale: 1.0,
          maxScale: 3,
            child: entry.isAsset
              ? Image.asset(
                    entry.imageUrl,
                  height: 400,
                  fit: BoxFit.fitWidth,
                )
              : Image.network(
                    entry.imageUrl,
                    //height: 400,
            fit: BoxFit.fitWidth,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Text(
              entry.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
          Container(
            padding:
                const EdgeInsets.only(top: 10, bottom: 20, left: 15, right: 15),
            child: Text(
              entry.description,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
          ),
        const Spacer(),
        ],
                      ),
                    );
                  }

  @override
  Widget build(BuildContext context) {
    _speak(cardEntry);
    final PageController pageController =
        PageController(initialPage: index, viewportFraction: 0.95);

    return Scaffold(
      appBar: AppBar(
        title: Text("せつめい"),
      ),
      body: Scrollbar(
        controller: pageController,
        thumbVisibility: true,
        child: PageView.builder(
          // store this controller in a State to save the carousel scroll position
          itemCount: cardList.length,
          controller: pageController,
          onPageChanged: (index) {
            _speak(cardList[index]);
          },
          itemBuilder: (BuildContext context, int itemIndex) {
            return _detailCard(context, cardList[itemIndex]);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
        tooltip: 'Home',
                child: const Icon(Icons.home),
      ), // This trailing comma
    );
  }
}
