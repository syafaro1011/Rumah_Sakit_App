class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String role; // 'patient' atau 'doctor'
  final int saldo;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    this.saldo = 0, // Default saldo 0
    this.photoUrl,
  });

  // Mengubah data dari Firestore (Map) ke Object Model
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      nama: data['nama'] ?? 'User',
      email: data['email'] ?? '',
      role: data['role'] ?? 'pasien',
      saldo: data['saldo'] ?? 0,
      photoUrl: data['photoUrl'],
    );
  }

  // Mengubah Object Model ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'role': role,
      'saldo': saldo,
      'photoUrl': photoUrl,
    };
  }
}