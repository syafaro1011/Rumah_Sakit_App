import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPatientService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getUserProfile() async {
    return _db.collection('users').doc(_auth.currentUser!.uid).get();
  }

  Stream<QuerySnapshot> getTodayBooking() {
  String uid = _auth.currentUser!.uid;

  return _db
      .collection('bookings')
      .where('pasien_id', isEqualTo: uid) // ✅ sesuai booking
      .where('status', isEqualTo: 'menunggu') // ✅ sesuai booking
      .orderBy('waktu_booking', descending: true)
      .limit(1)
      .snapshots();
}

}
