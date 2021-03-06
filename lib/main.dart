import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
//import 'package:interactive_webview/interactive_webview.dart';
import 'static_variable.dart' as stvb;

import 'package:flutter/foundation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
      home: FirstRoute(title: 'First route',),
    );
  }
}

/*void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}*/

class FirstRoute extends StatefulWidget {
  FirstRoute({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  FirstRouteStage createState() => FirstRouteStage();
}

//class stc {
//  static BuildContext context;
//}

class FirstRouteStage extends State<FirstRoute> {
  static LocalAuthentication auth = LocalAuthentication();
  static InAppWebViewController webView;
  static String initialUrl = "http://10.0.10.72:8080/";
  static BuildContext ctx;
  // static final _webView = new InteractiveWebView();

  int _selectedIndex = 0;
  bool checkFirst = false;
  FirstRouteStage() {
    //webView.reload();
  }
  @override
  void initState() {
    super.initState();
//    _webViewHandler();
  }

  /*_webViewHandler() async {
    _webView.loadUrl("http://10.0.10.72:8080/");

    _webView.didReceiveMessage.listen((message) {
      print("OK as well");
      print(message.data);
    });

    _webView.stateChanged.listen((state) {
      print("stateChanged ${state.type} ${state.url}");
    });

    final html = await rootBundle.loadString("assets/index.html", cache: false);
    _webView.loadHTML(html, baseUrl: initialUrl);
  }*/

  @override
  Widget build(BuildContext context) {

    ctx = context;
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),/*RaisedButton(
          child: Text('Open route'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondRoute()),
            );
          },
        ),*/
      ),
      bottomNavigationBar: Theme(
        data:  Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
            canvasColor: Colors.green,
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.white,
            textTheme: Theme
                .of(context)
                .textTheme
                .copyWith(caption: new TextStyle(color: Colors.yellow))),
        child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.business), title: Text('Business')),
          BottomNavigationBarItem(icon: Icon(Icons.school), title: Text('School')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.white,
        onTap: _onItemTapped,
      ),)
    );
  }
  final _widgetOptions = [
  Scaffold(
    appBar: new AppBar(
      title: const Text('WebView'),
    ),
    body: InAppWebView(
      initialUrl: initialUrl,
      initialHeaders: {

      },
      initialOptions: {

      },
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage){
        print(consoleMessage.message);
      },
      onLoadStart: (InAppWebViewController controller, String url) async {
        print("started $url");
        if ((initialUrl != url)) {
          controller.stopLoading();
          await Navigator.push(ctx, MaterialPageRoute(builder: (context) => WebViewRoute(webview_url: url)),);
          //controller.loadUrl(initialUrl);
          print("After push");
        } else {
          print("old url");
        }
      },
      onLoadStop: (InAppWebViewController controller, String url){
        controller.injectScriptCode("""
              console.log(`--------------------------------------------------`);
              window['token'] = '${stvb.static_variable.user_token}';
              console.log("OK I am work as well");
              console.log(window.token);
              console.log(`--------------------------------------------------`);
          """);
      },
    ),
  ),
    Scaffold(
      appBar: AppBar(
        title: Text('First Route tab 1'),
      ),
      body: Column(
        children: <Widget>[
          Text('Index 1: Business'),
          RaisedButton(
            child: Text('Open second'),
            onPressed: () {
              Navigator.push(
                ctx,
                MaterialPageRoute(builder: (context) => SecondRoute()),
              );
            },
          ),
          RaisedButton(
            child: Text('Check Biomatric'),
            onPressed:  () async {
              try{
                print("Click is handle");
                bool canCheckBiometrics = await auth.canCheckBiometrics;
                if(canCheckBiometrics) {
                  List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

                  print("Click is ended $canCheckBiometrics");
                  if (Platform.isIOS) {
                    if (availableBiometrics.contains(BiometricType.face)) {
                      print('Face id is available');
                    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
                      print('Torch id is available');
                    }
                  } else if(Platform.isAndroid){
                    print("Platform ${Platform.isAndroid}");
                    print(availableBiometrics);
                    if (availableBiometrics.contains(BiometricType.face)) {
                      print('Face scanner is available');
                    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
                      print('Finger print is available');
                      bool didAuthenticate =
                      await auth.authenticateWithBiometrics( localizedReason: 'Please authenticate your account' );
                      if(didAuthenticate){
                        print("Authentication is passed");
                      } else {
                        print("Authentication is not passed");
                      }
                    } else {
                      print('Finger print is not available');
                      const androidStrings = const AndroidAuthMessages(
                          cancelButton: 'cancel',
                          goToSettingsButton: 'settings',
                          goToSettingsDescription: 'Please set up your Finger Print.');
                      await auth.authenticateWithBiometrics(
                          localizedReason: 'Please authenticate to show account balance',
                          useErrorDialogs: false,
                          androidAuthStrings: androidStrings);
                    }
                  }
                }  else {
                  print("Cannot check biometric");
                }
              } on PlatformException catch(e) {
                print("Error: ");
                print(e);
                if(e.code == auth_error.notAvailable){
                  print('Not available');
                }
              }
            },
          ),
        ],
      ),
    ),
    Scaffold(
      appBar: AppBar(
        title: Text('First Route tab 2'),
      ),
      body: Column(
        children: <Widget>[
          Text(new DBCrypt().hashpw("hellobcrypt",new DBCrypt().gensaltWithRounds(10))),
          RaisedButton(
              onPressed: () {
                final text = "Hello from Native!!!";
//                _webView.evalJavascript("test('$text')");
              },
              child: Text("Send to WebView")
          ),
        ],
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

    });
    print("You choose on  $_selectedIndex tap");
  }
}

