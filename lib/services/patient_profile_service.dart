import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateProfile({
  required String nama,
  required String nik,
  required String gender,
  required String birthDate,
  required String bloodType,
  required String phone,
  required String address,
  required List<String> allergies,
}) async {
  String uid = _auth.currentUser!.uid;
  await _db.collection('users').doc(uid).update({
    'nama': nama,
    'nik': nik,
    'gender': gender,
    'birthDate': birthDate,
    'bloodType': bloodType,
    'phone': phone,
    'address': address,
    'allergies': allergies,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

  // Mengambil Stream data profil user yang sedang login
  Stream<DocumentSnapshot> getPatientProfile() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User tidak terautentikasi");
    
    return _db.collection('users').doc(uid).snapshots();
  }

  // Fungsi Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update foto profil (opsional jika ingin dikembangkan)
  Future<void> updateProfilePicture(String url) async {
    await _db.collection('users').doc(_auth.currentUser!.uid).update({
      'photoUrl': url,
    });
  }
}