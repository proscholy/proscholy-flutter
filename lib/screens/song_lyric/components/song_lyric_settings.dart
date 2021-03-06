import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/providers/settings_provider.dart';
import 'package:zpevnik/screens/components/bottom_form_sheet.dart';
import 'package:zpevnik/screens/components/highlightable_button.dart';
import 'package:zpevnik/screens/components/platform/platform_slider.dart';
import 'package:zpevnik/screens/song_lyric/components/selector_widget.dart';
import 'package:zpevnik/theme.dart';

class SongLyricSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accidentalsStyle = AppTheme.of(context).bodyTextStyle.copyWith(fontSize: 20, fontFamily: 'Hiragino Sans');

    return Consumer<SongLyric>(
      builder: (context, songLyric, _) => BottomFormSheet(
        title: 'Nastavení zobrazení',
        items: [
          _row('Transpozice', SizedBox(width: 96, child: _transpositionStepper())),
          _row(
            'Posuvky',
            SizedBox(
              width: 96,
              child: SelectorWidget(
                onSelected: (index) => songLyric.accidentals = index == 1,
                options: [
                  Text('#', style: accidentalsStyle, textAlign: TextAlign.center),
                  Text('♭', style: accidentalsStyle, textAlign: TextAlign.center)
                ],
                selected: songLyric.accidentals ? 1 : 0,
              ),
            ),
          ),
          _row(
            'Akordy',
            SizedBox(
              width: 96,
              child: SelectorWidget(
                onSelected: (index) => songLyric.showChords = index == 1,
                options: [
                  Icon(Icons.visibility_off),
                  Icon(Icons.visibility),
                ],
                selected: songLyric.showChords ? 1 : 0,
              ),
            ),
          ),
          _fontSizeSlider(context),
        ],
      ),
    );
  }

  Widget _row(String name, Widget widget) => Container(
        padding: EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(name), widget],
        ),
      );

  Widget _transpositionStepper() => Container(
        child: Consumer<SongLyric>(
          builder: (context, songLyric, _) => Row(
            children: [
              HighlightableButton(
                padding: EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
                icon: Icon(Icons.remove),
                highlightColor: AppTheme.of(context).highlightColor,
                onPressed: () => songLyric.changeTransposition(-1),
              ),
              SizedBox(
                width: 22,
                child: Text(songLyric.transposition.toString(), textAlign: TextAlign.center),
              ),
              HighlightableButton(
                padding: EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
                icon: Icon(Icons.add),
                highlightColor: AppTheme.of(context).highlightColor,
                onPressed: () => songLyric.changeTransposition(1),
              ),
            ],
          ),
        ),
      );

  Widget _fontSizeSlider(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) => Row(children: [
            RichText(
              text: TextSpan(text: 'A', style: AppTheme.of(context).bodyTextStyle),
              textScaleFactor: kMinimumFontSizeScale,
            ),
            Expanded(
              child: PlatformSlider(
                min: kMinimumFontSizeScale,
                max: kMaximumFontSizeScale,
                value: settingsProvider.fontSizeScale,
                onChanged: settingsProvider.changeFontSizeScale,
                activeColor: AppTheme.of(context).chordColor,
                inactiveColor: AppTheme.of(context).disabledColor,
              ),
            ),
            RichText(
              text: TextSpan(text: 'A', style: AppTheme.of(context).bodyTextStyle),
              textScaleFactor: kMaximumFontSizeScale,
            ),
          ]),
        ),
      );
}
