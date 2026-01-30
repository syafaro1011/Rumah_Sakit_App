import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> processPayment({
    required String bookingId,
    required int amount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User tidak ditemukan';

    final userRef = _firestore.collection('users').doc(user.uid);
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    return _firestore.runTransaction((transaction) async {
      // 1. Ambil data user untuk cek saldo
      DocumentSnapshot userSnap = await transaction.get(userRef);
      if (!userSnap.exists) throw "Data user tidak ditemukan";
      
      int currentBalance = (userSnap.data() as Map<String, dynamic>)['saldo'] ?? 0;

      // 2. Cek apakah saldo cukup
      if (currentBalance < amount) {
        throw "Saldo tidak cukup. Silakan top up terlebih dahulu.";
      }

      // 3. Kurangi saldo user
      transaction.update(userRef, {
        'saldo': currentBalance - amount,
      });

      // 4. Update status booking menjadi Lunas
      transaction.update(bookingRef, {
        'status_pembayaran': 'Lunas',
        'paidAt': FieldValue.serverTimestamp(),
      });
      
      // 5. Opsional: Tambahkan riwayat transaksi
      DocumentReference txRef = _firestore.collection('transactions').doc();
      transaction.set(txRef, {
        'userId': user.uid,
        'bookingId': bookingId,
        'amount': amount,
        'type': 'Payment',
        'description': 'Pembayaran Rekam Medis',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}