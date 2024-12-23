import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'package:testing/widgets/othertile.dart';

String? _selectedOption;

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;
final AuthServices _authServices = locator.get();

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.otherUid});
  final String otherUid;
  @override
  _ReportScreen createState() => _ReportScreen();
}

String email = 'default@gmail.com',
    otherName = 'ローディング...',
    otherUsername = 'ローディング...',
    uid = 'default';

class _ReportScreen extends State<ReportScreen> {
  @override
  void initState() {
    getCurrentUserUID();
    fetchOtherUsername();
    super.initState();
  }

  void getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
        email = user.email!;
      });
    }
  }

  Future<void> fetchOtherUsername() async {
    try {
      Map<String, dynamic>? user =
          await _authServices.getUserDetail(widget.otherUid);

      setState(() {
        otherUsername = user?['username'];
        otherName = user?['name'];
      });
    } catch (e) {
      if (mounted)
        setState(() {
          otherUsername = "ユーザー名の取得エラー";
          otherName = "ユーザー名の取得エラー";
        });
      debugPrint("ユーザー名の取得エラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height * 2,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "このレポートを送信する理由を教えてください",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ListTile(
                  title: Text('スパム/広告'),
                  leading: Radio<String>(
                    value: 'スパム/広告',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('セクシャルハラスメント'),
                  leading: Radio<String>(
                    value: 'セクシャルハラスメント',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('その他のハラスメント'),
                  leading: Radio<String>(
                    value: 'その他のハラスメント',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('なりすまし'),
                  leading: Radio<String>(
                    value: 'なりすまし',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('詐欺'),
                  leading: Radio<String>(
                    value: '詐欺',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('その他'),
                  leading: Radio<String>(
                    value: 'その他',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      profileServices
                          .reportThisUser(
                              uid, widget.otherUid, _selectedOption!)
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'お客様は「${otherUsername}」を「$_selectedOption」で申告しました。')),
                        );
                      });
                    },
                    child: Text(
                      '報告',
                      style: TextStyle(fontSize: 20),
                    ))
              ],
            )));
  }
}
