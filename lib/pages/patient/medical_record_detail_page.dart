import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_option_page.dart';
import 'package:rumahsakitapp/model/medical_record_model.dart';

class MedicalRecordDetailPage extends StatelessWidget {
  final Map<String, dynamic> recordData;

  const MedicalRecordDetailPage({super.key, required this.recordData});

  @override
  Widget build(BuildContext context) {
    // Menggunakan data dari Firestore atau model map
    final dynamic rawDate = recordData['createdAt'];
    DateTime? dateObject;

    if (rawDate is Timestamp) {
      dateObject = rawDate.toDate();
    } else if (rawDate is DateTime) {
      dateObject = rawDate;
    }

    final dateStr = dateObject != null
        ? "${dateObject.day} ${_monthName(dateObject.month)} ${dateObject.year}"
        : "-";

    // Pastikan status_pembayaran diambil dari data yang dilempar list sebelumnya
    final status = recordData['status_pembayaran'] ?? 'Pending';
    final bool isPaid = status.toString().toLowerCase() == 'lunas';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Detail Rekam Medis',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _infoCard(dateStr),
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
                    content: recordData['resepObat'] ?? '-', // Sesuai model
                  ),
                  _paymentCard(isPaid, status),
                ],
              ),
            ),

            /// TOMBOL BAYAR (Hanya muncul jika belum lunas)
            if (!isPaid)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F6DF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentOptionPage(
                            bookingId: recordData['bookingId'],
                            totalAmount: recordData['totalBayar'] ?? 0,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Bayar Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String date) {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const Divider(height: 20),
          Text(
            recordData['doctorName'] ?? 'Dokter',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            recordData['poliName'] ?? 'Umum',
            style: const TextStyle(
              color: Color(0xFF3F6DF6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 10), child: Divider()),
          Text(
            content,
            style: const TextStyle(height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(bool isPaid, String status) {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Rincian Biaya',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _priceRow('Biaya Konsultasi', recordData['biayaKonsultasi'] ?? 0),
          _priceRow('Biaya Obat', recordData['biayaObat'] ?? 0),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Rp ${recordData['totalBayar'] ?? 0}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF3F6DF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            "Rp $price",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _cardWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

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
      'Desember',
    ];
    return months[month];
  }
}
