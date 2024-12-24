import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.isCurrentUser,
    required this.message,
  });
  final String message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ThemeManager.readTheme();
    return BubbleSpecialTwo(
      tail: true,
      text: message,
      isSender: isCurrentUser ? true : false,
      color: isCurrentUser
          ? isDarkMode
              ? Colors.green.shade600
              : Colors.green.shade500
          : isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade200,
      textStyle: TextStyle(
        color: isCurrentUser
            ? Colors.white
            : isDarkMode
                ? Colors.white
                : Colors.black,
      ),
    );
  }
}
