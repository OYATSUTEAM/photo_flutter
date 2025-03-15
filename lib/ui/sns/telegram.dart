import 'package:social_sharing_plus/social_sharing_plus.dart';

import 'package:flutter/material.dart';

class TelegramAppPage extends StatefulWidget {
  const TelegramAppPage({super.key});

  @override
  State<TelegramAppPage> createState() => _TelegramAppPageState();
}

class _TelegramAppPageState extends State<TelegramAppPage> {
  static const SocialPlatform platform = SocialPlatform.facebook;

  String? _mediaPath; // add image or video path
  List<String> _mediaPaths = []; // add image or video paths
  bool isMultipleShare = true;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          final String content = '_controller.text';
          isMultipleShare
              ? await SocialSharingPlus.shareToSocialMediaWithMultipleMedia(
                  platform,
                  media: _mediaPaths,
                  content: content,
                  isOpenBrowser: false,
                  onAppNotInstalled: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                            '${platform.name.capitalize} is not installed.'),
                      ));
                  },
                )
              : await SocialSharingPlus.shareToSocialMedia(
                  platform,
                  content,
                  media: _mediaPath,
                  isOpenBrowser: true,
                );
        },
        child: Text('data'));
  }
}

extension StringExtension on String {
  String get capitalize => "${this[0].toUpperCase()}${substring(1)}";
}
