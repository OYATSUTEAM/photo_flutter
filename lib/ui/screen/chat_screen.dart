import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/services/notification_service.dart';
import 'package:photo_sharing_app/widgets/chat_bubble.dart';
import 'package:photo_sharing_app/widgets/my_textfield.dart';

final ChatService chatServices = locator.get();
final AuthServices authServices = locator.get();

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
    required this.receiverName,
    required this.receiverUserName,
  });
  final String receiverEmail;
  final String receiverId;
  final String receiverName;
  final String receiverUserName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  // String receiverUserName = 'ローディング...';
  @override
  void initState() {
    _setUpInitiate();

    super.initState();
    myFocusNode.addListener(
      () {
        if (myFocusNode.hasFocus) {
          Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
        }
      },
    );
  }

  Future<void> _setUpInitiate() async {
    await globalData.updateChatScreen(true); // Set flag when screen opens

    // var user = await authServices.getDocument(widget.receiverId);
    setState(() {
      // receiverUserName = user?['username'];
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    globalData.updateChatScreen(false);
    super.dispose();
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 10),
      curve: Curves.decelerate,
    );
  }

  void scrollDownInit() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }

  void sendMessage() async {
    if (controller.text.isNotEmpty) {
      await chatServices.sendMessage(widget.receiverId, controller.text);
      controller.clear();
    }

    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(title: Text(widget.receiverUserName), centerTitle: true),
            body: Padding(
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  Expanded(
                      child: MessageList(
                    receiverID: widget.receiverId,
                    controller: scrollController,
                  )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: MyTextField(
                                  hint: "",
                                  obsecure: false,
                                  controller: controller,
                                  focusNode: myFocusNode),
                            ),
                            SizedBox(width: 10),
                            Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green),
                                child: IconButton(
                                  onPressed: sendMessage,
                                  icon: const Icon(Icons.arrow_upward,
                                      color: Colors.white),
                                ))
                          ]))
                ]))));
  }
}

class MessageList extends StatefulWidget {
  const MessageList(
      {super.key, required this.receiverID, required this.controller});
  final String receiverID;
  final ScrollController controller;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late int lastMessageIndex;
  @override
  void initState() {
    super.initState();
    lastMessageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    String senderID = authServices.getCurrentuser()!.uid;
    return StreamBuilder(
      stream: chatServices.getMessage(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        var messages = snapshot.data!.docs;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (messages.isNotEmpty) {
            var newMessage = messages[messages.length - 1];
            if (newMessage['senderId'] != senderID) {
              NotificationService().showNotification();
            }

            if (widget.controller.hasClients) {
              widget.controller
                  .jumpTo(widget.controller.position.maxScrollExtent);
            }
          }
        });
        return ListView(
          controller: widget.controller,
          children: messages.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == authServices.getCurrentuser()!.uid;

    return ChatBubble(
      isCurrentUser: isCurrentUser,
      message: data["message"],
    );
  }
}
