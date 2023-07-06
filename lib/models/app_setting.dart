class AppSettingModel {
  late final String qnapUserName;
  late final String qnapPassword;
  late final String qnapAesKey;

  AppSettingModel(this.qnapUserName, this.qnapPassword, this.qnapAesKey);
  AppSettingModel.fromJson(json){
    qnapAesKey=json["qnap_aes_key"];
    qnapPassword=json["qnap_password"];
    qnapUserName=json["qnap_username"];
  }
}