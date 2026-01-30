import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================================
  // CREATE MEDICAL RECORD (DOKTER)
  // ================================
  Future<void> createMedicalRecord({
    required String bookingId,
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String poliName,
    required String diagnosa,
    required String resep,
    required String tindakan,
    required int totalPrice,
  }) async {
    final docRef = _firestore.collection('medical_records').doc();

    await docRef.set({
      'bookingId': bookingId,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'poliName': poliName,
      'diagnosa': diagnosa,
      'resep': resep,
      'tindakan': tindakan,
      'totalPrice': totalPrice,
      'paymentStatus': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update booking menjadi selesai
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'done',
      'hasMedicalRecord': true,
      'finishedAt': FieldValue.serverTimestamp(),
    });
  }

  // Fungsi tambahan untuk menghitung total kunjungan secara real-time
  Stream<int> getTotalVisits() {
    String uid = _auth.currentUser?.uid ?? '';
    return _firestore
        .collection('medical_records')
        .where('patientId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ======================================
  // GET MEDICAL RECORD (REALTIME PASIEN)
  // ======================================
  Stream<QuerySnapshot> getMedicalRecordsByPatient() {
    final user = _auth.currentUser;

    return _firestore
        .collection('medical_records')
        .where('patientId', isEqualTo: user?.uid)
        .snapshots();
  }

  // ======================================
  // GET MEDICAL RECORD BY DOCTOR
  // ======================================
  Stream<QuerySnapshot> getMedicalRecordsByDoctor(String doctorId) {
    return _firestore
        .collection('medical_records')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ======================================
  // GET SINGLE MEDICAL RECORD
  // ======================================
  Future<DocumentSnapshot> getMedicalRecordById(String recordId) {
    return _firestore.collection('medical_records').doc(recordId).get();
  }

  // ======================================
  // UPDATE PAYMENT STATUS
  // ======================================
  Future<void> updatePaymentStatus({
    required String recordId,
    required String status,
  }) async {
    await _firestore.collection('medical_records').doc(recordId).update({
      'paymentStatus': status,
      'paidAt': status == 'Lunas' ? FieldValue.serverTimestamp() : null,
    });
  }

  // ======================================
  // DELETE MEDICAL RECORD (ADMIN)
  // ======================================
  Future<void> deleteMedicalRecord(String recordId) async {
    await _firestore.collection('medical_records').doc(recordId).delete();
  }

  // ======================================
  // PROSES BAYAR PAKAI SALDO (TRANSACTION)
  // ======================================
  Future<void> payWithWallet({
    required String recordId,
    required int amount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User tidak terautentikasi");

    final userRef = _firestore.collection('users').doc(user.uid);
    final recordRef = _firestore.collection('medical_records').doc(recordId);

    return _firestore.runTransaction((transaction) async {
      // 1. Ambil data user terbaru dalam transaksi
      DocumentSnapshot userSnap = await transaction.get(userRef);
      if (!userSnap.exists) throw Exception("Data user tidak ditemukan");

      int currentSaldo =
          (userSnap.data() as Map<String, dynamic>)['saldo'] ?? 0;

      // 2. Cek apakah saldo cukup
      if (currentSaldo < amount) {
        throw Exception("Saldo tidak cukup. Silakan Top Up.");
      }

      // 3. Potong Saldo
      transaction.update(userRef, {'saldo': currentSaldo - amount});

      // 4. Update status di rekam medis
      transaction.update(recordRef, {
        'paymentStatus': 'Lunas',
        'paidAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
