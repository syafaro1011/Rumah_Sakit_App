import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. FUNGSI REGISTRASI 
  Future<void> registerPasien({
    required String email,
    required String password,
    required String nama,
    required String nik,
    required String tanggalLahir,
  }) async {
    // A. Buat user di Firebase Auth
    UserCredential res = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );

    // B. Simpan detail ke Firestore menggunakan UID yang sama
    // Ini poin yang kita bahas tadi: UID Auth = ID Dokumen Firestore
    await _db.collection('users').doc(res.user!.uid).set({
      'uid': res.user!.uid,
      'nama': nama,
      'email': email,
      'nik': nik,
      'tanggalLahir': tanggalLahir,
      'role': 'pasien', // Kita kunci sebagai pasien
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. FUNGSI LOGIN (Sesuai alur 'Tampil Dashboard Masing-masing Role')
  Future<String?> loginAndGetRole(String email, String password) async {
    // A. Login ke Auth
    UserCredential res = await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );

    // B. Ambil data role dari Firestore
    DocumentSnapshot userDoc = await _db.collection('users').doc(res.user!.uid).get();
    
    // Kembalikan nilai role (admin/dokter/pasien) ke Frontend
    return userDoc.get('role');
  }
}

