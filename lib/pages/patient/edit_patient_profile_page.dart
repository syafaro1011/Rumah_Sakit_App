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

  DateTime? _selectedBirthDate;
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
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          nameController.text = data['nama'] ?? '';
          nikController.text = data['nik'] ?? '';
          final dob = data['birthDate'];
          if (dob != null) {
            DateTime? date;
            if (dob is Timestamp) {
              date = dob.toDate();
            } else if (dob is String && dob.isNotEmpty) {
              // Jika format di Firestore adalah DD-MM-YYYY
              try {
                List<String> parts = dob.split('-');
                date = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              } catch (e) {
                print("Error parsing date string: $e");
              }
            }

            if (date != null) {
              _selectedBirthDate = date;
              birthDateController.text =
                  "${date.day.toString().padLeft(2, '0')}-"
                  "${date.month.toString().padLeft(2, '0')}-"
                  "${date.year}";
            }
          }

          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';

          // --- Perbaikan Gender & BloodType ---
          // Pastikan value dari Firestore sama persis dengan List di Dropdown
          if (data['gender'] != null) {
            gender = data['gender'];
          }
          if (data['bloodType'] != null) {
            bloodType = data['bloodType'];
          }

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

  Future<void> _pickBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF3F6DF6)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        List<String> allergyList = allergyController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // Memanggil service dengan data yang sudah di-update di state
        await _profileService.updateProfile(
          nama: nameController.text,
          nik: nikController.text,
          birthDate: birthDateController.text,
          gender: gender, // Isi dengan variabel state gender
          bloodType: bloodType, // Isi dengan variabel state bloodType
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
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                        _textField(
                          'NIK',
                          nikController,
                          keyboardType: TextInputType.number,
                        ),
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
                        GestureDetector(
                          onTap: _pickBirthDate,
                          child: AbsorbPointer(
                            child: _textField(
                              'Tanggal Lahir',
                              birthDateController,
                              readOnly: true,
                              suffixIcon: Icons.calendar_today,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _sectionCard(
                      title: 'Kontak',
                      children: [
                        _textField(
                          'Email',
                          emailController,
                          readOnly: true,
                        ), // Email biasanya tidak diubah sembarang
                        _textField(
                          'No. Telpon',
                          phoneController,
                          keyboardType: TextInputType.phone,
                        ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _saveProfile,
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
        validator: (value) =>
            value == null || value.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }

  // ... (Gunakan sisa komponen UI dari kode Anda sebelumnya)
  Widget _avatarSection() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(radius: 50),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF3F6DF6),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
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
