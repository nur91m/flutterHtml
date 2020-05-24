import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  List<Order> receivedOrders = [];

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
          });
        });
      }
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
            return OrderItem(order: orders[index]);
          },
          itemCount: orders.length,
        ));
  }
}

class OrderItem extends StatelessWidget {
  final Order order;

  OrderItem({@required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: LayoutBuilder(
          builder: (context, constraints) => Container(
            padding: EdgeInsets.all(8),
            height: constraints.maxHeight,
            width: constraints.maxHeight,
            child: orderIcon(constraints),
          ),
        ),
        title: Text(
          order.number,
          style: TextStyle(
              fontSize: 20,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          getOrderDescription(order.status),
          style: TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  Widget orderIcon(BoxConstraints constraints) {
    switch (order.status) {
      case OrderStatus.inCountry:
        return Stack(
          children: <Widget>[
            SvgPicture.asset(
              "assets/icons/store.svg",
              color: Colors.lightGreen,
              height: 0.8 * constraints.maxHeight - 16,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(
                "assets/icons/kazakhstan.svg",
                height: 0.7 * constraints.maxHeight - 16,
              ),
            ),
          ],
        );
        break;
      case OrderStatus.atUsaStore:
        return Stack(
          children: <Widget>[
            SvgPicture.asset(
              "assets/icons/store.svg",
              color: Colors.indigo,
              height: 0.8 * constraints.maxHeight - 16,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(
                "assets/icons/usa.svg",
                height: 0.7 * constraints.maxHeight - 16,
              ),
            ),
          ],
        );
        break;
      case OrderStatus.added:
        return SvgPicture.asset(
          "assets/icons/added.svg",
          height: 0.7 * constraints.maxHeight - 16,
          alignment: Alignment.bottomRight,
          color: Colors.amber,
        );
        break;
      case OrderStatus.onWay:
        return Icon(
          Icons.airplanemode_active,
          size: constraints.maxHeight - 16,
          color: Colors.blue,
        );
        break;
      case OrderStatus.recieved:
        return SvgPicture.asset(
          "assets/icons/received.svg",
          height: 0.7 * constraints.maxHeight - 16,
          alignment: Alignment.bottomRight,          
        );
        break;
      case OrderStatus.inCountryCustoms:
        return SvgPicture.asset(
          "assets/icons/customs.svg",
          height: 0.7 * constraints.maxHeight - 16,
          alignment: Alignment.bottomRight,         
        );
        break;
      default:
        return Icon(
          Icons.pages,
          size: constraints.maxHeight - 16,
          color: Colors.grey,
        );
    }
  }

  String getOrderDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.inCountry:
        return "В сервис центре";
        break;
      case OrderStatus.atUsaStore:
        return "На складе в США";
        break;
      case OrderStatus.added:
        return "Добавлено в базу Globbing";
        break;
      case OrderStatus.recieved:
        return "Получена";
        break;
      case OrderStatus.inCountryCustoms:
        return "Прибыла на таможню";
        break;
      case OrderStatus.onWay:
        return "В пути";
        break;
      default:
        return "Не известный статус";
    }
  }
}
