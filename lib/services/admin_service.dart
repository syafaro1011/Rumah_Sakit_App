import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===============================
  // 1. CREATE DOKTER ACCOUNT
  // ===============================
  Future<void> createDoctor({
    required String nama,
    required String poli,
    required String email,
    required String password,
    required String noStr,
    required String noHp,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('doctors').doc(uid).set({
        'uid': uid,
        'nama': nama,
        'poli': poli,
        'email': email,
        'no_str': noStr,
        'no_hp': noHp,
        'role': 'doctor',
        'status': 'aktif',
        'created_at': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 2. UPDATE DATA DOKTER
  // ===============================
  Future<void> updateDoctor({
    required String dokterId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('doctors').doc(dokterId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 3. DELETE DOKTER
  // ===============================
  Future<void> deleteDoctor(String dokterId) async {
    try {
      await _firestore.collection('doctors').doc(dokterId).delete();
      // NOTE: Firebase Auth user harus dihapus via Cloud Function / Admin SDK
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 4. GET ALL DOKTER
  // ===============================
  Stream<QuerySnapshot> getAllDoctors() {
    return _firestore.collection('doctors').snapshots();
  }

  // ===============================
  // 5. CREATE POLI
  // ===============================
  Future<void> createPoli({
    required String namaPoli,
    required String deskripsi,
  }) async {
    try {
      await _firestore.collection('polis').add({
        'nama_poli': namaPoli,
        'deskripsi': deskripsi,
        'created_at': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 6. UPDATE POLI
  // ===============================
  Future<void> updatePoli({
    required String poliId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('polis').doc(poliId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 7. DELETE POLI
  // ===============================
  Future<void> deletePoli(String poliId) async {
    try {
      await _firestore.collection('polis').doc(poliId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 8. GET ALL POLI
  // ===============================
  Stream<QuerySnapshot> getAllPoli() {
    return _firestore.collection('polis').snapshots();
  }

  // ===============================
  // 9. CREATE JADWAL DOKTER
  // ===============================
  Future<void> createJadwalDokter({
    required String dokterId,
    required String hari,
    required String jamMulai,
    required String jamSelesai,
  }) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(dokterId)
          .collection('jadwal')
          .add({
        'hari': hari,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'created_at': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 10. UPDATE JADWAL DOKTER
  // ===============================
  Future<void> updateJadwalDokter({
    required String dokterId,
    required String jadwalId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(dokterId)
          .collection('jadwal')
          .doc(jadwalId)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 11. DELETE JADWAL DOKTER
  // ===============================
  Future<void> deleteJadwalDokter({
    required String dokterId,
    required String jadwalId,
  }) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(dokterId)
          .collection('jadwal')
          .doc(jadwalId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 12. GET JADWAL DOKTER
  // ===============================
  Stream<QuerySnapshot> getJadwalDokter(String dokterId) {
    return _firestore
        .collection('doctors')
        .doc(dokterId)
        .collection('jadwal')
        .snapshots();
  }

  // ===============================
  // 13. AKTIFKAN / NONAKTIFKAN DOKTER
  // ===============================
  Future<void> updateStatusDokter({
    required String dokterId,
    required String status, // aktif / nonaktif
  }) async {
    try {
      await _firestore.collection('doctors').doc(dokterId).update({
        'status': status,
      });
    } catch (e) {
      rethrow;
    }
  }
}
