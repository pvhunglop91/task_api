class LoginBody {
  String? email;
  String? password;

  LoginBody();

  factory LoginBody.fromJson(Map<String, dynamic> json) => LoginBody()
    ..email = json['email'] as String?
    ..password = json['password'] as String?;

  // LoginBody.fromJson(Map<String, dynamic> map) {
  //   email = map['email'];
  //   password = map['password'];
  // }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
