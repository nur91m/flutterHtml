import '../services/globbingClient.dart';

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
      case OrderStatus.all:
        return "Все";
        break;
      default:
        return "Не известный статус";
    }
  }