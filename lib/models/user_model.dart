class AuthModel {
  int? loginStatus;
  String? loginMessage;
  String? fname;
  String? lname;
  String? photo;
  String? email;
  bool? tenant;
  String? token;
  String? password;
  int? userLevel;
  AuthModel(
      {this.loginStatus,
      this.loginMessage,
      this.fname,
      this.lname,
      this.photo,
      this.email,
      this.tenant,
      this.token,
      this.userLevel});

  AuthModel.fromJson(Map<String, dynamic> json) {
    loginStatus = json['login_status'];
    loginMessage = json['login_message'];
    fname = json['fname'];
    lname = json['lname'];
    photo = json['photo'];
    email = json['email'];
    tenant = json['tenant'];
    token = json['token'];
    password = json['password'];
    userLevel = int.tryParse(json['level']?.toString() ?? "1") ?? 1;
  }

  String get fullName => "$fname $lname";

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['login_status'] = loginStatus;
    data['login_message'] = loginMessage;
    data['fname'] = fname;
    data['lname'] = lname;
    data['photo'] = photo;
    data['email'] = email;
    data['tenant'] = tenant;
    data['token'] = token;
    data['level'] = userLevel;
    data['password'] = password;
    return data;
  }

  static AuthModel Function(dynamic) parser = (json) => AuthModel.fromJson(json);
}
