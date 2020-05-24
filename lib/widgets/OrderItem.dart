import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/getOrderDescription.dart';
import '../services/globbingClient.dart';

class OrderItem extends StatelessWidget {
  final Order order;

  OrderItem({@required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Color.fromRGBO(0, 168, 224, 0.1),
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

  
}
