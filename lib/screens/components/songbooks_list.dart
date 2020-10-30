import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/providers/songbooks_provider.dart';
import 'package:zpevnik/screens/components/songbook_widget.dart';

class SongbookListView extends StatelessWidget {
  final String _key = 'songbooksListView';

  @override
  Widget build(BuildContext context) => Scrollbar(
        child: Consumer<SongbooksProvider>(
          builder: (context, provider, child) => GridView.count(
            key: PageStorageKey(key),
            crossAxisCount: 2,
            children: List.generate(
              provider.songbooks.length,
              (index) => SongbookWidget(
                songbook: provider.songbooks[index],
              ),
            ),
          ),
        ),
      );
}
