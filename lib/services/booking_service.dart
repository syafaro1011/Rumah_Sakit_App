import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/doctor_model.dart';
import '/model/bookings_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fungsi untuk menyimpan pendaftaran janji temu ke Firestore
  Future<int> createAppointment({
    required DoctorModel doctor,
    required String selectedDate,
    required String selectedTime,
    required String userId,
  }) async {
    try {
      // 1. Cari jumlah antrean yang sudah ada untuk dokter & waktu tersebut
      final existingAppointments = await _db
          .collection('bookings')
          .where('doctorId', isEqualTo: doctor.id)
          .where('date', isEqualTo: selectedDate)
          .where('time', isEqualTo: selectedTime)
          .get();

      // 2. Nomor antrean adalah jumlah data yang ada + 1
      int nextQueueNumber = existingAppointments.docs.length + 1;

      // 3. Simpan data pendaftaran
      await _db.collection('bookings').add({
        'doctorId': doctor.id,
        'doctorName': doctor.nama,
        'poli': doctor.poli,
        'photoUrl': doctor.photoUrl ?? '',
        'userId': userId,
        'date': selectedDate,
        'time': selectedTime,
        'queueNumber': nextQueueNumber, // 🔥 Simpan nomor antrean
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return nextQueueNumber; // Kembalikan nomor antrean untuk ditampilkan di UI
    } catch (e) {
      throw Exception("Gagal mendapatkan nomor antrean: $e");
    }
  }

  /// Fungsi opsional: Mengambil daftar janji temu milik user tertentu
  Stream<QuerySnapshot> getUserAppointments(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  
  Stream<List<AppointmentModel>> streamUserAppointments(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}