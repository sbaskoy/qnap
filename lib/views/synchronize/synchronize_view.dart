import 'package:flutter/material.dart';

import 'package:qnap/controllers/qnap_controller.dart';
import 'package:qnap/views/synchronize/synchronize_item.dart';

class QnapSynchronizeView extends StatefulWidget {
  final QnapController qnapController;
  const QnapSynchronizeView({super.key, required this.qnapController});

  @override
  State<QnapSynchronizeView> createState() => _QnapSynchronizeViewState();
}

class _QnapSynchronizeViewState extends State<QnapSynchronizeView> {
  List<String> localFiles = [];
  List<String> targetFiles = [];
  @override
  void initState() {
    super.initState();
    widget.qnapController.synchronize();
  }

  @override
  void dispose() {
    super.dispose();
    widget.qnapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Material(
      elevation: 20,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.8,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        border: Border(
                      bottom: BorderSide(),
                    )),
                    child: Text(
                      widget.qnapController.localPath!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: StreamBuilder(
                        stream: widget.qnapController.localFileListStream,
                        builder: (context, snapshot) {
                          var files = snapshot.data ?? [];
                          return ListView.builder(
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              var file = files[index];
                              return UploadFileItem(
                                file: file,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 2,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        border: Border(
                      bottom: BorderSide(),
                    )),
                    child: Text(
                      widget.qnapController.qnapPath!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: StreamBuilder(
                        stream: widget.qnapController.qnapFileListStream,
                        builder: (context, snapshot) {
                          var files = snapshot.data?.datas ?? [];

                          return ListView.builder(
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              var file = files[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(file.filename ?? ""),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
