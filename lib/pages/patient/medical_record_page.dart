import 'package:flutter/material.dart';
import 'medical_record_detail_page.dart';

class MedicalRecordPage extends StatelessWidget {
  const MedicalRecordPage({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _totalVisitCard(),
            const SizedBox(height: 20),
            const Text(
              'Riwayat Pemeriksaan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _medicalCard(
                    date: '20 Januari 2026',
                    doctor: 'Dr. Floyd Miles',
                    poli: 'Poli Gigi',
                    diagnosis: 'Gigi Berlubang',
                    status: 'Pending',
                    price: 'RP 150.000',
                    isPaid: false,
                  ),
                  _medicalCard(
                    date: '10 Januari 2026',
                    doctor: 'Dr. Floyd Miles',
                    poli: 'Poli Gigi',
                    diagnosis: 'Gigi Berlubang',
                    price: 'RP 150.000',
                    status: 'Lunas',
                    isPaid: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TOTAL VISIT =================

  Widget _totalVisitCard() {
    return Container(
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
      child: Row(
        children: const [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE8F0FF),
            child: Icon(Icons.description, color: Color(0xFF3F6DF6)),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '12',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              Text('Total kunjungan', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // ================= MEDICAL CARD =================

  Widget _medicalCard({
    required String date,
    required String doctor,
    required String poli,
    required String diagnosis,
    required String status,
    String? price,
    required bool isPaid,
  }) {
    final statusColor = isPaid ? Colors.green.shade100 : Colors.orange.shade100;
    final statusTextColor = isPaid ? Colors.green : Colors.orange;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// DATE & STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(date),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(doctor, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(poli, style: TextStyle(color: Colors.grey.shade600)),

          const SizedBox(height: 12),

          /// DIAGNOSIS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diagnosis:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  diagnosis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          if (price != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F6DF6),
                  ),
                ),
                Builder(
                  builder: (context) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MedicalRecordDetailPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Detail'),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
