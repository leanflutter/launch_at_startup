import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:preference_list/preference_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _isEnabled = await launchAtStartup.isEnabled();
    setState(() {});
  }

  _handleEnable() async {
    await launchAtStartup.enable();
    await _init();
  }

  _handleDisable() async {
    await launchAtStartup.disable();
    await _init();
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          title: const Text('Methods'),
          children: [
            PreferenceListItem(
              title: const Text('enable'),
              onTap: _handleEnable,
            ),
            PreferenceListItem(
              title: const Text('disable'),
              onTap: _handleDisable,
            ),
            PreferenceListItem(
              title: const Text('isEnabled'),
              accessoryView: Text('$_isEnabled'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }

  @override
  void onScreenEvent(String eventName) {
    print('[ScreenRetriever] onScreenEvent: $eventName');
  }
}
