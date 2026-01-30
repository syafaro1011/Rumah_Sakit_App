import 'package:flutter/material.dart';
import 'payment_option_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordDetailPage extends StatelessWidget {
  final Map<String, dynamic> recordData;

  const MedicalRecordDetailPage({
    super.key,
    required this.recordData,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = recordData['createdAt'] as Timestamp?;
    final date = timestamp != null
        ? "${timestamp.toDate().day} "
          "${_monthName(timestamp.toDate().month)} "
          "${timestamp.toDate().year}"
        : "-";

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
                  _infoCard(date),
                  _sectionCard(
                    icon: Icons.description_outlined,
                    iconColor: Colors.blue,
                    title: 'Diagnosis',
                    content: recordData['diagnosa'] ?? '-',
                  ),
                  _sectionCard(
                    icon: Icons.medication_outlined,
                    iconColor: Colors.green,
                    title: 'Resep Obat',
                    content: recordData['resep'] ?? '-',
                  ),
                  _sectionCard(
                    title: 'Tindakan dan Anjuran',
                    content: recordData['tindakan'] ?? '-',
                  ),
                  _paymentCard(),
                ],
              ),
            ),

            /// BUTTON BAYAR
            if (recordData['paymentStatus'] != 'Lunas')
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
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= INFO DOCTOR =================

  Widget _infoCard(String date) {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16),
              const SizedBox(width: 6),
              Text(date),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            recordData['doctorName'] ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            recordData['poliName'] ?? '-',
            style: const TextStyle(color: Colors.grey),
          ),
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
              if (icon != null)
                Icon(icon, color: iconColor ?? Colors.black),
              if (icon != null)
                const SizedBox(width: 8),
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
    final isPaid = recordData['paymentStatus'] == 'Lunas';

    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.attach_money, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Pembayaran',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Biaya:'),
              Text(
                "Rp ${recordData['totalPrice'] ?? 0}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
                  color: isPaid
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  recordData['paymentStatus'] ?? 'Pending',
                  style: TextStyle(
                    color: isPaid
                        ? Colors.green
                        : Colors.orange,
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

  // ================= MONTH FORMAT =================

  String _monthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month];
  }
}
