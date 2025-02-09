import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/widgets/chat_bubble.dart';
import 'package:photo_sharing_app/widgets/my_textfield.dart';

final ChatService chatServices = locator.get();
final AuthServices authServices = locator.get();

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  });
  final String receiverEmail;
  final String receiverId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  String receiverUserName = 'ローディング...';
  @override
  void initState() {
    _setUpInitiate();
    super.initState();
    myFocusNode.addListener(
      () {
        if (myFocusNode.hasFocus) {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => scrollDown(),
          );
        }
      },
    );
  }

  Future<void> _setUpInitiate() async {
    var user = await authServices.getDocument(widget.receiverId);
    setState(() {
      receiverUserName = user?['username'];
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
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
      appBar: AppBar(
        title: Text(receiverUserName),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              receiverID: widget.receiverId,
              controller: scrollController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    hint:
                        "メッセージを入力する....", ////////////////////type a message////////////////////////////
                    obsecure: false,
                    controller: controller,
                    focusNode: myFocusNode,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 20.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class MessageList extends StatelessWidget {
  const MessageList(
      {super.key, required this.receiverID, required this.controller});
  final String receiverID;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    String senderID = authServices.getCurrentuser()!.uid;
    return StreamBuilder(
      stream: chatServices.getMessage(receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "読み込み中",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                SpinKitWanderingCubes(
                  color: Theme.of(context).colorScheme.primary,
                  size: 30.0,
                ),
              ],
            ),
          );
        }
        return ListView(
          controller: controller,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurentUser = data['senderId'] == authServices.getCurrentuser()!.uid;

    return ChatBubble(
      isCurrentUser: isCurentUser,
      message: data["message"],
    );
  }
}
