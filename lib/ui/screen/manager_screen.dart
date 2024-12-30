import 'package:flutter/material.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

ProfileServices profileServices = ProfileServices();

class _ManagerScreenState extends State<ManagerScreen> {
  bool isBlockTrue = true;
  bool isReportTrue = true;
  bool isCommenting = true;
  @override
  void initState() {
    super.initState();
    _setUpBlockStatus();
    _setUpReportStatus();
    _setUpCommentStatus();
  }

  Future<void> _setUpBlockStatus() async {
    bool fetchedBlock = await profileServices.isBlockTrue();
    if (mounted) {
      setState(() {
        isBlockTrue = fetchedBlock;
      });
    }
  }

  Future<void> _setUpReportStatus() async {
    bool fetchedReport = await profileServices.isReportTrue();
    if (mounted) {
      setState(() {
        isBlockTrue = fetchedReport;
      });
    }
  }

  Future<void> _setUpCommentStatus() async {
    bool fetchedComments = await profileServices.getCommentStatus();
    if (mounted) {
      setState(() {
        isCommenting = fetchedComments;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('ステータス管理')),
        body: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('報告ステータス'),
                  Switch(
                    // This bool value toggles the switch.
                    value: isReportTrue,
                    activeColor: const Color.fromARGB(255, 30, 180, 24),
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        isReportTrue = value;
                        profileServices.setReportStatus(value);
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('ブロックステータス'),
                  Switch(
                    // This bool value toggles the switch.
                    value: isBlockTrue,
                    activeColor: const Color.fromARGB(255, 30, 180, 24),
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        isBlockTrue = value;
                        profileServices.setBlockStatus(value);
                      });
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('コメントステータス'),
                  Switch(
                    // This bool value toggles the switch.
                    value: isCommenting,
                    activeColor: const Color.fromARGB(255, 30, 180, 24),
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        isCommenting = value;
                        profileServices.setCommentStatus(value);
                      });
                    },
                  )
                ],
              )
            ],
          ),
        ));
  }
}
