import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Retrieve appointments for a specific userId
  Stream<List<Map<String, dynamic>>> getAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList());
  }

  // Retrieve conversations for a specific userId
  Stream<List<Map<String, dynamic>>> getConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList());
  }

  // Create a new conversation
  Future<void> createConversation(String userId) async {
    await _firestore.collection('conversations').add({
      'creationTime': FieldValue.serverTimestamp(),
      'messages': [],
      'summary': "New Chat",
      'userId': userId,
    });
  }
}
