import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class DoctorFormPage extends StatefulWidget {
  final String? doctorId;
  final Map<String, dynamic>? initialData;

  const DoctorFormPage({super.key, this.doctorId, this.initialData});

  @override
  State<DoctorFormPage> createState() => _DoctorFormPageState();
}

class _DoctorFormPageState extends State<DoctorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  late TextEditingController namaC;
  late TextEditingController emailC;
  late TextEditingController passwordC;
  late TextEditingController noStrC;
  late TextEditingController noHpC;

  String? selectedPoli;

  bool get isEdit => widget.doctorId != null;

  final List<String> poliList = [
    'Poli Umum',
    'Poli Gigi',
    'Poli Saraf',
    'Poli Mata',
    'Poli Anak',
  ];

  @override
  void initState() {
    super.initState();

    final d = widget.initialData;

    namaC = TextEditingController(text: d?['nama']);
    emailC = TextEditingController(text: d?['email']);
    passwordC = TextEditingController();
    noStrC = TextEditingController(text: d?['no_str']);
    noHpC = TextEditingController(text: d?['no_hp']);
    selectedPoli = d?['poli'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Dokter' : 'Tambah Dokter'),
        backgroundColor: const Color(0xFF3F6DF6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field('Nama Dokter', namaC),
              _dropdown(),
              _field('Email', emailC, enabled: !isEdit),
              if (!isEdit) _field('Password', passwordC, obscure: true),
              _field('No STR', noStrC),
              _field('No HP', noHpC),
              const SizedBox(height: 24),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _field(
    String label,
    TextEditingController c, {
    bool obscure = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        enabled: enabled,
        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedPoli,
        items: poliList
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => selectedPoli = v),
        validator: (v) => v == null ? 'Wajib dipilih' : null,
        decoration: InputDecoration(
          labelText: 'Poli',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3F6DF6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: _submit,
      child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Dokter'),
    );
  }

  // ================= LOGIC =================

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isEdit) {
        await _adminService.updateDoctor(widget.doctorId!, {
          'nama': namaC.text,
          'poli': selectedPoli,
          'no_str': noStrC.text,
          'no_hp': noHpC.text,
        });
      } else {
        await _adminService.createDoctor(
          nama: namaC.text,
          poli: selectedPoli!,
          email: emailC.text,
          password: passwordC.text,
          noStr: noStrC.text,
          noHp: noHpC.text,
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }
}
