import 'package:flutter/material.dart';
import 'package:qnap/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool savePassword=false;
  bool hidePassword=true;

  @override
  void initState() {
    super.initState();
   
  }

  @override
  void didChangeDependencies() {
    
    super.didChangeDependencies();
     loadPrefs();
  }

  void loadPrefs()async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     _usernameController.text=prefs.getString("username") ?? "";
     _passwordController.text=prefs.getString("password") ?? "";
     setState(() {
       savePassword=prefs.getBool("save") ?? false;
     });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
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
                height: size.height < 300 ? size.height : size.height * 0.5,
                child: Column(
                  children: [
                     Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: "Kullanıcı adı",
                        ),
                      ),
                    ),
                     Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        obscureText: hidePassword,
                        controller: _passwordController,
                        decoration:  InputDecoration(
                          labelText: "Şifre",
                          suffix: InkWell(
                            onTap: (){
                            setState(() {
                              hidePassword=!hidePassword;
                            });
                            },
                            child: Icon(
                              hidePassword ? Icons.visibility_off : Icons.visibility
                            ),
                          )
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      title: Text("Şifreyi kaydet"),
                      value: savePassword, onChanged: (val){
                      setState(() {
                        savePassword=!savePassword;
                      });
                    }),
                    InkWell(
                      onTap: () {
                        AuthState.login(_usernameController.text, _passwordController.text,savePassword);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Giriş yap",
                            style: TextStyle(color: theme.scaffoldBackgroundColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
