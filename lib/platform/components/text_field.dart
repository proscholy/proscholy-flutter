import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/platform/mixin.dart';

class PlatformTextField extends StatelessWidget with PlatformWidgetMixin {
  final TextEditingController controller;
  final String placeholder;
  final EdgeInsetsGeometry padding;
  final Function(String) onSubmitted;

  const PlatformTextField({
    Key key,
    this.controller,
    this.placeholder,
    this.padding = const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget androidWidget(BuildContext context) {
    return Container(
      padding: padding,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: placeholder),
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  Widget iOSWidget(BuildContext context) {
    return Container(
      padding: padding,
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        padding: EdgeInsets.all(kDefaultPadding),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
