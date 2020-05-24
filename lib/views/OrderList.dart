import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/getOrderDescription.dart';
import '../widgets/OrderItem.dart';
import '../services/globbingClient.dart';

class OrderList extends StatefulWidget {
  OrderList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  GlobbingClient gClient;
  List<Order> orders = [];
  List<Order> receivedOrders = [];

  List<Order> filteredOrders = [];
  OrderStatus filter = OrderStatus.all;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    gClient = new GlobbingClient();
    gClient.login().then((isAuthenticated) {
      if (isAuthenticated) {
        // gClient.fetchReceivedOrders().then((value) {
        //   setState(() {
        //     receivedOrders = value;
        //   });
        // });
        gClient.fetchAllOrders().then((value) {
          setState(() {
            orders = value;
            filteredOrders = value;
          });
        });
      }
    });
  }

  void handleFilter(OrderStatus selectedFilter) {
    setState(() {

      filteredOrders = selectedFilter == OrderStatus.all ? orders :
          orders.where((order) => order.status == selectedFilter).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Мои посылки"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          // IconButton(
          //   icon: Icon(Icons.filter_list, size: 28,),
          //   onPressed: (){},
          // )
          PopupMenuButton(
            onSelected: handleFilter,
            icon: Icon(
              Icons.filter_list,
              size: 28,
            ),
            itemBuilder: (context) {
              return OrderStatus.values
                  .map((status) => PopupMenuItem(
                        value: status,
                        textStyle: TextStyle(fontSize: 14),
                        child: ListTile(
                          title: Text(getOrderDescription(status)),
                        ),
                      ))
                  .toList();
            },
          )
        ],
      ),
      body: filteredOrders.length != 0
          ? ListView.builder(
              itemBuilder: (context, index) {
                return OrderItem(order: filteredOrders[index]);
              },
              itemCount: filteredOrders.length,
            )
          : Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LayoutBuilder(
                  builder: (context, contraints) => SvgPicture.asset(
                    "assets/icons/empty.svg",
                    width: contraints.maxWidth * 0.4,
                  ),
                ),
                Text(
                  "Пусто",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }
}
