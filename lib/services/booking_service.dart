import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/doctor_model.dart';
import '/model/bookings_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> createAppointment({
    required DoctorModel doctor,
    required String selectedDate,
    required String selectedTime,
    required String userId,
  }) async {
    // 1. CEK APAKAH USER SUDAH DAFTAR DI DOKTER & TANGGAL YANG SAMA
    final existingCheck = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('doctorId', isEqualTo: doctor.id)
        .where('date', isEqualTo: selectedDate)
        // Kita batasi pengecekan untuk status yang masih aktif (pending/processing)
        // Jika pasien sudah 'selesai' atau 'dibatalkan', mereka boleh daftar lagi (opsional)
        .where('status', whereIn: ['pending', 'processing'])
        .get();

    if (existingCheck.docs.isNotEmpty) {
      // Jika ditemukan data, lempar error agar ditangkap oleh Try-Catch di UI
      throw Exception(
        "Anda sudah memiliki antrean aktif untuk dokter ini di hari yang sama.",
      );
    }

    // 2. JIKA TIDAK ADA DUPLIKASI, LANJUTKAN TRANSAKSI ANTREAN
    DocumentReference counterRef = _db
        .collection('counters')
        .doc('${doctor.id}_$selectedDate');

    return _db.runTransaction((transaction) async {
      DocumentSnapshot counterSnapshot = await transaction.get(counterRef);

      int nextQueueNumber;
      if (!counterSnapshot.exists) {
        nextQueueNumber = 1;
        transaction.set(counterRef, {'lastNumber': 1});
      } else {
        nextQueueNumber =
            (counterSnapshot.data() as Map<String, dynamic>)['lastNumber'] + 1;
        transaction.update(counterRef, {'lastNumber': nextQueueNumber});
      }

      DocumentReference bookingRef = _db.collection('bookings').doc();
      transaction.set(bookingRef, {
        'doctorId': doctor.id,
        'doctorName': doctor.nama,
        'poli': doctor.poli,
        'photoUrl': doctor.photoUrl ?? '',
        'userId': userId,
        'date': selectedDate,
        'time': selectedTime,
        'queueNumber': nextQueueNumber,
        'status': 'pending',
        'status_pembayaran': 'belum_bayar',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return nextQueueNumber;
    });
  }

  // --- LOGIC UNTUK DOKTER ---

  /// Stream antrean untuk dokter secara real-time
  Stream<List<AppointmentModel>> streamDoctorQueue(
    String doctorId,
    String date,
  ) {
    return _db
        .collection('bookings')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
        .where('status', isEqualTo: 'pending') // Hanya pasien yang mengantre
        .orderBy('queueNumber', descending: false) // Urutkan 1, 2, 3...
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
