import 'package:flutter/material.dart';
import '../services/globbingClient.dart';

class OrderDetailView extends StatefulWidget {
  @override
  _OrderDetailViewState createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  @override
  Widget build(BuildContext context) {
    Order order = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(order.number),
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: Text("OrderDetail view"),
        ),
      ),
    );
  }
}
