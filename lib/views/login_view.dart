import 'package:flutter/material.dart';
import 'package:qnap/controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController(text: "salimcancontact@gmail.com");
  final TextEditingController _passwordController = TextEditingController(text: "123Salim");
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
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: "Şifre",
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        AuthState.login(_usernameController.text, _passwordController.text);
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
