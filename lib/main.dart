import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
// import 'dart:convert';

void main() {
  runApp(const ClipboardUrlApp());
}

class ClipboardUrlApp extends StatelessWidget {
  const ClipboardUrlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'クリップボードURLデコーダー',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UrlDecoderPage(),
    );
  }
}

class UrlDecoderPage extends StatefulWidget {
  const UrlDecoderPage({super.key});

  @override
  State<UrlDecoderPage> createState() => _UrlDecoderPageState();
}

class _UrlDecoderPageState extends State<UrlDecoderPage> {
  final TextEditingController _urlController = TextEditingController();
  String _message = 'アプリを起動して最初の処理を実行します。';
  // final String _anchor = '#:~:text=';

  @override
  void initState() {
    super.initState();
    _processClipboard();
  }

  Future<void> _processClipboard() async {
    setState(() {
      _message = 'クリップボードからURLを読み取っています...';
    });

    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final rawUrl = clipboardData?.text;

      if (rawUrl == null || rawUrl.isEmpty) {
        setState(() {
          _message = 'クリップボードにテキストがありませんでした。';
          _urlController.text = '';
        });
        return;
      }

      // -----------------------------------------------------
      // URL全体に対してデコード処理を常に実行する
      // -----------------------------------------------------
      try {
        // URL全体をデコードし、パス内の日本語エンコードなどを解消
        final decodedWholeUrl = Uri.decodeComponent(rawUrl);

        setState(() {
          _message = 'デコードが完了しました。新しいURLがクリップボードにコピーされました。';
          _urlController.text = decodedWholeUrl;
        });

        // デコードされたURLをクリップボードに書き戻す
        await Clipboard.setData(ClipboardData(text: decodedWholeUrl));
        return;
      } catch (e) {
        // デコードに失敗した場合
        setState(() {
          _message = 'デコードできませんでした。URLに無効なエンコード文字列が含まれている可能性があります。';
          _urlController.text = rawUrl;
        });
        return;
      }
    } catch (e) {
      setState(() {
        _message = 'エラーが発生しました: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('クリップボードURLデコーダー'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(_message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                labelText: '処理結果',
                hintText: 'ここにデコードされたURLが表示されます',
              ),
              maxLines: null,
              readOnly: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _processClipboard,
        tooltip: 'クリップボードを再処理',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
