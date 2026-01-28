import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<String>> getPoliList() {
    return _db.collection('doctors').snapshots().map((s) {
      final set = <String>{};
      for (var d in s.docs) {
        set.add(d['poli']);
      }
      return set.toList();
    });
  }

  Stream<QuerySnapshot> getDokterByPoli(String poli) {
    return _db
        .collection('doctors')
        .where('poli', isEqualTo: poli)
        .where('status', isEqualTo: 'aktif')
        .snapshots();
  }

  Future<void> buatBooking({
    required String pasienId,
    required String dokterId,
    required String namaDokter,
    required String poli,
  }) async {
    final ref = _db.collection('bookings').doc();

    await ref.set({
      'booking_id': ref.id,
      'pasien_id': pasienId,
      'dokter_id': dokterId,
      'nama_dokter': namaDokter,
      'poli': poli,
      'nomor_antrean': 1,
      'status': 'menunggu',
      'waktu_booking': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getLiveAntrean(String dokterId, String poli) {
    return _db
        .collection('bookings')
        .where('dokter_id', isEqualTo: dokterId)
        .where('poli', isEqualTo: poli)
        .where('status', isEqualTo: 'menunggu')
        .orderBy('nomor_antrean')
        .snapshots();
  }
}

