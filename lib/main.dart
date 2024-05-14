import 'package:flutter/material.dart';
import 'card_flip.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '卡牌翻轉動畫',
      home: Scaffold(
        body: CardFlip(),
      ),
    );
  }
}
