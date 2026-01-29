import 'package:flutter/material.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumahsakitapp/services/queue_service.dart';
import 'package:rumahsakitapp/model/bookings_model.dart';

class QueueInfoPage extends StatefulWidget {
  const QueueInfoPage({super.key});

  @override
  State<QueueInfoPage> createState() => _QueueInfoPageState();
}

class _QueueInfoPageState extends State<QueueInfoPage> {
  final QueueService _queueService = QueueService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Antrean'), centerTitle: true),
      // Perubahan: Menggunakan List<AppointmentModel> sesuai service
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _queueService.getMyActiveBooking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada antrean aktif"));
          }

          // Ambil data menggunakan objek model
          final myBooking = snapshot.data!.first;

          return StreamBuilder<DocumentSnapshot>(
            stream: _queueService.getCurrentServing(
              myBooking.doctorId,
              myBooking.date,
            ),
            builder: (context, servingSnapshot) {
              int nowServing = 0;
              if (servingSnapshot.hasData && servingSnapshot.data!.exists) {
                // Gunakan try-catch kecil untuk menghindari error jika field belum ada di Firestore
                try {
                  nowServing = servingSnapshot.data!.get('nowServing') ?? 0;
                } catch (e) {
                  nowServing = 0;
                }
              }

              int myNum = myBooking.queueNumber;
              int remaining = (myNum - nowServing) < 0
                  ? 0
                  : (myNum - nowServing);

              // Hindari pembagian dengan nol (division by zero)
              double progress = myNum > 0 ? (nowServing / myNum) : 0.0;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildQueueCard(myBooking, nowServing, remaining, progress),
                    const SizedBox(height: 16),
                    _noteCard(),
                    const Spacer(),
                    _cancelButton(context, myBooking.id),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Menggunakan AppointmentModel sebagai parameter
  Widget _buildQueueCard(
    AppointmentModel booking,
    int serving,
    int sisa,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        border: Border.all(color: const Color(0xFF3F6DF6).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            booking.doctorName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(booking.poli, style: const TextStyle(color: Colors.grey)),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _queueCircle(
                serving.toString(),
                'Sekarang',
                Colors.orange.shade100,
              ),
              _queueCircle(
                booking.queueNumber.toString(),
                'Nomor Anda',
                const Color(0xFFEAF1FF),
              ),
            ],
          ),
          const SizedBox(height: 30),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF3F6DF6)),
          ),
          const SizedBox(height: 12),
          Text(
            sisa == 0 ? "Giliran Anda!" : "Sisa $sisa antrean lagi",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: sisa == 0 ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Mohon datang 10 menit sebelum estimasi giliran Anda. '
              'Anda akan menerima notifikasi saat giliran hampir tiba.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blueGrey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _queueCircle(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _cancelButton(BuildContext context, String bookingId) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _showCancelConfirmation(context, bookingId),
        child: const Text(
          'Batalkan Antrean',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan?'),
        content: const Text('Apakah Anda yakin ingin membatalkan antrean ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              await _queueService.cancelBooking(bookingId);
              // close dialog
              Navigator.pushNamed(context, AppRoutes.patientDashboard); // back to dashboard
            },
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
