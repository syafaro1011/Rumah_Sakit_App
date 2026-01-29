import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumahsakitapp/model/doctor_model.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===============================
  // 1. DASHBOARD STATS (STREAMS)
  // ===============================

  Stream<int> getCountByRole(String role) {
    return _db
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getTodayPraktikCount() {
    // Menghitung booking aktif (asumsi koleksi 'bookings' ada)
    return _db
        .collection('bookings')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getDoctorsCount() {
    return _db
        .collection('doctors')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ===============================
  // 2. AUTHENTICATION (SECONDARY INSTANCE)
  // ===============================

  // Memastikan SecondaryApp tidak diinisialisasi berulang kali
  Future<FirebaseAuth> get _secondaryAuth async {
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app('SecondaryApp');
    } catch (e) {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );
    }
    return FirebaseAuth.instanceFor(app: secondaryApp);
  }

  // ===============================
  // 3. CRUD DOKTER
  // ===============================

  // Create Dokter (Tanpa File Gambar, Menggunakan Link URL)
  Future<void> createDoctor(DoctorModel doctor) async {
    try {
      // 1. Daftarkan di Auth melalui Secondary Instance
      FirebaseAuth authInstance = await _secondaryAuth;
      UserCredential res = await authInstance.createUserWithEmailAndPassword(
        email: doctor.email,
        password: doctor.password,
      );

      String uid = res.user!.uid;

      // 2. Simpan identitas dasar ke koleksi 'users'
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'nama': doctor.nama,
        'email': doctor.email,
        'role': 'dokter',
      });

      // 3. Simpan profil lengkap ke koleksi 'doctors' 
      // doctor.photoUrl sudah berisi link internet dari form
      await _db.collection('doctors').doc(uid).set(doctor.toMap());

      // 4. Simpan jadwal ke sub-koleksi menggunakan WriteBatch agar lebih cepat
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

      // 5. Keluar dari instance secondary
      await authInstance.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Update data dasar dokter
  Future<void> updateDoctor(String id, Map<String, dynamic> data) async {
    await _db.collection('doctors').doc(id).update(data);
  }

  // Hapus Dokter secara permanen

  

  Future<void> deleteDoctor(String doctorId) async {
    await _db.collection('doctors').doc(doctorId).delete();
    await _db.collection('users').doc(doctorId).delete();
    await deleteAllJadwal(doctorId);
    // Catatan: Menghapus user dari Firebase Auth memerlukan Firebase Admin SDK 
    // atau login kembali ke akun tersebut. Untuk saat ini hapus dari DB sudah cukup.
  }

  Stream<QuerySnapshot> getAllDoctors() {
    return _db.collection('doctors').snapshots();
  }

  // ===============================
  // 4. MANAJEMEN JADWAL (SUB-COLLECTION)
  // ===============================

  Future<void> deleteAllJadwal(String dokterId) async {
    final collection = _db.collection('doctors').doc(dokterId).collection('jadwal');
    final snapshots = await collection.get();
    
    final batch = _db.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> createJadwalDokter({
    required String dokterId,
    required String hari,
    required String jamMulai,
    required String jamSelesai,
  }) async {
    await _db.collection('doctors').doc(dokterId).collection('jadwal').add({
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'created_at': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getJadwalDokter(String dokterId) {
    return _db
        .collection('doctors')
        .doc(dokterId)
        .collection('jadwal')
        .snapshots();
  }

  // ===============================
  // 5. STATUS DOKTER
  // ===============================

  Future<void> updateStatusDokter({
    required String dokterId,
    required String status, // 'aktif' atau 'nonaktif'
  }) async {
    await _db.collection('doctors').doc(dokterId).update({'status': status});
  }
}