class SecondRoute extends StatefulWidget {
  SecondRoute({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  SecondRouteStage createState() => SecondRouteStage();
}

class SecondRouteStage extends State<SecondRoute> {
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu',
          onPressed: (){
            print("This is menu bar");
            handleShowDrawer();
          },
        ),
        title: Text('Second Route'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: (){
              print("This is search button");
            }
          ),
        ],
      ),
      body: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to first'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ThirdRoute()),);
              },
              child: Text('Open third'),
            ),

          ]
        )
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the Drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }

  handleShowDrawer(){
    _key.currentState.openDrawer();

    setState(() {
      ///DO MY API CALLS
    });

  }
}

class ThirdRoute extends StatefulWidget {
  ThirdRoute({Key key,}) : super(key: key);

  @override
  ThirdRouteState createState() => ThirdRouteState();
}

class ThirdRouteState extends State<ThirdRoute> {
  static String initialUrl = "https://flutter.dev/";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  var news = [];
  InAppWebViewController webView;
  ThirdRouteState(){

  }
  @override
  void initState() {
    super.initState();
    if(mounted) {
      getNews();
    }
  }
  Future<Null>  getNews(){
    var d = new DateTime.now();
    print(d.toString().split(" ")[0]);
    var url = 'https://newsapi.org/v2/everything?q=bitcoin&from=${d.toString().split(" ")[0]}&sortBy=publishedAt&apiKey=026f82c0df634de9a0b6a88f59d63641';
    return http.get(url).then((http.Response res){
      print("Data: ${res.body}");
      print("Length: ${news.length}");
      setState(() {
        news = jsonDecode(res.body)['articles'];
        print("Length: ${news.length}");
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Third Route"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Scaffold(
              body: InAppWebView(
                initialUrl: initialUrl,
                initialHeaders: {

                },
                initialOptions: {

                },
                onWebViewCreated: (InAppWebViewController controller) {
                  webView = controller;
                },
                onLoadStart: (InAppWebViewController controller, String url) async {
                  if ((initialUrl != url)) {
                    controller.stopLoading();
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewRoute(webview_url: url)),);
                    controller.loadUrl(initialUrl);
                  }
                },
              )
            ),
            Scaffold(
              body: RefreshIndicator(
                key: _refreshIndicatorKey,
                child:  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            Center(child: (news.length <= 0)?CircularProgressIndicator():Text('')),
                            StaggeredGridView.countBuilder(
                              crossAxisCount: 1,
                              itemCount: news.length,
                              itemBuilder: (context, index) {
                                return Card(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          '${news[index]['author']}',
                                          style: new TextStyle(
                                            fontSize: 25.0,
                                          ),
                                        ),
                                        FadeInImage.assetNetwork(
                                          placeholder: "images/ic_loader.gif",
                                          image: '${news[index]['urlToImage']}',
                                        ),
                                        /*Stack(
                                        children: <Widget>[
                                          Center(child: Image.asset("images/ic_loading.gif") *//*CircularProgressIndicator()*//*),
                                          Center(child: Icon(Icons.image, color: Colors.grey,), heightFactor: 10.65,),
                                          Center(
                                            child: Image.network(
                                              '${news[index]['urlToImage']}',
                                            ),
                                          ),
                                        ],
                                      ),*/
                                        Text('${news[index]['content']}',),
                                      ],
                                    )
                                );
                              },
                              staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                              mainAxisSpacing: 0.0,
                              crossAxisSpacing: 1.0,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                onRefresh: getNews,
              )
            ),
            Scaffold(
                body: Text("Right"),
            ),
          ]
        ),
      ),
    );
  }

}


class WebViewRoute extends StatefulWidget {
  WebViewRoute({Key key, @required this.webview_url}) : super(key: key);
  final String webview_url;

  @override
  WebViewRouteStage createState() => WebViewRouteStage();
}

class WebViewRouteStage extends State<WebViewRoute> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  @override
  Widget build(BuildContext context) {
    String initialUrl = widget.webview_url;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Web_View"),
      ),
      body: InAppWebView(
        initialUrl: initialUrl,
        initialHeaders: {

        },
        initialOptions: {

        },
        onWebViewCreated: (InAppWebViewController controller) {
          webView = controller;
        },
        onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage){
          print(consoleMessage.message);
        },
        onLoadStart: (InAppWebViewController controller, String url) async {
          print("Old: " + initialUrl);
          print("New: " + url);
          if ((initialUrl != url)) {
            controller.stopLoading();
            await Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewRoute(webview_url: url)),);
            //controller.loadUrl(initialUrl);
          } else {
            print("old url");
          }
        },
        onLoadStop: (InAppWebViewController controller, String url){
          controller.injectScriptCode("""
              console.log(`--------------------------------------------------`);
              window['token'] = '${stvb.static_variable.user_token}';
              console.log("OK I am work as well");
              console.log(window.token);
              console.log(`--------------------------------------------------`);
          """);
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          setState(() {
            this.progress = progress/100;
          });
        },
      ),
    );
  }

}



