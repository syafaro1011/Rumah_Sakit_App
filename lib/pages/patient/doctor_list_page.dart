import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_detail_page.dart';

class DoctorListPage extends StatelessWidget {
  final String poli;

  const DoctorListPage({super.key, required this.poli});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(poli),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('poli', isEqualTo: poli)
            .where('status', isEqualTo: 'aktif')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Dokter belum tersedia'));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEAF1FF),
                  backgroundImage:
                      (data['photoUrl'] != null &&
                              data['photoUrl'].toString().isNotEmpty)
                          ? NetworkImage(data['photoUrl'])
                          : null,
                  child: (data['photoUrl'] == null ||
                          data['photoUrl'].toString().isEmpty)
                      ? const Icon(Icons.person, color: Colors.blue)
                      : null,
                ),
                title: Text(data['nama'] ?? '-'),
                subtitle: Text(data['poli'] ?? '-'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailPage(
                        doctorId: docs[i].id,
                        name: data['nama'],
                        poli: data['poli'],
                        photoUrl: data['photoUrl'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
