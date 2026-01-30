import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/doctor_model.dart';
import '../model/bookings_model.dart';

class DoctorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // AMBIL DATA DARI KOLEKSI 'doctors'
  Stream<DoctorModel> getDoctorStream(String uid) {
    return _db.collection('doctors').doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception("Dokter tidak ditemukan!");
      }
      return DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  // AMBIL ANTREAN DARI KOLEKSI 'bookings'
  Stream<List<BookingsModel>> getBookingsByDate(String doctorId, String date) {
    return _db
        .collection('bookings') 
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
        .where('status', isEqualTo: "pending")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingsModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // AMBIL JADWAL DOKTER
  Stream<QuerySnapshot> getJadwalDokter(String dokterId) {
    return _db
        .collection('doctors')
        .doc(dokterId)
        .collection('jadwal')
        .snapshots();
  }
}