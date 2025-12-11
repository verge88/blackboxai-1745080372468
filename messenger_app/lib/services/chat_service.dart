import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessages(String userId1, String userId2) {
    String chatRoomId = _getChatRoomId(userId1, userId2);
    
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data()))
          .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    String chatRoomId = _getChatRoomId(senderId, receiverId);
    
    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      type: type,
    );

    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toMap());
        
    // Update last message in chat room
    await _firestore.collection('chats').doc(chatRoomId).set({
      'users': [senderId, receiverId],
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    });
  }

  String _getChatRoomId(String userId1, String userId2) {
    // Create consistent chat room ID regardless of who is user1 or user2
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Stream<List<UserModel>> getAllUsers(String currentUserId) {
    return _firestore
        .collection('users')
        .where('id', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getChatRooms(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> chatRooms = [];
      
      for (var doc in snapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id;
        
        // Get other user info
        String? otherUserId;
        List<dynamic>? users = data['users'];
        if (users != null) {
          for (var userId in users) {
            if (userId != currentUserId) {
              otherUserId = userId.toString();
              break;
            }
          }
        }
        
        if (otherUserId != null) {
          chatRooms.add({
            'id': doc.id,
            'otherUserId': otherUserId,
            'lastMessage': data['lastMessage'] ?? '',
            'lastMessageTime': data['lastMessageTime'] ?? DateTime.now(),
            'lastSenderId': data['lastSenderId'] ?? '',
          });
        }
      }
      
      return chatRooms;
    });
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': isOnline ? null : FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}