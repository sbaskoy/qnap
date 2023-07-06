import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class NewFileDialog extends StatefulWidget {
  final String path;
  const NewFileDialog({super.key, required this.path});

  @override
  State<NewFileDialog> createState() => _NewFileDialogState();
}

class _NewFileDialogState extends State<NewFileDialog> {
  bool isImage(String path) {
    final mimeType = lookupMimeType(path);

    return mimeType?.startsWith('image/') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Yeni dosya eklendi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: isImage(widget.path)
                ? Image.file(File(widget.path))
                : Padding(
                    padding: const EdgeInsets.all(8),
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
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                size: 50,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                path.basename(widget.path),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Sil"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Yükle"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
