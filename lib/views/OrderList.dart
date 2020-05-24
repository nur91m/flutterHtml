import 'package:flutter/material.dart';
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
          });
        });
      }
    });
  }

  void handleFilter(selectedFilter) {
    print(selectedFilter);
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
            icon:Icon(Icons.filter_list, size: 28,),
            itemBuilder: (context) {
              return OrderStatus.values
                  .map((status) => PopupMenuItem(                    
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
      body: ListView.builder(
        itemBuilder: (context, index) {
          return OrderItem(order: orders[index]);
        },
        itemCount: orders.length,
      ),
    );
  }
}
