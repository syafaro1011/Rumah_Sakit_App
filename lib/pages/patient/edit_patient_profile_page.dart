import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumahsakitapp/services/patient_profile_service.dart';

class EditPatientProfilePage extends StatefulWidget {
  const EditPatientProfilePage({super.key});

  @override
  State<EditPatientProfilePage> createState() => _EditPatientProfilePageState();
}

class _EditPatientProfilePageState extends State<EditPatientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final PatientProfileService _profileService = PatientProfileService();
  bool _isLoading = false;

  // Controllers (Inisialisasi kosong, akan diisi di initState)
  final nameController = TextEditingController();
  final nikController = TextEditingController();
  final birthDateController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final allergyController = TextEditingController();

  String gender = 'Laki-Laki';
  String bloodType = 'A';

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  // Mengambil data awal dari Firestore
  void _loadCurrentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          nameController.text = data['name'] ?? '';
          nikController.text = data['nik'] ?? '';
          birthDateController.text = data['dob'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
          gender = data['gender'] ?? 'Laki-Laki';
          bloodType = data['bloodType'] ?? 'A';
          
          // Konversi List ke String untuk TextField
          List<dynamic> allergies = data['allergies'] ?? [];
          allergyController.text = allergies.join(', ');
        });
      }
    }
  }

  @override
  void dispose() {
    // Selalu dispose controller untuk menghindari memory leak
    nameController.dispose();
    nikController.dispose();
    birthDateController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    allergyController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Pecah string alergi kembali menjadi List
        List<String> allergyList = allergyController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        await _profileService.updateProfile(
          name: nameController.text,
          nik: nikController.text,
          gender: gender,
          bloodType: bloodType,
          phone: phoneController.text,
          address: addressController.text,
          allergies: allergyList,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui profil: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _avatarSection(),
                    const SizedBox(height: 24),
                    _sectionCard(
                      title: 'Informasi Pribadi',
                      children: [
                        _textField('Nama Lengkap', nameController),
                        _textField('NIK', nikController, keyboardType: TextInputType.number),
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
                        _textField('Email', emailController, readOnly: true), // Email biasanya tidak diubah sembarang
                        _textField('No. Telpon', phoneController, keyboardType: TextInputType.phone),
                        _textField('Alamat', addressController, maxLines: 3),
                      ],
                    ),
                    _sectionCard(
                      title: 'Informasi Medis',
                      children: [
                        _textField(
                          'Riwayat Alergi',
                          allergyController,
                          hint: 'Contoh: Seafood, Debu, Penisilin',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F6DF6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _saveProfile,
                        child: const Text('Simpan Perubahan', 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- UI Components (Avatar, SectionCard, TextField) tetap seperti kode Anda ---
  // Pastikan menambahkan parameter keyboardType pada _textField agar UX lebih baik
  Widget _textField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    int maxLines = 1,
    String? hint,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }

  // ... (Gunakan sisa komponen UI dari kode Anda sebelumnya)
  Widget _avatarSection() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF3F6DF6),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                onPressed: () {
                  // Tambahkan fungsi image picker di sini jika diperlukan
                },
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
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
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
        value: items.contains(value) ? value : items.first,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}