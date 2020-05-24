import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

class GlobbingClient {
  static const String _mainUrl = "https://kz.globbing.com/ru";
  static const String _loginUrl = "https://kz.globbing.com/ru/login";
  static const String _inCountryStoreUrl =
      "https://kz.globbing.com/ru/profile/my-orders/in-country?";
  static const String _inCountryCustomsUrl =
      "https://kz.globbing.com/ru/profile/my-orders/in-country?customs=1&";

  static const String _onWay =
      "https://kz.globbing.com/ru/profile/my-orders/on-way?";
  static const String _atUsaStore =
      "https://kz.globbing.com/ru/profile/my-orders/in-warehouse?";
  static const String _added =
      "https://kz.globbing.com/ru/profile/my-orders/qr-orders?";
  static const String _received =
      "https://kz.globbing.com/ru/profile/my-orders/received?";

  static const String _email = "madina2030@list.ru";
  static const String _password = "madina90";

  String _cookie = "";
  String _token = "";

  bool _isAuthenticated = false;

  Future<bool> login() async {
    var response = await http.get(_mainUrl);
    if (response.statusCode == 200) {
      _setCookie(response);
      var htmlBody = html.parse(response.body);
      // Get token
      var tokenInputTag =
          htmlBody.querySelector("#user-login-form>input[name=_token]");
      _token = tokenInputTag.attributes["value"];

      // Sign in
      var request = http.MultipartRequest('POST', Uri.parse(_loginUrl))
        ..fields['email'] = _email
        ..fields['password'] = _password
        ..fields['redirect_to'] = ""
        ..fields['_token'] = _token;
      request.headers['cookie'] = _cookie;
      request.headers['content-type'] =
          "application/x-www-form-urlencoded; charset=UTF-8";

      var loginResponse = await request.send();
      if (loginResponse.statusCode == 200) {
        _setCookie(loginResponse);
        _isAuthenticated = true;
      }
    }

    return _isAuthenticated;
  }

  Future<List<Order>> fetchInCountryStoreOrders() async {
    return await _parseOrders(_inCountryStoreUrl);
  }

  Future<List<Order>> fetchInCountryCustomsOrders() async {
    return await _parseOrders(_inCountryCustomsUrl);
  }

  Future<List<Order>> fetchOnWayOrders() async {
    return await _parseOrders(_onWay);
  }

  Future<List<Order>> fetchAtUsaStoreOrders() async {
    return await _parseOrders(_atUsaStore);
  }

  Future<List<Order>> fetchAddedOrders() async {
    return await _parseOrders(_added);
  }

  Future<List<Order>> fetchReceivedOrders() async {
    return await _parseOrders(_received);
  }

  Future<List<Order>> fetchAllOrders() async {
    List<Future<List<Order>>> querries = [];
    querries.add(_parseOrders(_added));
    querries.add(_parseOrders(_inCountryStoreUrl));
    querries.add(_parseOrders(_inCountryCustomsUrl));
    querries.add(_parseOrders(_onWay));
    querries.add(_parseOrders(_atUsaStore));

    var ordersList = await Future.wait(querries);

    return ordersList.expand((list) => list).toList();
  }

  Future<List<Order>> _parseOrders(String url) async {
    OrderStatus orderStatus = getOrderStatus(url);
    var response = await http.get(url, headers: {'cookie': _cookie});
    if (response.statusCode == 200) {
      List<Order> orders = [];
      var htmlBody = html.parse(response.body);

      List<Future<void>> pageLoads = [];

      //Get all pages count
      var ulPageTags =
          htmlBody.querySelector("#order-tab div.clear-fix.pagination__out>ul");

      var allPageCount = 0;

      if (ulPageTags != null) {
        var liPageTags = ulPageTags.children;
        allPageCount = liPageTags.length >= 4
            ? int.parse(
                liPageTags[liPageTags.length - 2].children.first.innerHtml)
            : 0;
      }

      Future<void> parseOrderTable(String pageUrl) {
        return http.get(pageUrl, headers: {'cookie': _cookie}).then((res) {
          if (res.statusCode == 200) {
            htmlBody = html.parse(res.body);
            var aTags = htmlBody.querySelectorAll(
                "#order-tab table>tbody>tr>td.track-number__col--out>a[title]");

            for (var aTag in aTags) {
              var order = Order();
              order.number = aTag.attributes['title'];
              order.url = aTag.attributes['href'];
              order.status = orderStatus;
              orders.add(order);
            }
          }
        });
      }

      // Load and get orders from page #1
      pageLoads.add(parseOrderTable("${url}page=1"));

      // Load rest of the orders from other pages
      int currentPage = 2;
      while (currentPage <= allPageCount) {
        var pageUrl = '${url}page=$currentPage';
        pageLoads.add(parseOrderTable(pageUrl));
        currentPage++;
      }

      // Wait for all page loads
      await Future.wait(pageLoads);

      return orders;
    }
  }

  void _setCookie(http.BaseResponse response) {
    String rawCookie = response.headers['set-cookie'];
    var values = rawCookie.split(';');

    var cookie = "";
    for (var value in values) {
      var val = value.substring(value.indexOf(',') + 1);
      if (val.contains('__cfduid') ||
          val.contains('XSRF-TOKEN') ||
          val.contains('laravel_session') ||
          val.contains('lngId')) {
        cookie = cookie + val + ";";
      }
    }
    this._cookie = cookie;
  }

  OrderStatus getOrderStatus(String url) {
    switch (url) {
      case _inCountryCustomsUrl:
        return OrderStatus.inCountryCustoms;
        break;
      case _inCountryStoreUrl:
        return OrderStatus.inCountry;
        break;
      case _added:
        return OrderStatus.added;
        break;
      case _atUsaStore:
        return OrderStatus.atUsaStore;
        break;
      case _onWay:
        return OrderStatus.onWay;
        break;
      case _received:
        return OrderStatus.recieved;
        break;
      default:
        return OrderStatus.added;
    }
  }
}

class Order {
  String number;
  String url;
  OrderStatus status;

  Order({this.number, this.status, this.url});
}

enum OrderStatus {
  all,
  inCountry,
  inCountryCustoms,
  onWay,
  atUsaStore,
  added,
  recieved,
}

void main() async {
  GlobbingClient g = GlobbingClient();
  await g.login();
  var orders = await g.fetchAllOrders();
  var orders2 = await g.fetchAddedOrders();
  print(orders.first.number);
  print(orders2.first.number);
}
