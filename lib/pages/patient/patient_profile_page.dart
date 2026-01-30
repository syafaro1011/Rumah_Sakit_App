import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumahsakitapp/services/patient_profile_service.dart';
import '../widgets/patient_bottom_nav.dart';
import 'edit_patient_profile_page.dart';
import '../login_page.dart';


class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final PatientProfileService _profileService = PatientProfileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const PatientBottomNav(currentIndex: 1),
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _profileService.getPatientProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data profil tidak ditemukan"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _profileHeader(data),
                const SizedBox(height: 16),
                _sectionCard(
                  title: 'Informasi Pribadi',
                  children: [
                    _infoItem(Icons.credit_card, 'NIK', data['nik'] ?? '-'),
                    _infoItem(Icons.cake, 'Tanggal Lahir', data['birthDate'] ?? '-'),
                    _infoItem(Icons.person, 'Jenis Kelamin', data['gender'] ?? '-'),
                    _infoItem(Icons.bloodtype, 'Golongan Darah', data['bloodType'] ?? '-'),
                  ],
                ),
                _sectionCard(
                  title: 'Kontak',
                  children: [
                    _infoItem(Icons.email, 'Email', data['email'] ?? '-'),
                    _infoItem(Icons.phone, 'No. Telpon', data['phone'] ?? '-'),
                    _infoItem(Icons.location_on, 'Alamat', data['address'] ?? '-'),
                  ],
                ),
                _sectionCard(
                  title: 'Informasi Medis',
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                        const SizedBox(width: 10),
                        const Text('Riwayat Alergi', style: TextStyle(fontSize: 14)),
                        const Spacer(),
                        _buildAllergyChips(data['allergies'] ?? []),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _actionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileHeader(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.blue.shade50,
            backgroundImage: (data['photoUrl'] != null && data['photoUrl'] != "")
                ? NetworkImage(data['photoUrl'])
                : const AssetImage('assets/images/avatar.png') as ImageProvider,
          ),
          const SizedBox(height: 12),
          Text(
            data['name'] ?? 'Pasien',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'ID Pasien: #${data['patientId'] ?? '---'}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyChips(dynamic allergies) {
    List<dynamic> allergyList = allergies is List ? allergies : [];
    if (allergyList.isEmpty) return const Text('Tidak Ada', style: TextStyle(color: Colors.grey));
    
    return Wrap(
      spacing: 6,
      children: allergyList.map((a) => _chip(a.toString())).toList(),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        _largeButton(
          label: 'Edit Profile',
          icon: Icons.edit,
          color: const Color(0xFF3F6DF6),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditPatientProfilePage()),
          ),
        ),
        const SizedBox(height: 12),
        _largeButton(
          label: 'Sign Out',
          icon: Icons.power_settings_new,
          color: Colors.red,
          onTap: () => _showSignOutConfirmation(context),
        ),
      ],
    );
  }

  Widget _largeButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await _profileService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Global/Helper Widgets tetap sama seperti kode Anda sebelumnya (dengan sedikit tweak styling)
Widget _sectionCard({required String title, required List<Widget> children}) {
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
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

class _infoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _infoItem(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: const Color(0xFF3F6DF6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _chip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade100)),
    child: Text(text, style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.w500)),
  );
}