import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Admin membuat akun dokter
  Future<void> createDoctor({
    required String nama,
    required String spesialisasi,
    required String email,
    required String password,
    required String noStr,
    required String noHp,
  }) async {
    try {
      // 1. Buat akun dokter di Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 2. Simpan data dokter di Firestore
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
}