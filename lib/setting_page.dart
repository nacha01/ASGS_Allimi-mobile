import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isChecked = false;
  SharedPreferences _pref;
  @override
  void initState() {
    super.initState();
    _loadSharedPreference();
  }

  _loadSharedPreference() async{
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = _pref.getBool('checked') ?? false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('환경설정'),),
      body: Column(
        children: [
          ListTile(title: Text('자동 로그인 설정하기'),
          subtitle: Text('체크박스가 체크되면 자동 로그인 설정, 체크박스가 해제되면 자동 로그인이 해제됩니다.'),
          isThreeLine: true,
          leading: Icon(Icons.login),
          trailing: Checkbox(
            value: _isChecked,
            onChanged: (value){
                setState(() {
                  _isChecked = value;
                  _pref.setBool('checked', _isChecked);
                });
            },
          ),),
          Divider(height: 4,thickness: 2,)
        ],
      ),
    );
  }
}
