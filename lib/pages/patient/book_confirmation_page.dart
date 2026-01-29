import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '/services/booking_service.dart'; // 🔥 Import service Anda
import '/model/doctor_model.dart'; // 🔥 Import model Anda

class BookConfirmationPage extends StatelessWidget {
  final DoctorModel doctor; // 🔥 Gunakan objek model langsung
  final String selectedDate;
  final String selectedTime;

  BookConfirmationPage({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
  });

  final BookingService _bookingService = BookingService();

Future<void> _processBooking(BuildContext context) async {
    try {
      int queueNum = await _bookingService.createAppointment(
        doctor: doctor,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        userId: "",
      );

      if (context.mounted) _showSuccessDialog(context, queueNum); // 🔥 Kirim nomor antrean
    } catch (e) {
      if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

}

void _showSuccessDialog(BuildContext context, int queueNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.checkCircle, color: Colors.green, size: 50),
            const SizedBox(height: 16),
            const Text("Booking Berhasil!", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Nomor Antrean Anda:"),
            Text(
              queueNumber.toString().padLeft(3, '0'), // Contoh: 001
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF3F6DF6)),
            ),
            const SizedBox(height: 10),
            const Text("Tunjukkan nomor ini saat tiba di RS.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [ /* Tombol OK */ ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F6DF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "KONFIRMASI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detail Dokter",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDoctorCard(),
                  const SizedBox(height: 24),
                  const Text(
                    "Waktu & Lokasi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoItem(LucideIcons.calendar, "Tanggal", selectedDate),
                  _infoItem(LucideIcons.clock, "Jam Praktik", selectedTime),
                  _infoItem(
                    LucideIcons.mapPin,
                    "Lokasi",
                    "RS Heal Sync, Jakarta",
                  ),
                  const SizedBox(height: 40),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF3F6DF6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            child: Icon(
              LucideIcons.calendarCheck,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Hampir Selesai!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Pastikan jadwal yang Anda pilih sudah benar.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                (doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty)
                ? NetworkImage(doctor.photoUrl!)
                : const AssetImage('assets/images/default.png')
                      as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  doctor.poli,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3F6DF6)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F6DF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _processBooking(context),
            child: const Text(
              "Konfirmasi Sekarang",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Batalkan",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  
}
