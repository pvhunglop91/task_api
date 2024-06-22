import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_api_flutter/constants/app_constant.dart';
import 'package:task_api_flutter/services/local/shared_prefs.dart';
import 'package:task_api_flutter/services/remote/body/change_password_body.dart';
import 'package:task_api_flutter/services/remote/body/login_body.dart';
import 'package:task_api_flutter/services/remote/body/new_password_body.dart';
import 'package:task_api_flutter/services/remote/body/register_body.dart';

abstract class ImplAuthServices {
  Future<http.Response> sendOtp(String email);
  Future<http.Response> register(RegisterBody body);
  Future<http.Response> login(LoginBody body);
  Future<http.Response> postForgotPassword(NewPasswordBody body);
  Future<http.Response> changePassword(ChangePasswordBody body);
}

class AuthServices implements ImplAuthServices {
  @override
  Future<http.Response> sendOtp(String email) async {
    const url = AppConstant.endPointOtp;

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${null}',
      },
      body: jsonEncode({'email': email}),
    );
    return response;
  }

  @override
  Future<http.Response> register(RegisterBody body) async {
    const url = AppConstant.endPointAuthRegister;

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${null}',
      },
      body: jsonEncode(body.toJson()),
      //encode de day len 1 cai map
    );
    return response;
  }

  @override
  Future<http.Response> login(LoginBody body) async {
    const url = AppConstant.endPointLogin;

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${null}',
      },
      body: jsonEncode(body.toJson()),
    );
    return response;
  }

  @override
  Future<http.Response> postForgotPassword(NewPasswordBody body) async {
    const url = AppConstant.endPointForgotPassword;

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${null}',
      },
      body: jsonEncode(body.toJson()),
    );
    return response;
  }

  @override
  Future<http.Response> changePassword(ChangePasswordBody body) async {
    const url = AppConstant.endPointChangePassword;

    http.Response response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs.token}',
      },
      body: jsonEncode(body.toJson()),
    );
    return response;
  }
}
