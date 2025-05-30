import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDbContext {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAllNews() async {
    final querySnapshot =
        await _firestore
            .collection('News')
            .orderBy('publication_date', descending: true)
            .get();
    return querySnapshot.docs
        .map((doc) => doc.data()..['id'] = doc.id)
        .toList();
  }
}
