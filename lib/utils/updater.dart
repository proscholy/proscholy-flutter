import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/entities/author.dart';
import 'package:zpevnik/models/entities/external.dart';
import 'package:zpevnik/models/entities/song.dart';
import 'package:zpevnik/models/entities/song_lyric.dart';
import 'package:zpevnik/models/entities/songbook.dart';
import 'package:zpevnik/models/entities/songbook_record.dart';
import 'package:zpevnik/models/entities/tag.dart';
import 'package:zpevnik/providers/data_provider.dart';
import 'package:zpevnik/utils/beans.dart';
import 'package:zpevnik/utils/database.dart';

const String _versionKey = 'version';
const String _lastUpdateKey = 'last_update';

const String _lastUpdatePlaceholder = '[LAST_UPDATE]';
const String _initialLastUpdate = '2021-03-06 11:30:00';

const Duration _updatePeriod = Duration(hours: 12);

class Updater {
  Updater._();

  static final Updater shared = Updater._();

  final String _url = 'https://zpevnik.proscholy.cz/graphql';

  final String _query = '''
  {
    "query": "query {
      authors {
        id
        name
      }
      tags_enum {
        id
        name
        type_enum
      }
      songbooks {
        id
        name
        shortcut
        color
        color_text
        is_private
      }
      songs {
          id
          name
      }
      song_lyrics$_lastUpdatePlaceholder {
        id
        name
        secondary_name_1
        secondary_name_2
        lyrics
        lilypond_svg
        lang
        lang_string
        type_enum
        song {
          id
        }
        songbook_records {
          id
          number
          songbook {
            id
          }
        }
        externals {
          id
          public_name
          media_id
          media_type
          authors {
            id
          }
        }
        authors_pivot {
          author {
            id
          }
        }
        tags {
          id
        }
      }
      song_lyric_ids: song_lyrics {
        id
      }
      external_ids: externals {
        id
      }
    }"
  }
  ''';

  Future<bool> update() async {
    final prefs = await SharedPreferences.getInstance();
    final connectivityResult = await Connectivity().checkConnectivity();

    final version = prefs.getInt(_versionKey) ?? -1;
    String lastUpdate = prefs.getString(_lastUpdateKey) ?? _initialLastUpdate;

    await Database.shared.init(version);

    if (version != kCurrentVersion) {
      await _loadLocal().then((_) {
        prefs.setInt(_versionKey, kCurrentVersion);
        lastUpdate = _initialLastUpdate;
      }).catchError((error) => print(error));
    }

    if (connectivityResult == ConnectivityResult.wifi) _update(lastUpdate);

    await DataProvider.shared.init();

    return true;
  }

  Future<void> _update(String lastUpdate) async {
    final format = DateFormat('yyyy-MM-dd HH:mm:ss');
    if (!format.parse(lastUpdate).isBefore(DateTime.now().subtract(_updatePeriod))) return;

    final response = await Client().post(_url,
        body: _query.replaceAll('\n', '').replaceFirst(_lastUpdatePlaceholder, '(updated_after: \\"$lastUpdate\\")'),
        headers: <String, String>{'Content-Type': 'application/json; charset=utf-8'});

    await _parse(response.body).catchError((error) => print(error));

    SharedPreferences.getInstance().then((prefs) => prefs.setString(_lastUpdateKey, format.format(DateTime.now())));
  }

  Future<void> _loadLocal() async => _parse(await rootBundle.loadString('assets/data.json'));

  Future<void> _parse(String body) async {
    final data = (jsonDecode(body) as Map<String, dynamic>)['data'];

    if (data == null) return;

    final authors = (data['authors'] as List<dynamic>).map((json) => AuthorEntity.fromJson(json)).toList();

    final tags = (data['tags_enum'] as List<dynamic>).map((json) => TagEntity.fromJson(json)).toList();

    final songbooks = (data['songbooks'] as List<dynamic>).map((json) => SongbookEntity.fromJson(json)).toList();

    final songs = (data['songs'] as List<dynamic>).map((json) => SongEntity.fromJson(json)).toList();

    final songLyrics = (data['song_lyrics'] as List<dynamic>).map((json) => SongLyricEntity.fromJson(json)).toList();

    final songLyricIds = (data['song_lyric_ids'] as List<dynamic>).map((json) => int.parse(json['id'])).toList();

    final externalIds = (data['external_ids'] as List<dynamic>).map((json) => int.parse(json['id'])).toList();

    final externalsTmp = songLyrics.map((songLyric) => songLyric.externals).toList();

    final List<ExternalEntity> externals = externalsTmp.isEmpty
        ? []
        : externalsTmp.reduce((result, list) {
            result.addAll(list);
            return result;
          }).toList();

    final songbookRecordsTmp = songLyrics.map((songLyric) => songLyric.songbookRecords).toList();

    final List<SongbookRecord> songbookRecords = songbookRecordsTmp.isEmpty
        ? []
        : songbookRecordsTmp.reduce((result, list) {
            result.addAll(list);
            return result;
          }).toList();

    final songLyricAuthorsTmp = songLyrics
        .map((songLyric) => List.generate(
            songLyric.authors.length,
            (index) => SongLyricAuthor()
              ..songLyricId = songLyric.id
              ..authorId = songLyric.authors[index].id))
        .toList();

    final List<SongLyricAuthor> songLyricAuthors = songLyricAuthorsTmp.isEmpty
        ? []
        : songLyricAuthorsTmp.reduce((result, list) {
            result.addAll(list);
            return result;
          }).toList();

    final songLyricTagsTmp = songLyrics
        .map((songLyric) => List.generate(
            songLyric.tags.length,
            (index) => SongLyricTag()
              ..songLyricId = songLyric.id
              ..tagId = songLyric.tags[index].id))
        .toList();

    final List<SongLyricTag> songLyricTags = songLyricTagsTmp.isEmpty
        ? []
        : songLyricTagsTmp.reduce((result, list) {
            result.addAll(list);
            return result;
          }).toList();

    await Database.shared.saveAuthors(authors);
    await Database.shared.saveTags(tags);
    await Database.shared.saveSongbooks(songbooks);
    await Database.shared.saveSongs(songs);
    await Database.shared.saveSongLyrics(songLyrics);
    await Database.shared.saveExternals(externals);
    await Database.shared.saveSongbookRecords(songbookRecords);
    await Database.shared.saveSongLyricTags(songLyricTags);
    await Database.shared.saveSongLyricAuthors(songLyricAuthors);
    // update search table
    await Database.shared.updateSongLyricsSearchTable(songLyrics, songbooks);
    // outdated removals
    await Database.shared.removeOutdatedAuthors(authors.map((author) => author.id).toList());
    await Database.shared.removeOutdatedTags(tags.map((tag) => tag.id).toList());
    await Database.shared.removeOutdatedSongbooks(songbooks.map((songbook) => songbook.id).toList());
    await Database.shared.removeOutdatedSongs(songs.map((song) => song.id).toList());
    await Database.shared.removeOutdatedSongLyrics(songLyricIds);
    await Database.shared.removeOutdatedExternals(externalIds);
  }
}
