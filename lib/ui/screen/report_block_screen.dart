import 'package:flutter/material.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';

class Report_Block extends StatefulWidget {
  const Report_Block({super.key});

  @override
  State<Report_Block> createState() => _Report_BlockState();
}

ProfileServices profileServices = ProfileServices();

class _Report_BlockState extends State<Report_Block> {
  bool isBlockTrue = true;
  bool isReportTrue = true;
  @override
  void initState() {
    super.initState();
    _setUpReportBlock();
    _setUpInisiate();
  }

  Future<void> _setUpReportBlock() async {
    bool fetchedBlock = await profileServices.isBlockTrue();
    if (mounted) {
      setState(() {
        isBlockTrue = fetchedBlock;
      });
    }
  }

  Future<void> _setUpInisiate() async {
    bool fetchedReport = await profileServices.isReportTrue();
    if (mounted) {
      setState(() {
        isBlockTrue = fetchedReport;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
        appBar: AppBar(title: Text('Report and Block')),
        body: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('report status'),
                  Switch(
                    // This bool value toggles the switch.
                    value: isReportTrue,
                    activeColor: const Color.fromARGB(255, 30, 180, 24),
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        isReportTrue = value;
                        setReportStatus(value);
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('block status'),
                  Switch(
                    // This bool value toggles the switch.
                    value: isBlockTrue,
                    activeColor: const Color.fromARGB(255, 30, 180, 24),
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        isBlockTrue = value;
                        setBlockStatus(value);
                      });
                    },
                  )
                ],
              )
            ],
          ),
        )));
  }
}
