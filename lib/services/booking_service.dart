import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> buatBooking({
    required String pasienId,
    required String dokterId,
    required String namaDokter,
  }) async {
    // 1. Referensi ke dokumen counter untuk dokter spesifik hari ini
    // Kita buat ID dokumen berdasarkan ID Dokter agar antrean tidak tertukar antar dokter
    DocumentReference counterRef = _db.collection('counters').doc(dokterId);

    // 2. Gunakan Transaction agar jika 2 orang klik bersamaan, nomor tidak bentrok
    await _db.runTransaction((transaction) async {
      DocumentSnapshot counterSnap = await transaction.get(counterRef);

      int nomorBaru = 1; // Default jika belum ada antrean

      if (counterSnap.exists) {
        // Jika sudah ada antrean, ambil nomor terakhir + 1
        nomorBaru = (counterSnap.get('last_number') ?? 0) + 1;
      }

      // 3. Update nomor terakhir di koleksi counters
      transaction.set(counterRef, {
        'last_number': nomorBaru,
        'last_update': FieldValue.serverTimestamp(),
      });

      // 4. Buat dokumen booking baru di koleksi 'bookings'
      DocumentReference bookingRef = _db.collection('bookings').doc();
      transaction.set(bookingRef, {
        'booking_id': bookingRef.id,
        'pasien_id': pasienId,
        'dokter_id': dokterId,
        'nama_dokter': namaDokter,
        'nomor_antrean': nomorBaru,
        'status': 'menunggu', // Sesuai Activity Diagram
        'waktu_booking': FieldValue.serverTimestamp(),
      });
    });
  }

  // Fungsi untuk memantau antrean yang sedang berjalan secara live
  Stream<QuerySnapshot> getLiveAntrean(String dokterId) {
    return _db.collection('bookings')
        .where('dokter_id', isEqualTo: dokterId)
        .where('status', isEqualTo: 'menunggu')
        .orderBy('nomor_antrean', descending: false)
        .snapshots();
  }

  // Fungsi untuk Dokter saat selesai melayani pasien
  Future<void> inputRekamMedis({
    required String bookingId,
    required String diagnosa,
    required int biaya,
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'selesai',
      'diagnosa': diagnosa,
      'total_biaya': biaya,
      'status_pembayaran': 'menunggu_pembayaran', // Sesuai alur pembayaran di diagram
    });
  }

  // Fungsi untuk Admin mengubah status bayar
  Future<void> verifikasiPembayaran(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status_pembayaran': 'lunas',
    });
  }
}