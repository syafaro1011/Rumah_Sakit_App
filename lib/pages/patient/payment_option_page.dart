import 'package:flutter/material.dart';
import '../../services/payment_service.dart'; // Pastikan path benar

class PaymentOptionPage extends StatefulWidget {
  final String bookingId;
  final int totalAmount;

  const PaymentOptionPage({
    super.key,
    required this.bookingId,
    required this.totalAmount,
  });

  @override
  State<PaymentOptionPage> createState() => _PaymentOptionPageState();
}

class _PaymentOptionPageState extends State<PaymentOptionPage> {
  String selectedPayment = 'saldo'; // Default ke Saldo
  bool _isLoading = false;
  final PaymentService _paymentService = PaymentService();

  Future<void> _handlePayment() async {
    if (selectedPayment != 'saldo') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Metode ini belum tersedia, gunakan Saldo'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _paymentService.processPayment(
        bookingId: widget.bookingId,
        amount: widget.totalAmount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Pembayaran Berhasil!'),
          ),
        );
        // Kembali ke daftar rekam medis (pop 2 kali: dari Payment -> Detail -> List)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Metode Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ringkasan Pembayaran",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              "Rp ${widget.totalAmount}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F6DF6),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Pilih Metode Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Opsi Saldo
            _paymentTile(
              value: 'saldo',
              title: 'Saldo Akun',
              subtitle: 'Bayar instan dengan saldo Anda',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),

            // Opsi QRIS
            _paymentTile(
              value: 'qris',
              title: 'QRIS',
              subtitle: 'Gopay, OVO, Dana, LinkAja',
              icon: Icons.qr_code_scanner,
              iconColor: Colors.purple,
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F6DF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _handlePayment,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Konfirmasi & Bayar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    bool isSelected = selectedPayment == value;
    return InkWell(
      onTap: () => setState(() => selectedPayment = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF3F6DF6) : Colors.grey.shade200,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color(0xFF3F6DF6).withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF3F6DF6) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
