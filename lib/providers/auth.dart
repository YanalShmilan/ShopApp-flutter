import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiaryDate;
  String? _userId;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId.toString();
  }

  String? get token {
    if (_expiaryDate != null &&
        _expiaryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return _token;
  }

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDn97EK4Ux4bNYjAgskW2QO-Ij6HWtF0dE");
    try {
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw responseData['error']['message'];
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiaryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signin(String email, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDn97EK4Ux4bNYjAgskW2QO-Ij6HWtF0dE");
    try {
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true
          }));

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw responseData['error']['message'];
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiaryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiaryDate": _expiaryDate!.toIso8601String()
      });
      await prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<bool> tryLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('userData') == false) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData').toString());
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiaryDate = DateTime.parse(extractedUserData['expiaryDate']);
    notifyListeners();
    return true;
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiaryDate = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    notifyListeners();
  }
}
