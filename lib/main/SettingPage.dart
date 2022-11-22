import 'package:flutter/cupertino.dart';
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

  _loadSharedPreference() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref != null) {
      setState(() {
        _isChecked =
            _pref.getBool('checked') == null ? false : _pref.getBool('checked');
      });
    } else {
      _pref = await SharedPreferences.getInstance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '환경설정',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(size.width * 0.01),
            title: Text('자동 로그인 설정하기'),
            subtitle: Text('체크박스가 체크되면 자동 로그인 설정, 체크박스가 해제되면 자동 로그인이 해제됩니다.',
                style: TextStyle(fontSize: 12)),
            leading: Container(
              width: size.width * 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 30,
                  ),
                ],
              ),
            ),
            trailing: Container(
              alignment: Alignment.center,
              width: size.width * 0.15,
              child: Checkbox(
                value: _isChecked,
                onChanged: (value) {
                  setState(() {
                    _isChecked = value;
                    _pref.setBool('checked', _isChecked);
                  });
                },
              ),
            ),
          ),
          Divider(
            thickness: 2,
          )
        ],
      ),
    );
  }
}
