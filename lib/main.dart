import 'package:flutter/material.dart';
import './views/DashboardView.dart';
import './views/OrderListView.dart';
import './views/OrderDetailView.dart';

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
      initialRoute: "/orders",
      routes: {
        "/" : (context) => DashboardView(),
        "/orders" : (context) => OrderListView(),
        "/order-detail" : (context) => OrderDetailView(),
        // "/recipients" : (context) => OrderList(),
      },
    );
  }
}



