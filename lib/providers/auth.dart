// ignore_for_file: use_rethrow_when_possible

import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/http_exception.dart';

class Auth extends ChangeNotifier {
  String? _token;

  // ignore: unused_field
  String? _userId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    } else {
      return null;
    }
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment,) async {
    const String apiKey = 'AIzaSyD1els5AXYAEHAUclWF9o9xm1VbYEtlvQU';
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$apiKey';
    try {
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      var resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData["error"]["message"]);
      }
      _token = resData['idToken'];
      _userId = resData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(resData['expiresIn'])));
      autoLogout();
      notifyListeners();
      final SharedPreferences pref = await SharedPreferences.getInstance();
      final String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String()
      });
      pref.setString('userData', userData);
      /*pref.setString('token', _token);
      pref.setString('userId', _userId!);
      pref.setString('expiryDate', _expiryDate!.toIso8601String());
      autoLogout();*/
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    final SharedPreferences pref = await SharedPreferences.getInstance();
    /*pref.remove('token');
    //pref.setString('token', '');

    pref.setString('userId', '');
    pref.setString(
        'expiryDate', DateTime(2021, 1, 1, 0, 0, 0, 0, 0).toString());*/
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    pref.clear();
    notifyListeners();
  }

  autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final int timeToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }

  Future<bool> tryAutoLogin() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) {
      // Fluttertoast.showToast(msg: "userData");
      return false;
    }
    var extractedUserData =
        json.decode(pref.getString('userData')!) as Map<String, Object>;
    // final expiryDate = DateTime.parse(extractedUserData['expiryDate'].toString());
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'].toString());
    if (expiryDate.isBefore(DateTime.now())) {
      //Fluttertoast.showToast(msg: "expiryDate");
      return false;
    }

    /*_*/ /*token = pref.getString('token')!;
    _userId = pref.getString('userId')!;
    _expiryDate = expiryDate;*/
    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    _expiryDate = expiryDate;

    notifyListeners();
    autoLogout();
    return true;
  }
}
