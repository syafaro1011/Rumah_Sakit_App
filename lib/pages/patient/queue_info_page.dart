import 'package:flutter/material.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumahsakitapp/services/queue_service.dart';
import 'package:rumahsakitapp/model/bookings_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Informasi Antrean',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<BookingsModel>>(
        stream: _queueService.getMyActiveBooking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final myBooking = snapshot.data!.first;

          // Stream kedua untuk memantau nomor yang sedang dilayani (nowServing)
          return StreamBuilder<DocumentSnapshot>(
            stream: _queueService.getCurrentServing(
              myBooking.doctorId,
              myBooking.date,
            ),
            builder: (context, servingSnapshot) {
              int nowServing = 0;

              // PERBAIKAN: Validasi dokumen dan field agar tidak crash 'Bad State'
              if (servingSnapshot.hasData && servingSnapshot.data!.exists) {
                final data = servingSnapshot.data!.data() as Map<String, dynamic>?;
                if (data != null && data.containsKey('nowServing')) {
                  nowServing = data['nowServing'] ?? 0;
                }
              }

              int myNum = myBooking.queueNumber;
              // Menghitung sisa antrean (tidak boleh minus)
              int remaining = (myNum - nowServing).clamp(0, 999);

              // Progress bar logic
              // Full (1.0) jika status sudah 'checking' (dipanggil) atau nomor sudah terlewati
              double progress =
                  (myBooking.status == 'checking' || nowServing >= myNum)
                      ? 1.0
                      : (myNum > 0 ? (nowServing / myNum).clamp(0.0, 1.0) : 0.0);

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDoctorHeader(myBooking),
                    const SizedBox(height: 20),
                    // Jika status sudah dipanggil dokter, tampilkan UI khusus Giliran Anda
                    myBooking.status == 'checking' 
                        ? _buildServingState(myBooking)
                        : _buildQueueCard(myBooking, nowServing, remaining, progress),
                    const SizedBox(height: 20),
                    _noteCard(),
                    const SizedBox(height: 40),
                    // Tombol batal hanya muncul jika status masih 'pending'
                    if (myBooking.status == 'pending')
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

  Widget _buildServingState(BookingsModel booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.stethoscope,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            "GILIRAN ANDA!",
            style: TextStyle(fontSize: 22,  color: Colors.green),
          ),
          const SizedBox(height: 12),
          Text(
            "Silakan masuk ke ruangan ${booking.doctorName}. Dokter sedang menunggu Anda.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.calendarX, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Tidak ada antrean aktif",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader(BookingsModel booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: booking.photoUrl.isNotEmpty
                ? NetworkImage(booking.photoUrl)
                : null,
            child: booking.photoUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.doctorName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(booking.poli, style: TextStyle(color: Colors.blue.shade700, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(BookingsModel booking, int serving, int sisa, double progress) {
    bool isMyTurn = sisa == 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Status Antrean Real-time",
            style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _queueCircle(
                serving.toString(),
                'Sedang Dilayani',
                Colors.orange.shade50,
                Colors.orange,
              ),
              _queueCircle(
                booking.queueNumber.toString(),
                'Nomor Anda',
                const Color(0xFFEAF1FF),
                const Color(0xFF3F6DF6),
              ),
            ],
          ),
          const SizedBox(height: 35),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(
                isMyTurn ? Colors.green : const Color(0xFF3F6DF6),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isMyTurn ? "SILAHKAN BERSIAP" : "Sisa $sisa antrean lagi",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isMyTurn ? Colors.green : const Color(0xFF3F6DF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _queueCircle(String value, String label, Color bgColor, Color textColor) {
    return Column(
      children: [
        Container(
          width: 85,
          height: 85,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: textColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ]
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 28,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _noteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade100),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.info, color: Colors.amber.shade800, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Harap standby di area tunggu. Jika nomor terlewat, Anda mungkin harus mendaftar ulang di loket.',
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelButton(BuildContext context, String bookingId) {
    return TextButton(
      onPressed: () => _showCancelConfirmation(context, bookingId),
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
      child: const Text(
        'Batalkan Janji Temu',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Antrean?'),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Nomor antrean Anda akan dikosongkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await _queueService.cancelBooking(bookingId);
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
              }
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}