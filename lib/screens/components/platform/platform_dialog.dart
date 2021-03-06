import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/theme.dart';
import 'package:zpevnik/utils/platform.dart';

class PlatformDialog extends StatelessWidget with PlatformWidgetMixin {
  final String title;
  final String initialValue;
  final String submitText;
  final Function(String) onSubmit;

  const PlatformDialog({Key key, this.title, this.initialValue, this.onSubmit, this.submitText = 'Vytvořit'})
      : super(key: key);

  @override
  Widget androidWidget(BuildContext context) {
    final textFieldController = TextEditingController()..text = initialValue;

    return AlertDialog(
      title: Text(title),
      content: Container(
        child: TextField(
          decoration: InputDecoration(border: InputBorder.none, hintText: 'Název'),
          controller: textFieldController,
        ),
      ),
      actions: [
        TextButton(
          child: Text('Zrušit', style: AppTheme.of(context).bodyTextStyle.copyWith(color: Colors.red)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // fixme: don't know better way to do it now, but there must be
        ChangeNotifierProvider.value(
          value: textFieldController,
          child: Consumer<TextEditingController>(
            builder: (context, controller, _) => TextButton(
              child: Text(submitText),
              onPressed: controller.text.isEmpty
                  ? null
                  : () {
                      onSubmit(controller.text);
                      Navigator.of(context).pop();
                    },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget iOSWidget(BuildContext context) {
    final textFieldController = TextEditingController()..text = initialValue;

    return CupertinoTheme(
      data: AppTheme.of(context).cupertinoTheme, // fixme: is set again, because it is lost somewhere
      child: CupertinoAlertDialog(
        title: Text(title),
        content: Container(child: CupertinoTextField(placeholder: 'Název', controller: textFieldController)),
        actions: [
          TextButton(
            child: Text('Zrušit', style: AppTheme.of(context).bodyTextStyle.copyWith(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // fixme: don't know better way to do it now, but there must be
          ChangeNotifierProvider.value(
            value: textFieldController,
            child: Consumer<TextEditingController>(
              builder: (context, controller, _) => TextButton(
                child: Text(submitText,
                    style: AppTheme.of(context).bodyTextStyle.copyWith(
                        color: controller.text.isEmpty ? AppTheme.of(context).textColor.withAlpha(0x77) : null)),
                onPressed: controller.text.isEmpty
                    ? null
                    : () {
                        onSubmit(controller.text);
                        Navigator.of(context).pop();
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
