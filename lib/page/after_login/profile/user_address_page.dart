import 'package:flutter/material.dart';
import 'package:juso/juso.dart';

class JusoScreen extends StatelessWidget {
  const JusoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주소 검색')),
      body: const JusoWebView(),
    );
  }
}
