import 'package:flutter/cupertino.dart';

class TextCardOne extends StatelessWidget {
  String title;
  TextStyle style;
  TextCardOne({super.key, required this.title, style})
      : style = style ?? const TextStyle();

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: style,
    );
  }
}
