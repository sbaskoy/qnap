import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfile_picker/pfile_picker.dart';
import '../../../controllers/qnap_controller.dart';

import '../../../utils/encryption.dart';

class QnapLoginWidget extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final QnapController qnapController;
  const QnapLoginWidget({super.key, required this.onLoginSuccess, required this.qnapController});

  @override
  State<QnapLoginWidget> createState() => _QnapLoginWidgetState();
}

class _QnapLoginWidgetState extends State<QnapLoginWidget> {
  final TextEditingController _qnapFolderController = TextEditingController();
  final TextEditingController _localDesktopFolderController =
      TextEditingController(text: "C:\\Users\\GaniOtomasyon_005\\Desktop\\QnapTest");
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectFolder() async {
    try {
      String? path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Klasör seçiniz",
      );

      if (path != null) {
        _localDesktopFolderController.text = path;
      }
    } catch (ex) {
      log("$ex");
    }
  }

  void _loginAndStart() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        var path = decryptAESCryptoJS(_qnapFolderController.text, "qnap_key");
        String? d = jsonDecode(path)["path"];
        if (d != null) {
          await widget.qnapController.loginQnap();
          widget.qnapController.localPathChange(_localDesktopFolderController.text);
          widget.qnapController.qnapPathChange(d);
          widget.onLoginSuccess();
          return;
        }
        throw "Geçersiz kod";
      } catch (ex) {
        Get.showSnackbar(GetSnackBar(
          title: "Error",
          message: ex.toString(),
        ));
      }
    }
  }

  String? _validator(String? val) {
    if (val?.isEmpty ?? true) {
      return "Bu alan zorunludur";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Material(
        elevation: 20,
        borderRadius: BorderRadius.circular(50),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          width: size.width < 300
              ? size.width
              : size.width > 500
                  ? 500
                  : size.width * 0.5,
          height: size.height < 300 ? size.height : size.height * 0.6,
          child: Column(
            children: [
              const Text("Senkronize et"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _qnapFolderController,
                  decoration: const InputDecoration(
                    labelText: "Qnap klasör kodunuz",
                  ),
                  validator: _validator,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _localDesktopFolderController,
                  readOnly: true,
                  onTap: _selectFolder,
                  decoration: const InputDecoration(
                    labelText: "Eşleştirilecek klasör",
                  ),
                  validator: _validator,
                ),
              ),
              InkWell(
                onTap: _loginAndStart,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Qnap baglan",
                      style: TextStyle(color: theme.scaffoldBackgroundColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
