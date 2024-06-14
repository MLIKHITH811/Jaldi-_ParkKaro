import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobileoffice/model/User.dart';
import 'package:mobileoffice/utils/Logger.dart';
import 'package:mobileoffice/model/AccessToken.dart';
import 'package:mobileoffice/model/MonthReservations.dart';
import 'package:mobileoffice/controller/UserController.dart';
import 'package:mobileoffice/exception/AuthException.dart';

class WebService {
  static const SERVER_ADDRESS = 'https://visp-parking-web-unix.azurewebsites.net';

  final API_ADDRESS = SERVER_ADDRESS + '/api';
  final STATIC_HEADERS =  { "Accept": "application/json", "Content-Type": "application/json" };

  Future<MonthReservations> getParkingMonth(String yearMonth) async {
    final response =
        await http.get(API_ADDRESS + '/calendar/$yearMonth', headers: await prepareHeaders());

    logResponse(response);

    if (response.statusCode == 200) {
      return MonthReservations.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load GET /calendar/$yearMonth');
    }
  }

  Future<Map<String, String>> prepareHeaders() async {
    var headers = Map.of(STATIC_HEADERS);
    var accessToken = await UserController.get().getAccessToken();
    if (accessToken != null) {
      headers["X-Access-Token"] =  accessToken;
    }

    return headers;
  }

  Future<void> postParking(String date) async {
    final response =
        await http.post(API_ADDRESS + '/calendar/$date/reservation', headers: await prepareHeaders());

    logResponse(response);
    if (isResponseSuccessful(response)) {
      return response;
    } else {
      throw Exception('Failed request');
    }
  }

  Future<void> postParkingNextReservations(String yearMonth, List<int> days) async {
    Map<String, dynamic> bodyMap = {
      'days': days
    };

    final response = await http.post(API_ADDRESS + '/calendar/$yearMonth/reservations', headers: await prepareHeaders(), body: json.encode(bodyMap));

    logResponse(response);
    if (isResponseSuccessful(response)) {
      return response;
    } else {
      throw Exception('Failed request');
    }
  }

  Future<void> deleteParking(String date) async {
    final response =
    await http.delete(API_ADDRESS + '/calendar/$date/reservation', headers: await prepareHeaders());

    logResponse(response);

    if (isResponseSuccessful(response)) {
      return response;
    } else {
      throw Exception('Failed request');
    }
  }

  Future<void> postFirebaseToken(String token) async {
    Map<String, dynamic> bodyMap = {
      'token': token,
      'platform': 'firebase',
    };

    final response = await  http.post(API_ADDRESS + '/users/me/notifiers', body: json.encode(bodyMap),headers: await prepareHeaders());

    logResponse(response);
    if (isResponseSuccessful(response)) {
      return;
    } else {
      throw Exception('Could not register push token');
    }
  }

//  Future<AccessToken> postAuth(String email, String password) async {
//    Map<String, dynamic> bodyMap = {
//      'email': email,
//      'password': password,
//    };
//
//    final response =
//      await http.post(API_ADDRESS + '/auth', headers: await prepareHeaders(), body: json.encode(bodyMap));
//
//    logResponse(response);
//    if (isResponseSuccessful(response)) {
//      return AccessToken.fromJson(json.decode(response.body));
//    } if (response.statusCode == 403) {
//      throw AuthException();
//    } else {
//      throw Exception('failure');
//    }
//  }

  Future<MyUser> getUser() async {
    final response = await http.get(API_ADDRESS + '/users/me', headers: await prepareHeaders());
    logResponse(response);

    if (isResponseSuccessful(response)) {
      return MyUser.fromJson(json.decode(response.body));
    } else if (response.statusCode == 403) {
      throw AuthException();
    } else {
      throw Exception('failure');
    }
  }

  Future<List<User>> getUsers() async {
    final response = await http.get(API_ADDRESS + '/users', headers: await prepareHeaders());
    logResponse(response);

    if (isResponseSuccessful(response)) {
      final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
      return parsed.map<User>((json) => User.fromJson(json)).toList();

      List body = json.decode(response.body);
      var users = body.map((item) {
        return User.fromJson(item);
      } );
      return users;
//      for (var value in list) {
//
//      }

      return body;
    } else if (response.statusCode == 403) {
      throw AuthException();
    } else {
      throw Exception('failure');
    }
  }

  Future<void> postParkingGuest(String date, String guestName) async {
    Map<String, dynamic> bodyMap = {
      'guest_name': guestName,
    };

    final response = await http.post(API_ADDRESS + '/calendar/$date/reservation_guest', headers: await prepareHeaders(), body: json.encode(bodyMap));

    logResponse(response);
    if (isResponseSuccessful(response)) {
      return response;
    } else {
      throw Exception('Failed request');
    }
  }

  bool isResponseSuccessful(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  void logResponse(http.Response response) {
    Logger.log('${response.request.method} ${response.request.url.toString()} => code:${response.statusCode}, BODY: \n ${response.body}');
  }
}