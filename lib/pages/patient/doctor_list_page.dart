import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_detail_page.dart';

class DoctorListPage extends StatelessWidget {
  final String poliName;

  const DoctorListPage({super.key, required this.poliName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Warna background lebih soft
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          poliName, // Menampilkan nama Poli di Header
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('poli', isEqualTo: poliName)
            .where('status', isEqualTo: 'aktif')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _errorWidget("Terjadi kesalahan. Pastikan Index Firestore sudah dibuat.");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3F6DF6)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyWidget();
          }

          final doctors = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final data = doc.data() as Map<String, dynamic>;
              final String id = doc.id;

              return _doctorCard(context, data, id);
            },
          );
        },
      ),
    );
  }

  Widget _doctorCard(BuildContext context, Map<String, dynamic> data, String id) {
    // Sinkronisasi Key dengan DoctorModel
    final String name = data['nama'] ?? 'Tanpa Nama';
    final String poli = data['poli'] ?? '-';
    final String imageUrl = data['photoUrl'] ?? ''; 

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorDetailPage(
                  doctorId: id,
                  name: name,
                  specialist: poli,
                  image: imageUrl,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar dengan handling link internet
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(imageUrl),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        poli,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      // Badge kecil untuk pengalaman/rating (Opsional)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          const SizedBox(width: 12),
                          const Icon(Icons.work_outline, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            "${data['experience'] ?? '0'} Thn",
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty || !url.startsWith('http')) {
      return Image.asset('assets/images/default.png', fit: BoxFit.cover);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
        ));
      },
    );
  }

  Widget _emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada dokter di poli ini", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _errorWidget(String msg) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
    ));
  }
}