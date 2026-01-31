import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Mengambil user yang sedang login saat ini dari Firebase Auth
  User? get currentUser => _auth.currentUser;

  // Fungsi untuk Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mengambil data detail user dari Firestore berdasarkan UID
  Stream<DocumentSnapshot> getUserData(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // FUNGSI REGISTRASI 
  Future<void> registerPasien({
    required String email,
    required String password,
    required String nama,
    required String nik,
    required String tanggalLahir,
  }) async {
    // Buat user di Firebase Auth
    UserCredential res = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );

    // Simpan detail ke Firestore menggunakan UID yang sama
    await _db.collection('users').doc(res.user!.uid).set({
      'uid': res.user!.uid,
      'nama': nama,
      'email': email,
      'nik': nik,
      'tanggalLahir': tanggalLahir,
      'role': 'pasien', 
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // FUNGSI LOGIN 
  Future<String?> loginAndGetRole(String email, String password) async {
    // A. Login ke Auth
    UserCredential res = await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );

    // B. Ambil data role dari Firestore
    DocumentSnapshot userDoc = await _db.collection('users').doc(res.user!.uid).get();
    return userDoc.get('role');
  }

  // LUPA PW
  Future<void> resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch (e) {
    throw e.message ?? "Terjadi kesalahan saat mengirim email reset.";
  }
}
}