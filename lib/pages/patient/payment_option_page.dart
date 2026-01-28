import 'package:flutter/material.dart';

class PaymentOptionPage extends StatefulWidget {
  const PaymentOptionPage({super.key});

  @override
  State<PaymentOptionPage> createState() => _PaymentOptionPageState();
}

class _PaymentOptionPageState extends State<PaymentOptionPage> {
  String selectedPayment = 'qris';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Options'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _paymentTile(
              value: 'qris',
              title: 'QRIS',
              trailing: Image.asset('assets/images/iconQris.png', height: 24),
            ),
            const SizedBox(height: 12),
            _paymentTile(
              value: 'card',
              title: 'Credit Card',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [Icon(Icons.credit_card, color: Colors.blue)],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F6DF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // sementara hanya konfirmasi
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pembayaran dikonfirmasi')),
                  );
                },
                child: const Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(fontSize: 16),
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
    required Widget trailing,
  }) {
    return InkWell(
      onTap: () {
        setState(() => selectedPayment = value);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              selectedPayment == value
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: selectedPayment == value ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            trailing,
          ],
        ),
      ),
    );
  }
}
