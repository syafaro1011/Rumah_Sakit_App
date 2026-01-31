import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/doctor_model.dart';
import '../model/bookings_model.dart';
import '../model/medical_record_model.dart';

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

  //Ambil User Stream
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // AMBIL ANTREAN DARI KOLEKSI 'bookings'
  Stream<List<BookingsModel>> getBookingsByDate(String doctorId, String date) {
  return _db
      .collection('bookings')
      .where('doctorId', isEqualTo: doctorId)
      .where('date', isEqualTo: date)
      .where('status', whereIn: ['pending', 'checking']) 
      .orderBy('queueNumber', descending: false)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => BookingsModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ),
            )
            .toList(),
      );
}

  // AMBIL JADWAL DOKTER
  Stream<QuerySnapshot> getJadwalDokter(String dokterId) {
    return _db
        .collection('doctors')
        .doc(dokterId)
        .collection('jadwal')
        .snapshots();
  }

  //UPDATE STATUS BOOKING
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': newStatus,
    });
  }

  // SUBMIT REKAM MEDIS
  Future<void> submitMedicalRecord({
    required String bookingId,
    required MedicalRecordModel record,
  }) async {
    // Gunakan Batch Write agar jika salah satu gagal, semua batal (menjaga integritas data)
    WriteBatch batch = _db.batch();

    // 1. Referensi untuk koleksi medical_records
    DocumentReference recordRef = _db.collection('medical_records').doc();

    // 2. Simpan data rekam medis
    batch.set(recordRef, record.toMap());

    // 3. Referensi untuk dokumen booking yang bersangkutan
    DocumentReference bookingRef = _db.collection('bookings').doc(bookingId);

    // 4. Update status dan total tagihan di dokumen bookings
    batch.update(bookingRef, {
      'status': 'success', // Mengubah dari pending ke success
      'totalTagihan':
          record.totalBayar, // Menyimpan tagihan untuk dibayar pasien
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Eksekusi semua perintah di atas secara bersamaan
    await batch.commit();
  }
}
