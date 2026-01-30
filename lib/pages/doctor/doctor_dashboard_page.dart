import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import 'jadwal_praktik_page.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  DateTime selectedDate = DateTime.now();
  
  final List<String> allTimeSlots = [
    "08:00", "09:00", "10:00", "11:00", 
    "13:00", "14:00", "15:00", "16:00"
  ];

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    String dateFilter = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 28),
              onPressed: () => auth.signOut().then((_) => Navigator.pushReplacementNamed(context, '/login')),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: auth.getUserData(user?.uid ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          var userData = snapshot.data?.data() as Map<String, dynamic>?;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildHeader(userData),
                const SizedBox(height: 30),
                _buildNavigationBanner(context),
                const SizedBox(height: 30),
                
                // REVISI: Row Stat Card yang sekarang lebih ramping dan konsisten
                Row(
  children: [
    Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medical_records')
            .where('doctorId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          int totalPatients = snapshot.data?.docs.length ?? 0;

          return _buildStatCard("Patients", "+$totalPatients");
        },
      ),
    ),
    const SizedBox(width: 16),
    _buildStatCard(
      "Experiences",
      "+${userData?['experience'] ?? '0'} year",
    ),
  ],
),

                const SizedBox(height: 35),

                const Text("Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildHorizontalCalendar(),
                
                const SizedBox(height: 35),
                const Text("Time Slots Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildTimeGrid(dateFilter, key: ValueKey(dateFilter)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- LOGIKA TIME GRID ---
  Widget _buildTimeGrid(String dateFilter, {required Key key}) {
  final auth = AuthService();
  final doctorId = auth.currentUser?.uid;

  return StreamBuilder<QuerySnapshot>(
    key: key,
    stream: FirebaseFirestore.instance
        .collection('antrean')
        .where('tanggal', isEqualTo: dateFilter)
        .where('doctorId', isEqualTo: doctorId) // 🔥 FILTER DOKTER
        .snapshots(),
    builder: (context, snapshot) {
      List<String> bookedTimes = [];

      if (snapshot.hasData) {
        bookedTimes = snapshot.data!.docs
            .map((doc) =>
                (doc.data() as Map<String, dynamic>)['jam'].toString())
            .toList();
      }

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: allTimeSlots.map((time) {
          bool isBooked = bookedTimes.contains(time);
          return _buildTimeChip(time, isBooked);
        }).toList(),
      );
    },
  );
}


  Widget _buildTimeChip(String time, bool isBooked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isBooked ? const Color(0xFF3F6DF6) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBooked ? const Color(0xFF3F6DF6) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isBooked ? Colors.white : Colors.black26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- KOMPONEN UI LAINNYA ---
  Widget _buildHorizontalCalendar() {
  DateTime today = DateTime.now();

  return SizedBox(
    height: 95,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: 7, // 7 hari ke depan
      itemBuilder: (context, index) {
        DateTime date = today.add(Duration(days: index));
        return _buildAnimatedDateCard(
          date.day.toString(),
          DateFormat('MMMM').format(date),
          date.year,
          date.month,
        );
      },
    ),
  );
}


  Widget _buildAnimatedDateCard(String day, String month, int year, int monthNum) {
    bool isSelected = selectedDate.day.toString() == day && selectedDate.month == monthNum;
    return GestureDetector(
      onTap: () => setState(() => selectedDate = DateTime(year, monthNum, int.parse(day))),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3F6DF6) : const Color(0xFFF1F5FF),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected 
            ? [BoxShadow(color: const Color(0xFF3F6DF6).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] 
            : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF3F6DF6))),
            Text(month, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : const Color(0xFF3F6DF6))),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? userData) {
    return Row(
      children: [
        Hero(
          tag: 'profile_pic',
          child: Container(
            width: 85, height: 85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFEAF1FF),
              image: userData?['photoUrl'] != null && userData!['photoUrl'] != ""
                  ? DecorationImage(image: NetworkImage(userData['photoUrl']), fit: BoxFit.cover)
                  : null,
            ),
            child: userData?['photoUrl'] == null || userData!['photoUrl'] == ""
                ? const Icon(Icons.person, size: 45, color: Color(0xFF3F6DF6)) : null,
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userData?['nama'] ?? "Nama Dokter", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(userData?['poli'] ?? "Spesialis", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationBanner(BuildContext context) {
    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JadwalPraktikPage())),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: const Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
              SizedBox(width: 12),
              Text("Jadwal Praktik Pasien", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  // REVISI: Widget Stat Card dengan ukuran yang proporsional dan warna abu terang
  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12), // Padding dikurangi agar tidak kebesaran
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F9), // Warna abu-abu ultra-light
          borderRadius: BorderRadius.circular(18), // Radius disamakan dengan box schedule
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20, // Ukuran font disesuaikan agar proporsional
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}