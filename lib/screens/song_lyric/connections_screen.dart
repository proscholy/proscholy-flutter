import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/custom/custom_appbar.dart';
import 'package:zpevnik/platform/components/dialog.dart';
import 'package:zpevnik/platform/components/text_field.dart';
import 'package:zpevnik/providers/data_provider.dart';
import 'package:zpevnik/providers/sync_provider.dart';
import 'package:zpevnik/screens/components/highlightable_row.dart';
import 'package:zpevnik/screens/song_lyric/song_lyric_screen.dart';
import 'package:zpevnik/status_bar_wrapper.dart';
import 'package:zpevnik/theme.dart';
import 'package:zpevnik/platform/mixin.dart';

final _connectConfirmationText =
    'Chystáte se připojit k${unbreakableSpace}zařízení [DEVICE_NAME] a${unbreakableSpace}nechat si od${unbreakableSpace}něj automaticky přepínat písně ve${unbreakableSpace}Zpěvníku.\nChcete pokračovat?';
final _shareConfirmationText =
    'Chystáte se zařízením v${unbreakableSpace}okolí sdílet svůj stav Zpěvníku. Kdokoli v${unbreakableSpace}okolí se bude smět připojit a${unbreakableSpace}vždy se mu automaticky nastaví stejná píseň jako vám.\nChcete pokračovat?';

class ConnectionsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> with PlatformStateMixin {
  String _deviceName;

  @override
  void initState() {
    super.initState();

    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid)
      deviceInfo.androidInfo.then((info) => _deviceNameChanged(info.model));
    else if (Platform.isIOS) deviceInfo.iosInfo.then((info) => _deviceNameChanged(info.localizedModel));

    final navigator = Navigator.of(context, rootNavigator: true);
    Provider.of<SyncProvider>(context, listen: false).onSongChange = (int id) {
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => SongLyricScreen(
            songLyric: DataProvider.shared.songLyric(id),
          ),
        ),
      );
    };
  }

  @override
  void dispose() {
    Provider.of<SyncProvider>(context, listen: false).stop();

    super.dispose();
  }

  @override
  Widget androidWidget(BuildContext context) {
    return StatusBarWrapper(
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text(
            'Připojení k zařízením v okolí',
            style: AppTheme.of(context).navBarTitleTextStyle.copyWith(color: AppTheme.of(context).iconColor),
          ),
          shadowColor: AppTheme.of(context).appBarDividerColor,
          brightness: AppTheme.of(context).brightness,
        ),
        body: _body(context),
      ),
    );
  }

  @override
  Widget iOSWidget(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Připojení k zařízením v okolí', style: AppTheme.of(context).navBarTitleTextStyle),
        padding: EdgeInsetsDirectional.only(start: kDefaultPadding, end: kDefaultPadding),
      ),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(kDefaultPadding).copyWith(bottom: 0),
        child: Consumer<SyncProvider>(
          builder: (context, provider, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _infoText(context, provider),
              if (provider.isAdvertiser) _advertiserList(context, provider) else _browserList(context, provider),
              if (!provider.isAdvertiser)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jméno zařízení', style: AppTheme.of(context).captionTextStyle),
                    PlatformTextField(
                      controller: TextEditingController()..text = _deviceName,
                      onSubmitted: (deviceName) => _deviceNameChanged(deviceName),
                    ),
                  ],
                ),
              if (!provider.isAdvertiser)
                TextButton(
                  onPressed: () => _shareAppState(provider),
                  child: Text('Sdílet stav mé aplikace zařízením v okolí'),
                  style: ButtonStyle(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText(BuildContext context, SyncProvider provider) {
    String text;

    if (provider.isAdvertiser) {
      text =
          'Sdílení stavu vašeho zpěvníku je aktivní. Ostatní v${unbreakableSpace}okolí se nyní mouhou připojit k${unbreakableSpace}vašemu zařízení a${unbreakableSpace}každá píseň, kterou otevřete se ostatním přepne automaticky.';
    } else {
      text =
          'Pomocí této funkce se můžete připojit k${unbreakableSpace}zařízením v${unbreakableSpace}okolí a${unbreakableSpace}nechat si od${unbreakableSpace}něj automaticky přepínat písně ve${unbreakableSpace}Zpěvníku.\n';
      text +=
          'Tato funkce je ve${unbreakableSpace}fázi testování a${unbreakableSpace}pro${unbreakableSpace}komunikaci využívá několika bezdrátových technologií v${unbreakableSpace}telefonu.\n';
      text += 'Sdílení je zatím možné jen mezi stejnými operačními systémy.';
    }

    final color =
        provider.isAdvertiser ? AppTheme.of(context).successBackgroundColor : AppTheme.of(context).infoBackgroundColor;

    return Container(
      margin: EdgeInsets.only(bottom: kDefaultPadding),
      padding: EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(color: color),
      child: Text(text, style: AppTheme.of(context).captionTextStyle),
    );
  }

  Widget _advertiserList(BuildContext context, SyncProvider provider) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Připojená zařízení', style: AppTheme.of(context).captionTextStyle),
            TextButton(
              onPressed: () => setState(() => provider.isAdvertiser = false),
              child: Text('Ukončit sdílení'),
              style: ButtonStyle(),
            ),
          ]),
          Flexible(child: _devicesList(context, provider, provider.connectedDevices)),
        ],
      ),
    );
  }

  Widget _browserList(BuildContext context, SyncProvider provider) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (provider.connectedDevices.isNotEmpty)
            Text('Připojeno zařízení', style: AppTheme.of(context).captionTextStyle),
          if (provider.connectedDevices.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(provider.connectedDevices[0].deviceName),
                TextButton(
                  onPressed: () => setState(
                    () => provider.nearbyService.disconnectPeer(deviceID: provider.connectedDevices[0].deviceId),
                  ),
                  child: Text('Odpojit'),
                  style: ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          Text('Dostupná zařízení', style: AppTheme.of(context).captionTextStyle),
          Flexible(child: _devicesList(context, provider, provider.availableDevices)),
        ],
      ),
    );
  }

  Widget _devicesList(BuildContext context, SyncProvider provider, List<Device> devices) => ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) => HighlightableRow(
          padding: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
          child: Text(devices[index].deviceName),
          onPressed: () {
            switch (devices[index].state) {
              case SessionState.notConnected:
                _connect(provider, devices[index]);

                break;
              default:
                break;
            }
          },
        ),
      );

  void _deviceNameChanged(String deviceName) async {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);
    await syncProvider.stop();
    syncProvider.run(deviceName);

    setState(() => _deviceName = deviceName);
  }

  void _connect(SyncProvider provider, Device device) async {
    final confirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlatformAlert(
        title: 'Připojit k zařízení',
        child: Text(_connectConfirmationText.replaceFirst('[DEVICE_NAME]', device.deviceName)),
        onCancel: () => false,
        onConfirm: () => true,
      ),
    );

    if (confirmed) provider.nearbyService.invitePeer(deviceID: device.deviceId, deviceName: device.deviceName);
  }

  void _shareAppState(SyncProvider provider) async {
    final confirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlatformAlert(
        title: 'Zahájení sdílení',
        child: Text(_shareConfirmationText),
        onCancel: () => false,
        onConfirm: () => true,
      ),
    );

    if (confirmed) setState(() => provider.isAdvertiser = true);
  }
}
