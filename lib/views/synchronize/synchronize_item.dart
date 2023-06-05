import 'package:flutter/material.dart';
import 'package:qnap/widgets/centered_progress_indicator.dart';

import '../../controllers/qnap_controller.dart';

class UploadFileItem extends StatelessWidget {
  final QnapFileController file;
  const UploadFileItem({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: file.loading,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          var loading = snapshot.data ?? false;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(child: Text(file.filePath)),
                if (loading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CenteredProgressIndicator(
                      size: 15,
                    ),
                  )
              ],
            ),
          );
        });
  }
}
