import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/getOrderDescription.dart';
import '../widgets/OrderItem.dart';
import '../services/globbingClient.dart';

class OrderListView extends StatefulWidget {
  OrderListView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OrderListViewState createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  GlobbingClient gClient;
  List<Order> orders = [];
  List<Order> receivedOrders = [];

  List<Order> filteredOrders = [];
  bool isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    gClient = new GlobbingClient();
    gClient.login().then((isAuthenticated) {
      if (isAuthenticated) {
        gClient.fetchReceivedOrders().then((value) {
          setState(() {
            receivedOrders = value;
          });
        });
        gClient.fetchAllOrders().then((value) {
          setState(() {
            orders = value;
            filteredOrders = value;
            handleFilter(OrderStatus.all);
          });
        });
      }
    });
  }

  void handleFilter(OrderStatus selectedFilter) {
    setState(() {
      if (selectedFilter == OrderStatus.all) {
        filteredOrders = orders;
      } else if (selectedFilter == OrderStatus.recieved) {
        filteredOrders = receivedOrders;
      } else {
        filteredOrders =
            orders.where((order) => order.status == selectedFilter).toList();
      }
    });
  }

  void searchHandler(String text) {
    setState(() {
      filteredOrders =
          orders.where((order) => order.number.contains(text)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text("Мои посылки")
            : TextField(
                cursorColor: Colors.white,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Поиск по номеру заказа...",
                    hintStyle: TextStyle(color: Colors.white70)),
                onChanged: searchHandler,
              ),
        actions: <Widget>[
          IconButton(
            icon: Icon(!isSearching ? Icons.search : Icons.clear),
            onPressed: () {
              setState(() {
                this.isSearching = !this.isSearching;
                if (!isSearching) {
                  handleFilter(OrderStatus.all);
                }
              });
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.filter_list, size: 28,),
          //   onPressed: (){},
          // )
          Visibility(
            visible: !isSearching,
            child: PopupMenuButton(
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
            ),
          )
        ],
      ),
      body: filteredOrders.length != 0
          ? ListView.builder(
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: OrderItem(order: filteredOrders[index]),
                  onTap: () {
                    Navigator.pushNamed(context, "/order-detail",arguments: filteredOrders[index]);
                  },
                );
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
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
