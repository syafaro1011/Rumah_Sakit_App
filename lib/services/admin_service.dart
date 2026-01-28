import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumahsakitapp/model/doctor_model.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  Future<FirebaseAuth> get _secondaryAuth async {
    // Membuat instance Firebase App sementara
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );
    return FirebaseAuth.instanceFor(app: secondaryApp);
  }

  //Upload Foto Dokter ke Firebase Storage
  Future<String?> uploadDoctorPhoto(String uid, File file) async {
    try {
      // Simpan di folder doctors/UID_DOKTER.jpg
      Reference ref = _storage.ref().child('doctors').child('$uid.jpg');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref
          .getDownloadURL(); // Ambil URL untuk disimpan di Firestore
    } catch (e) {
      return null;
    }
  }

  // Create Dokter menggunakan Object Model
  Future<void> createDoctor(DoctorModel doctor, File? imageFile) async {
    try {
      // 1. Dapatkan instance secondary auth
      FirebaseAuth authInstance = await _secondaryAuth;

      // 2. Buat akun Auth via Secondary Instance
      // Dengan cara ini, session Admin di instance utama tidak akan terputus
      UserCredential res = await authInstance.createUserWithEmailAndPassword(
        email: doctor.email,
        password: doctor.password,
      );

      String uid = res.user!.uid;

      // 3. Upload Foto jika ada
      if (imageFile != null) {
        doctor.photoUrl = await uploadDoctorPhoto(uid, imageFile);
      }

      // 4. Simpan ke koleksi 'users'
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'nama': doctor.nama,
        'email': doctor.email,
        'role': 'dokter',
      });

      // 5. Simpan ke koleksi 'doctors'
      await _db.collection('doctors').doc(uid).set(doctor.toMap());

      // 6. Simpan jadwal ke sub-collection 'jadwal'
      if (doctor.schedules.isNotEmpty) {
        final batch = _db.batch();
        for (var s in doctor.schedules) {
          var scheduleRef = _db
              .collection('doctors')
              .doc(uid)
              .collection('jadwal')
              .doc();

          batch.set(scheduleRef, s.toMap());
        }
        await batch.commit();
      }

      // 7. PENTING: Sign out dari secondary instance agar tidak menumpuk memori
      await authInstance.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Update Dokter
  Future<void> updateDoctor(String id, Map<String, dynamic> data) async {
    await _db.collection('doctors').doc(id).update(data);
  }

  // Menghapus semua jadwal sebelum menulis yang baru saat Edit
  Future<void> deleteAllJadwal(String dokterId) async {
    final collection = _db
        .collection('doctors')
        .doc(dokterId)
        .collection('jadwal');
    final snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  // ===============================
  // 3. DELETE DOKTER
  // ===============================
  Future<void> deleteDoctor(String doctorId) async {
    await _db.collection('doctors').doc(doctorId).delete();
    await _db.collection('users').doc(doctorId).delete();
    await deleteAllJadwal(doctorId);
  }

  // ===============================
  // 4. GET ALL DOKTER
  // ===============================
  Stream<QuerySnapshot> getAllDoctors() {
    return _db.collection('doctors').snapshots();
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
