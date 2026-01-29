import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/model/doctor_model.dart';

class DoctorDetailPage extends StatefulWidget {
  final String name;
  final String specialist;
  final String image;
  final String doctorId;

  const DoctorDetailPage({
    super.key,
    required this.name,
    required this.specialist,
    required this.image,
    required this.doctorId,
  });

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  // State untuk melacak pilihan user
  int selectedDateIndex = 0;
  String? selectedTime;

  // Generate 7 hari ke depan secara dinamis
  final List<DateTime> availableDates = List.generate(
    7,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Detail Dokter",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Mengambil data detail tambahan (seperti experience) dari dokumen utama
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctorData =
              snapshot.data?.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _doctorHeader(),
                const SizedBox(height: 24),
                _stats(doctorData['experience'] ?? '0', doctorData['no_SIP'] ?? '0'),
                const SizedBox(height: 24),
                _aboutDoctor(doctorData['nama'] ?? widget.name),
                const SizedBox(height: 24),
                _datePickerSection(),
                const SizedBox(height: 24),
                _timePickerSection(),
                const SizedBox(height: 32),
                _bookButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HEADER DENGAN HANDLING URL GAMBAR ---
  Widget _doctorHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[100],
            image: DecorationImage(
              image: widget.image.startsWith('http')
                  ? NetworkImage(widget.image)
                  : const AssetImage('assets/images/default.png')
                        as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.specialist,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stats(String experience, String sip) {
  return Row(
    children: [
      _statCard(Icons.verified_user_outlined, 'No. SIP', sip),
      const SizedBox(width: 12),
      _statCard(Icons.work_history_outlined, 'Pengalaman', '+$experience Thn'),
    ],
  );
}

Widget _statCard(IconData icon, String label, String value) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3F6DF6)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

  // --- DATE PICKER (Dinamis 7 Hari ke Depan) ---
  Widget _datePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Tanggal',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableDates.length,
            itemBuilder: (context, index) {
              final date = availableDates[index];
              final isSelected = selectedDateIndex == index;
              return GestureDetector(
                onTap: () => setState(() {
                  selectedDateIndex = index;
                  selectedTime = null; // Reset jam jika ganti tanggal
                }),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3F6DF6)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        _getAbbrMonth(date.month),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- TIME PICKER (Ambil dari Sub-koleksi Jadwal) ---
  Widget _timePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jam Praktik Tersedia',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('doctors')
              .doc(widget.doctorId)
              .collection('jadwal')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();

            // Filter jadwal berdasarkan hari yang dipilih di date picker
            final selectedDayName = _getDayName(
              availableDates[selectedDateIndex],
            );
            final schedules = snapshot.data!.docs
                .map(
                  (d) =>
                      DoctorSchedule.fromMap(d.data() as Map<String, dynamic>),
                )
                .where((s) => s.day == selectedDayName)
                .toList();

            if (schedules.isEmpty) {
              return const Text(
                "Tidak ada jadwal praktik di hari ini.",
                style: TextStyle(color: Colors.red),
              );
            }

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: schedules.map((s) {
                final timeRange =
                    "${s.start.format(context)} - ${s.end.format(context)}";
                final isSelected = selectedTime == timeRange;
                return GestureDetector(
                  onTap: () => setState(() => selectedTime = timeRange),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3F6DF6)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3F6DF6)
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      timeRange,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _bookButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: selectedTime == null
            ? null
            : () {
                // Logic Booking
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Memproses janji temu: ${availableDates[selectedDateIndex].day} pada $selectedTime',
                    ),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F6DF6),
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Buat Janji Temu Sekarang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _aboutDoctor(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tentang Dokter',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'dr. $name adalah spesialis ${widget.specialist} yang berpengalaman dalam menangani berbagai kasus medis dengan pendekatan ramah pasien.',
          style: const TextStyle(color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }

  // --- HELPER METHODS ---
  String _getAbbrMonth(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _getDayName(DateTime date) {
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return days[date.weekday % 7];
  }
}
