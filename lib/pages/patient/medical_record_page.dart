import 'package:flutter/material.dart';
import 'medical_record_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/medical_record_service.dart';
import 'package:rumahsakitapp/model/medical_record_model.dart';

class MedicalRecordPage extends StatelessWidget {
  const MedicalRecordPage({super.key});

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final service = MedicalRecordService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Rekam Medis',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<int>(
              stream: service.getTotalVisits(),
              builder: (context, snapshot) =>
                  _totalVisitCard(snapshot.data ?? 0),
            ),
            const SizedBox(height: 20),
            const Text(
              'Riwayat Pemeriksaan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: service.getMedicalRecordsByPatient(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return _buildEmptyState();

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      // Konversi Map ke Model
                      final record = MedicalRecordModel(
                        bookingId: data['bookingId'] ?? '',
                        patientId: data['patientId'] ?? '',
                        doctorId: data['doctorId'] ?? '',
                        date: data['date'] ?? '',
                        diagnosa: data['diagnosa'] ?? '-',
                        resepObat: data['resepObat'] ?? '-',
                        biayaKonsultasi: data['biayaKonsultasi'] ?? 0,
                        biayaObat: data['biayaObat'] ?? 0,
                        totalBayar: data['totalBayar'] ?? 0,
                        createdAt: (data['createdAt'] as Timestamp).toDate(),
                      );

                      return FutureBuilder<List<DocumentSnapshot>>(
                        future: Future.wait([
                          FirebaseFirestore.instance
                              .collection('doctors')
                              .doc(record.doctorId)
                              .get(),
                          FirebaseFirestore.instance
                              .collection('bookings')
                              .doc(record.bookingId)
                              .get(),
                        ]),
                        builder: (context, multiSnap) {
                          String doctorName = "Memuat...";
                          String poliName = "Memuat...";
                          String statusBayar = "Pending";
                          bool isPaid = false;

                          if (multiSnap.hasData) {
                            // Data Dokter
                            final dDoc = multiSnap.data![0];
                            if (dDoc.exists) {
                              final dData = dDoc.data() as Map<String, dynamic>;
                              doctorName =
                                  dData['nama'] ?? 'Dokter Tidak Dikenal';
                              poliName = dData['spesialis'] ?? 'Umum';
                            }

                            // Data Booking (Status Pembayaran)
                            final bDoc = multiSnap.data![1];
                            if (bDoc.exists) {
                              final bData = bDoc.data() as Map<String, dynamic>;
                              statusBayar =
                                  bData['status_pembayaran'] ?? 'Pending';
                              isPaid = statusBayar.toLowerCase() == 'lunas';
                            }
                          }

                          final dateStr =
                              "${record.createdAt.day} ${_monthName(record.createdAt.month)} ${record.createdAt.year}";

                          return _medicalCard(
                            date: dateStr,
                            doctor: doctorName,
                            poli: poliName,
                            diagnosis: record.diagnosa,
                            status: statusBayar,
                            price: "Rp ${record.totalBayar}",
                            isPaid: isPaid,
                            recordData: {
                              ...record.toMap(),
                              'id': doc.id,
                              'doctorName': doctorName,
                              'poliName': poliName,
                              'status_pembayaran': statusBayar,
                            },
                            context: context,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Widgets (Tetap Sama) ---

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu, size: 60, color: Colors.grey),
          Text(
            "Belum ada riwayat pemeriksaan",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _totalVisitCard(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE8F0FF),
            child: Icon(Icons.description, color: Color(0xFF3F6DF6)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Total kunjungan',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _medicalCard({
    required String date,
    required String doctor,
    required String poli,
    required String diagnosis,
    required String status,
    required String price,
    required bool isPaid,
    required Map<String, dynamic> recordData,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            doctor,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            poli,
            style: const TextStyle(color: Color(0xFF3F6DF6), fontSize: 13),
          ),
          const Divider(height: 24),
          const Text(
            'Diagnosis:',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            diagnosis,
            style: const TextStyle(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MedicalRecordDetailPage(recordData: recordData),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F6DF6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Detail & Bayar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
