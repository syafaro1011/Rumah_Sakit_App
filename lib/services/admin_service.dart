import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Mengambil Stream jumlah total dokter
  Stream<int> getCountByRole(String role) {
    return _db
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 2. Mengambil Stream jumlah praktik/booking hari ini
  Stream<int> getTodayPraktikCount() {
    // Asumsi: Anda memiliki koleksi 'bookings'
    return _db
        .collection('bookings')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 3. Mengambil Stream daftar seluruh dokter
  Stream<int> getDoctorsCount() {
    return _db
        .collection('doctors')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

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
    List<Map<String, dynamic>>? jadwal, // Tambahan parameter optional
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // Simpan ke collection Users (untuk login)
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'nama': nama,
        'email': email,
        'role': 'dokter',
        'created_at': Timestamp.now(),
      });

      // Simpan ke collection Doctors (profil lengkap)
      await _db.collection('doctors').doc(uid).set({
        'uid': uid,
        'nama': nama,
        'poli': poli,
        'email': email,
        'no_str': noStr,
        'no_hp': noHp,
        'status': 'aktif',
        'created_at': Timestamp.now(),
      });

      // Jika ada jadwal awal, masukkan ke sub-collection
      if (jadwal != null) {
        for (var j in jadwal) {
          await _db.collection('doctors').doc(uid).collection('jadwal').add(j);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 2. UPDATE DATA DOKTER
  // ===============================
  Future<void> updateDoctor(String doctorId, Map<String, dynamic> data) async {
    await _db.collection('doctors').doc(doctorId).update(data);
  }

  // ===============================
  // 3. DELETE DOKTER
  // ===============================
  Future<void> deleteDoctor(String doctorId) async {
    await _db.collection('doctors').doc(doctorId).delete();
  }

  // ===============================
  // 4. GET ALL DOKTER
  // ===============================
  Stream<QuerySnapshot> getAllDoctors() {
    return _db.collection('doctors').snapshots();
  }

  // ===============================
  // 5. CREATE POLI
  // ===============================
  Future<void> createPoli({
    required String namaPoli,
    required String deskripsi,
  }) async {
    try {
      await _db.collection('polis').add({
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
      await _db.collection('polis').doc(poliId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 7. DELETE POLI
  // ===============================
  Future<void> deletePoli(String poliId) async {
    try {
      await _db.collection('polis').doc(poliId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===============================
  // 8. GET ALL POLI
  // ===============================
  Stream<QuerySnapshot> getAllPoli() {
    return _db.collection('polis').snapshots();
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
      await _db.collection('doctors').doc(dokterId).collection('jadwal').add({
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
      await _db
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
      await _db
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
    return _db
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
      await _db.collection('doctors').doc(dokterId).update({'status': status});
    } catch (e) {
      rethrow;
    }
  }
}
