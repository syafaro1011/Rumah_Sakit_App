import 'package:flutter/material.dart';

class EditPatientProfilePage extends StatefulWidget {
  const EditPatientProfilePage({super.key});

  @override
  State<EditPatientProfilePage> createState() => _EditPatientProfilePageState();
}

class _EditPatientProfilePageState extends State<EditPatientProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController(
    text: 'Mulyono',
  );
  final TextEditingController nikController = TextEditingController(
    text: '32103210984092184',
  );
  final TextEditingController birthDateController = TextEditingController(
    text: '15 Mei 1996',
  );
  final TextEditingController emailController = TextEditingController(
    text: 'mulyono007@example.com',
  );
  final TextEditingController phoneController = TextEditingController(
    text: '0821321324215',
  );
  final TextEditingController addressController = TextEditingController(
    text: 'Jl. Merdeka No.321, Jawa Barat',
  );
  final TextEditingController allergyController = TextEditingController(
    text: 'Seafood, Penisilin',
  );

  String gender = 'Laki-Laki';
  String bloodType = 'AB';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _avatarSection(),
              const SizedBox(height: 16),

              _sectionCard(
                title: 'Informasi Pribadi',
                children: [
                  _textField('Nama Lengkap', nameController),
                  _textField('NIK', nikController),
                  _dropdownField(
                    label: 'Jenis Kelamin',
                    value: gender,
                    items: const ['Laki-Laki', 'Perempuan'],
                    onChanged: (v) => setState(() => gender = v!),
                  ),
                  _dropdownField(
                    label: 'Golongan Darah',
                    value: bloodType,
                    items: const ['A', 'B', 'AB', 'O'],
                    onChanged: (v) => setState(() => bloodType = v!),
                  ),
                  _textField(
                    'Tanggal Lahir',
                    birthDateController,
                    readOnly: true,
                    suffixIcon: Icons.calendar_today,
                  ),
                ],
              ),

              _sectionCard(
                title: 'Kontak',
                children: [
                  _textField('Email', emailController),
                  _textField('No. Telpon', phoneController),
                  _textField('Alamat', addressController, maxLines: 3),
                ],
              ),

              _sectionCard(
                title: 'Informasi Medis',
                children: [
                  _textField(
                    'Riwayat Alergi',
                    allergyController,
                    hint: 'Pisahkan dengan koma',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F6DF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _saveProfile,
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== LOGIC =====================

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Integrasi Firestore / API
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    }
  }

  // ===================== UI COMPONENT =====================

  Widget _avatarSection() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 46,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF3F6DF6),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
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

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    int maxLines = 1,
    String? hint,
    IconData? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
