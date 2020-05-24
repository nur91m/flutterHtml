import 'package:flutter/material.dart';

import 'services/globbingClient.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobbingClient gClient;
  List<Order> orders = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    gClient = new GlobbingClient();
    gClient.login().then((_) => {
          gClient.fetchAllOrders().then((value) {
            setState(() {
              orders = value;
            });
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Text(orders[index].number);
        },
        itemCount: orders.length,
      ),
    );
  }
}
