import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ambil daftar poli unik dari collection doctors
  Stream<List<String>> getPoliList() {
    return _db.collection('doctors').snapshots().map((snapshot) {
      final setPoli = <String>{};
      for (var doc in snapshot.docs) {
        setPoli.add(doc['poli']);
      }
      return setPoli.toList();
    });
  }

  // Ambil dokter berdasarkan poli
  Stream<QuerySnapshot> getDokterByPoli(String poli) {
    return _db.collection('doctors')
        .where('poli', isEqualTo: poli)
        .snapshots();
  }

  // Booking antrean
  Future<void> buatBooking({
    required String pasienId,
    required String dokterId,
    required String namaDokter,
    required String poli,
  }) async {
    String counterId = '${dokterId}_$poli';
    DocumentReference counterRef = _db.collection('counters').doc(counterId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot counterSnap = await transaction.get(counterRef);

      int nomorBaru = 1;

      if (counterSnap.exists) {
        nomorBaru = (counterSnap.get('last_number') ?? 0) + 1;
      }

      transaction.set(counterRef, {
        'dokter_id': dokterId,
        'poli': poli,
        'last_number': nomorBaru,
        'last_update': FieldValue.serverTimestamp(),
      });

      DocumentReference bookingRef = _db.collection('bookings').doc();
      transaction.set(bookingRef, {
        'booking_id': bookingRef.id,
        'pasien_id': pasienId,
        'dokter_id': dokterId,
        'nama_dokter': namaDokter,
        'poli': poli,
        'nomor_antrean': nomorBaru,
        'status': 'menunggu',
        'waktu_booking': FieldValue.serverTimestamp(),
      });
    });
  }

  // Live antrean per dokter & poli
  Stream<QuerySnapshot> getLiveAntrean(String dokterId, String poli) {
    return _db.collection('bookings')
        .where('dokter_id', isEqualTo: dokterId)
        .where('poli', isEqualTo: poli)
        .where('status', isEqualTo: 'menunggu')
        .orderBy('nomor_antrean')
        .snapshots();
  }
}
