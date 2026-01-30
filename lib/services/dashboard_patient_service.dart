import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPatientService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getUserProfileStream() {
    String uid = _auth.currentUser?.uid ?? '';
    return _db.collection('users').doc(uid).snapshots();
  }

  // Fungsi yang sudah ada sebelumnya
  Future<DocumentSnapshot> getUserProfile() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(uid).get();
  }

  /// Mengambil booking aktif terbaru hari ini
  Stream<QuerySnapshot> getTodayBooking() {
    String uid = _auth.currentUser!.uid;

    return _db
        .collection('bookings')
        .where('userId', isEqualTo: uid) // 🔥 Disamakan dengan createAppointment
        .where('status', isEqualTo: 'pending') 
        .limit(1)
        .snapshots();
  }

  /// Fungsi untuk logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}