
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qnap/models/app_setting.dart';


Future<AppSettingModel> loadSetting() async {
  
//  var rootDirectory=await pathProvider.getTemporaryDirectory();

final String response = await rootBundle.loadString('assets/settings.json');
final data =  jsonDecode(response);
return AppSettingModel.fromJson(data);
}
