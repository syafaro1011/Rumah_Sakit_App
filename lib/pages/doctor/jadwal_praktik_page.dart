import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan ini untuk fix error locale
import '../../services/auth_service.dart';
import '../../pages/doctor/rekam_medis_page.dart'; // Import the RekamMedisPage class

class JadwalPraktikPage extends StatefulWidget {
  const JadwalPraktikPage({super.key});

  @override
  State<JadwalPraktikPage> createState() => _JadwalPraktikPageState();
}

class _JadwalPraktikPageState extends State<JadwalPraktikPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fix untuk error "Locale data has not been initialized"
    initializeDateFormatting('en_US', null);
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    String formattedDay = DateFormat('EEEE').format(selectedDate);
    String formattedFullDate = DateFormat('MMMM d, yyyy').format(selectedDate);
    String dateFilter = DateFormat('yyyy-MM-dd').format(selectedDate);

    bool isToday = DateFormat('yyyy-MM-dd').format(selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                SizedBox(width: 8),
                Text("Back", style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: auth.getUserData(user?.uid ?? ""),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = userSnapshot.data?.data() as Map<String, dynamic>?;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Profil
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFEAF1FF),
                        image: userData?['photoUrl'] != null && userData!['photoUrl'] != ""
                            ? DecorationImage(image: NetworkImage(userData['photoUrl']), fit: BoxFit.cover)
                            : null,
                      ),
                      child: userData?['photoUrl'] == null || userData!['photoUrl'] == ""
                          ? const Icon(Icons.person, size: 50, color: Color(0xFF3F6DF6))
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userData?['nama'] ?? "Doctor Name",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(userData?['poli'] ?? "Specialist",
                              style: const TextStyle(color: Colors.grey, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                child: Text("Jadwal Praktik Pasien", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),

              // 2. Navigasi Tanggal
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 30),
                      onPressed: () => _changeDate(-1),
                    ),
                    Column(
                      children: [
                        Text(isToday ? "Today" : formattedDay,
                            style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(formattedFullDate,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 30),
                      onPressed: () => _changeDate(1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 3. Daftar Pasien (REVISED MOCK LOGIC)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _buildPatientList(dateFilter),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPatientList(String dateFilter) {
    return StreamBuilder<QuerySnapshot>(
      key: ValueKey(dateFilter),
      stream: FirebaseFirestore.instance
          .collection('antrean')
          .where('tanggal', isEqualTo: dateFilter)
          .snapshots(),
      builder: (context, snapshot) {
        // Jika sedang loading dari Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // REVISI: Jika Firestore kosong, kita PAKSA munculkan Mock Data
        if (docs.isEmpty) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildPatientTile("Budi Santoso", "https://i.pravatar.cc/150?u=1", "08:00", {"status": "Lama"}),
              _buildPatientTile("Siti Aminah", "https://i.pravatar.cc/150?u=2", "09:15", {"status": "Baru"}),
              _buildPatientTile("Rian Hidayat", "", "10:30", {"status": "Lama"}),
              const SizedBox(height: 20),
              const Center(child: Text("Displaying dummy data (Database empty)", style: TextStyle(color: Colors.grey, fontSize: 12))),
            ],
          );
        }

        // Jika ada data asli dari Firebase
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return _buildPatientTile(
              data['nama_pasien'] ?? "Patient Name",
              data['photoUrl'] ?? "",
              data['jam'] ?? "00:00",
              data,
            );
          },
        );
      },
    );
  }

Widget _buildPatientTile(String name, String photoUrl, String time, Map<String, dynamic> fullData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // --- INI ADALAH FUNGSI NAVIGASINYA ---
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RekamMedisPage(),
                // Mengirim data pasien melalui arguments
                settings: RouteSettings(arguments: fullData),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar, Nama, dan Jam (Tetap seperti sebelumnya)
                Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF1F5FF),
                    image: photoUrl.isNotEmpty
                        ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: photoUrl.isEmpty ? const Icon(Icons.person, color: Color(0xFF3F6DF6)) : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF3F6DF6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}