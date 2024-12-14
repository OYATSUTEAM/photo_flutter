import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  Message(this.message, this.receiverId, this.senderEmail, this.senderID,
      this.timestamp);

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderID,
      "senderEmail": senderEmail,
      "receiverId": receiverId,
      "message": message,
      "timeStamp": timestamp,
    };
  }
}
