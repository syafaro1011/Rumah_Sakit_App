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
    required String spesialisasi,
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
        'spesialisasi': spesialisasi,
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
  Future<void> updateDoctor(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('doctors').doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 3. DELETE DOKTER
  // ===============================
  Future<void> deleteDoctor(String uid) async {
    try {
      // Hapus data Firestore
      await _firestore.collection('doctors').doc(uid).delete();

      // NOTE:
      // Firebase Auth tidak bisa hapus user dari client langsung
      // Solusi profesional: via Cloud Function / Admin SDK

    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 4. CREATE POLI
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
  // 5. DELETE POLI
  // ===============================
  Future<void> deletePoli(String poliId) async {
    try {
      await _firestore.collection('polis').doc(poliId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 6. UPDATE JADWAL DOKTER
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
  // 7. DELETE JADWAL DOKTER
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
}
