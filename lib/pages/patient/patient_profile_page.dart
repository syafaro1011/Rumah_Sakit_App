import 'package:flutter/material.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileHeader(),
            const SizedBox(height: 16),

            _sectionCard(
              title: 'Informasi Pribadi',
              children: const [
                _infoItem(Icons.credit_card, 'NIK', '32103210984092184'),
                _infoItem(Icons.cake, 'Tanggal Lahir', '15 Mei 1996'),
                _infoItem(Icons.person, 'Jenis Kelamin', 'Laki-Laki'),
                _infoItem(Icons.bloodtype, 'Golongan Darah', 'AB'),
              ],
            ),

            _sectionCard(
              title: 'Kontak',
              children: const [
                _infoItem(Icons.email, 'Email', 'mulyono007@example.com'),
                _infoItem(Icons.phone, 'No. Telpon', '0821321324215'),
                _infoItem(
                  Icons.location_on,
                  'Alamat',
                  'Jl. Merdeka No.321, Jawa Barat',
                ),
              ],
            ),

            _sectionCard(
              title: 'Informasi Medis',
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 10),
                    const Text('Riwayat Alergi'),
                    const Spacer(),
                    _chip('Seafood'),
                    const SizedBox(width: 6),
                    _chip('Penisilin'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// BUTTONS
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F6DF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // TODO: navigate ke Edit Profile
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // TODO: logout
                },
                icon: const Icon(Icons.power_settings_new),
                label: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _profileHeader() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF3F6DF6),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Mulyono',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text('ID Pasien: #66', style: TextStyle(color: Colors.grey.shade600)),
      ],
    ),
  );
}

Widget _sectionCard({required String title, required List<Widget> children}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(value),
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
    decoration: BoxDecoration(
      color: Colors.orange.shade100,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: const TextStyle(color: Colors.orange)),
  );
}
