import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rumahsakitapp/model/bookings_model.dart';

class QueueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan data booking aktif milik user (Pending atau sedang diperiksa)
  Stream<List<BookingsModel>> getMyActiveBooking() {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        // Menggunakan whereIn agar saat status berubah jadi 'checking', data tidak hilang di HP pasien
        .where('status', whereIn: ['pending', 'checking']) 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingsModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Mendapatkan nomor antrean yang sedang dilayani saat ini (Real-time)
  Stream<DocumentSnapshot> getCurrentServing(String doctorId, String date) {
    // Pastikan ID dokumen menggunakan format yang sama dengan yang diupdate dokter
    return _db.collection('counters').doc('${doctorId}_$date').snapshots();
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
}