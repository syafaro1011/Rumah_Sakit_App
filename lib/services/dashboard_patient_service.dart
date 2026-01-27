import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPatientService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mengambil Data User (Nama & NIK)
  Future<DocumentSnapshot> getUserProfile() async {
    String uid = _auth.currentUser!.uid;
    return await _db.collection('users').doc(uid).get();
  }

  // Mengambil Jadwal Praktik/Booking Terbaru si Pasien
  // Asumsinya kita simpan data booking di koleksi 'bookings'
  Stream<QuerySnapshot> getTodayBooking() {
    String uid = _auth.currentUser!.uid;
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active') // Hanya yang belum selesai
        .limit(1)
        .snapshots();
  }
}