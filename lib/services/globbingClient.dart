import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

class GlobbingClient {
  static const String _mainUrl = "https://kz.globbing.com/ru/";
  static const String _loginUrl = "https://kz.globbing.com/ru/login/";
  static const String _inCountryUrl =
      "https://kz.globbing.com/ru/profile/my-orders/in-country/";
  static const String _email = "madina2030@list.ru";
  static const String _password = "madina90";

  String _cookie = "";
  String _token = "";

  List<Order> orders = [];

  bool _isAuthenticated = false;

  Future<bool> login() async {
    var response = await http.get(_mainUrl);
    if (response.statusCode == 200) {
      var htmlBody = html.parse(response.body);
      _setCookie(response);
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

  List<Order> fetchInCountryOrders() async {
    var response = await http.get(_inCountryUrl, headers: {'cookie': _cookie});
    if (response.statusCode == 200) {
      var htmlBody = html.parse(response.body);

      List<Future<http.Response>> pageLoads = [];

      //Get all pages count
      var liPageTags = htmlBody
          .querySelector("#order-tab div.clear-fix.pagination__out>ul")
          .children;
      var allPageCount = liPageTags.length >= 4
          ? int.parse(
              liPageTags[liPageTags.length - 2].children.first.innerHtml)
          : 0;

      


      void parseInCountryOrder(String pageUrl) {
        http.get(pageUrl, headers: {'cookie': _cookie}).then((res) {
          if (res.statusCode == 200) {
            htmlBody = html.parse(response.body);
            var aTags = htmlBody.querySelectorAll(
                "#inCountry-sale-orders>table>tbody>tr>td.track-number__col--out>a[title]");

            for (var aTag in aTags) {
              var order = Order();
              order.number = aTag.attributes['title'];
              order.url = aTag.attributes['href'];
              order.status = OrderStatus.inCountry;
              orders.add(order);
            }
          }
        });
      }

      parseInCountryOrder("$_inCountryUrl?page=1");
      
      int currentPage = 2;
      while (currentPage <= allPageCount) {
        var pageUrl = '$_inCountryUrl?page=$currentPage';
        parseInCountryOrder(pageUrl);
        currentPage++;
      }
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
}

class Order {
  String number;
  String url;
  OrderStatus status;

  Order({this.number, this.status, this.url});
}

enum OrderStatus { inCountry, added, atStore, onWay, recieved }

void main() async {
  GlobbingClient g = GlobbingClient();
  await g.login();
  g.fetchInCountryOrders();
}
