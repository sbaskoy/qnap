import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';

class HomeViewAppBar extends StatelessWidget {
  final VoidCallback onPressChangeToken;
  final VoidCallback onPressExit;
  const HomeViewAppBar({super.key, required this.onPressChangeToken, required this.onPressExit});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 75,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.primaryColor,
          ),
        ),
      ),
      child: StreamBuilder<AuthModel?>(
          stream: AuthState.authUserStream,
          builder: (context, snapshot) {
            var user = snapshot.data;
            if (user == null) return const SizedBox();
            return Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.photo ?? Constants.userAvatarImageUrl),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName),
                    Text(user.email ?? ""),
                  ],
                ),
                const Spacer(),
                TextButton(onPressed: onPressChangeToken, child: const Text("Token değiştir")),
                const SizedBox(width: 20),
                TextButton(onPressed: onPressExit, child: const Text("Çıkış yap"))
              ],
            );
          }),
    );
  }
}
