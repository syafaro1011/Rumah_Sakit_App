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

          return StreamBuilder<DocumentSnapshot>(
            stream: _queueService.getCurrentServing(
              myBooking.doctorId,
              myBooking.date,
            ),
            builder: (context, servingSnapshot) {
              int nowServing = 0;
              if (servingSnapshot.hasData && servingSnapshot.data!.exists) {
                try {
                  nowServing = servingSnapshot.data!.get('nowServing') ?? 0;
                } catch (e) {
                  nowServing = 0;
                }
              }

              int myNum = myBooking.queueNumber;
              int remaining = (myNum - nowServing).clamp(0, 999);

              // Progress dihitung dari persentase kedekatan (0.0 - 1.0)
              double progress = 0.0;
              if (nowServing > 0) {
                progress = (nowServing / myNum).clamp(0.0, 1.0);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDoctorHeader(myBooking),
                    const SizedBox(height: 20),
                    _buildQueueCard(myBooking, nowServing, remaining, progress),
                    const SizedBox(height: 20),
                    _noteCard(),
                    const SizedBox(height: 40),
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
    return Row(
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
            Text(booking.poli, style: TextStyle(color: Colors.blue.shade700)),
          ],
        ),
      ],
    );
  }

  Widget _buildQueueCard(
    BookingsModel booking,
    int serving,
    int sisa,
    double progress,
  ) {
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
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation(
                  isMyTurn ? Colors.green : const Color(0xFF3F6DF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isMyTurn ? Colors.green.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isMyTurn ? "SILAHKAN MASUK" : "Sisa $sisa antrean lagi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMyTurn ? Colors.green : const Color(0xFF3F6DF6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _queueCircle(
    String value,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Container(
          width: 75,
          height: 75,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
          Icon(LucideIcons.info, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Harap standby di area tunggu. Jika nomor terlewat, Anda mungkin harus mendaftar ulang.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelButton(BuildContext context, String bookingId) {
    return TextButton(
      onPressed: () => _showCancelConfirmation(context, bookingId),
      child: const Text(
        'Batalkan Janji Temu',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
          'Tindakan ini tidak dapat dibatalkan. Nomor antrean Anda akan hangus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: () async {
              await _queueService.cancelBooking(bookingId);
              if (context.mounted) {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.patientDashboard,
                );
              }
            },
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
