import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CenteredProgressIndicator extends StatelessWidget {
  final double? size;
  const CenteredProgressIndicator({super.key,  this.size});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Center(
      child: SpinKitFadingCircle(
        color: theme.primaryColor,
        size: size ?? 25.0,
      ),
    );
  }
}
