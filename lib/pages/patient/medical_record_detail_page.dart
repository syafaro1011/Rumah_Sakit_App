import 'package:flutter/material.dart';
import 'payment_option_page.dart';

class MedicalRecordDetailPage extends StatelessWidget {
  const MedicalRecordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekam Medis'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _infoCard(),
                  _sectionCard(
                    icon: Icons.description_outlined,
                    iconColor: Colors.blue,
                    title: 'Diagnosis',
                    content: 'Gigi Berlubang',
                  ),
                  _sectionCard(
                    icon: Icons.medication_outlined,
                    iconColor: Colors.green,
                    title: 'Resep Obat',
                    content: '• Paracetamol 5mg (3x1)',
                  ),
                  _sectionCard(
                    title: 'Tindakan dan Anjuran',
                    content:
                        'Sementara konsumsi makanan yang teksturnya lembut',
                  ),
                  _paymentCard(),
                ],
              ),
            ),

            /// BUTTON BAYAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F6DF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentOptionPage(),
                    ),
                  );
                },
                child: const Text(
                  'Bayar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INFO DOCTOR =================

  Widget _infoCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16),
              SizedBox(width: 6),
              Text('20 Januari 2026'),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Dr. Floyd Miles',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text('Poli Gigi', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ================= SECTION CARD =================

  Widget _sectionCard({
    IconData? icon,
    Color? iconColor,
    required String title,
    required String content,
  }) {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: iconColor ?? Colors.black),
              if (icon != null) const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  // ================= PAYMENT =================

  Widget _paymentCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.attach_money, color: Colors.orange),
              SizedBox(width: 8),
              Text('Pembayaran', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Total Biaya:'),
              Text('Rp 150.000', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status:'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CARD WRAPPER =================

  Widget _cardWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
