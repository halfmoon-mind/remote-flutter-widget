// https://github.com/halfmoon-mind/remote-flutter-widget/raw/main/lib/remote/counter_app1.rfw
// https://github.com/halfmoon-mind/remote-flutter-widget/raw/main/lib/remote/counter_app2.rfw

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rfw/rfw.dart';

void main() {
  runApp(
    const MaterialApp(
      home: RemoveView(),
    ),
  );
}

class RemoveView extends StatefulWidget {
  const RemoveView({super.key});

  @override
  State<RemoveView> createState() => _RemoveViewState();
}

class _RemoveViewState extends State<RemoveView> {
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  int _counter = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _runtime.update(
        const LibraryName(<String>['core', 'widgets']), createCoreWidgets());
    _runtime.update(const LibraryName(<String>['core', 'material']),
        createMaterialWidgets());

    _updateData();
    _updateWidgets();
  }

  void _updateData() {
    _data.update('counter', _counter.toString());
  }

  void _updateWidgets() async {
    final Directory home = await getApplicationSupportDirectory();
    const baseUrl =
        "https://github.com/halfmoon-mind/remote-flutter-widget/raw/main/lib/remote/";
    const firstFileName = "counter_app1.rfw";
    const secondFileName = "counter_app2.rfw";

    String targetFileName = firstFileName;

    // 항상 새로운 값으로 업데이트
    File targetFile = File(join(home.path, firstFileName));
    if (targetFile.existsSync()) {
      targetFile.deleteSync();
      targetFileName = secondFileName;
    }
    final client =
        await (await HttpClient().getUrl(Uri.parse('$baseUrl$targetFileName')))
            .close();
    await targetFile
        .writeAsBytes(await client.expand((element) => element).toList());
    _runtime.update(const LibraryName(<String>['main']),
        decodeLibraryBlob(await targetFile.readAsBytes()));
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Container(
        child: Text("NOT READY"),
      );
    }
    return RemoteWidget(
      runtime: _runtime,
      widget: const FullyQualifiedWidgetName(
        LibraryName(<String>['main']),
        'Counter',
      ),
      data: _data,
      onEvent: (eventName, eventArguments) {
        if (eventName == 'increment') {
          setState(() {
            _counter++;
            _updateData();
          });
        }
      },
    );
  }
}
