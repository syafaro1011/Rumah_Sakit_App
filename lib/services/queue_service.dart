import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rumahsakitapp/model/bookings_model.dart';

class QueueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan data booking aktif milik user
  Stream<List<AppointmentModel>> getMyActiveBooking() {
  return _db
      .collection('bookings')
      .where('userId', isEqualTo: _auth.currentUser?.uid)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
}
  

  // Mendapatkan nomor antrean yang sedang dilayani saat ini (Real-time)
  // Kita asumsikan ada koleksi 'active_queues' atau mengecek booking dengan status 'processing'
  Stream<DocumentSnapshot> getCurrentServing(String doctorId, String date) {
    return _db.collection('counters').doc('${doctorId}_$date').snapshots();
  }

  // Fungsi membatalkan antrean
  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

}