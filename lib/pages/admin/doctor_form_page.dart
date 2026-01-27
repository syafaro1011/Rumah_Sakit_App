import 'package:flutter/material.dart';
import 'doctor_model.dart';

class DoctorFormPage extends StatefulWidget {
  final DoctorModel? initialDoctor;

  const DoctorFormPage({super.key, this.initialDoctor});

  @override
  State<DoctorFormPage> createState() => _DoctorFormPageState();
}

class _DoctorFormPageState extends State<DoctorFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController experienceController;
  late TextEditingController emailController;
  late TextEditingController sipController;
  late TextEditingController phoneController;

  String? selectedSpecialist;
  late List<DoctorSchedule> schedules;

  final List<String> specialists = [
    'Poli Umum',
    'Poli Gigi',
    'Poli Saraf',
    'Poli Anak',
  ];

  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  bool get isEdit => widget.initialDoctor != null;

  @override
  void initState() {
    super.initState();

    final d = widget.initialDoctor;

    nameController = TextEditingController(text: d?.name);
    experienceController = TextEditingController(text: d?.experience);
    emailController = TextEditingController(text: d?.email);
    sipController = TextEditingController(text: d?.sip);
    phoneController = TextEditingController(text: d?.phone);

    selectedSpecialist = d?.poli;
    schedules = d != null ? List.from(d.schedules) : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Dokter' : 'Tambah Dokter'),
        backgroundColor: const Color(0xFF3F6DF6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(),
              const SizedBox(height: 20),

              _field('Nama Lengkap *', nameController),
              _dropdown(),
              _field('Pengalaman', experienceController, hint: '10 Tahun'),
              _field('Email *', emailController),
              _field('SIP *', sipController),
              _field('Nomor Telepon *', phoneController),

              const SizedBox(height: 24),
              _scheduleHeader(),
              ..._scheduleList(),

              const SizedBox(height: 32),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _title() => Text(
    isEdit ? 'Edit Data Dokter' : 'Input Data Dokter',
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  );

  Widget _field(String label, TextEditingController c, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedSpecialist,
        items: specialists
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => selectedSpecialist = v),
        validator: (v) => v == null ? 'Wajib dipilih' : null,
        decoration: InputDecoration(
          labelText: 'Spesialis',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _scheduleHeader() {
    return Row(
      children: [
        const Text(
          'Jadwal Praktik',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: _addSchedule,
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
        ),
      ],
    );
  }

  List<Widget> _scheduleList() {
    return List.generate(schedules.length, (i) {
      final s = schedules[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: s.day,
                isExpanded: true,
                items: days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => s.day = v!),
              ),
            ),
            _time(s.start, (t) => setState(() => s.start = t)),
            const Text(' - '),
            _time(s.end, (t) => setState(() => s.end = t)),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(() => schedules.removeAt(i)),
            ),
          ],
        ),
      );
    });
  }

  Widget _time(TimeOfDay t, Function(TimeOfDay) onPick) {
    return InkWell(
      onTap: () async {
        final r = await showTimePicker(context: context, initialTime: t);
        if (r != null) onPick(r);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(t.format(context)),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F6DF6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _submit,
        child: Text(
          isEdit ? 'Simpan Perubahan' : 'Tambah Dokter',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // ================= LOGIC =================

  void _addSchedule() {
    setState(() {
      schedules.add(
        DoctorSchedule(
          day: days.first,
          start: const TimeOfDay(hour: 8, minute: 0),
          end: const TimeOfDay(hour: 13, minute: 0),
        ),
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final result = DoctorModel(
      id: widget.initialDoctor?.id ?? DateTime.now().toString(),
      name: nameController.text,
      poli: selectedSpecialist!,
      sip: sipController.text,
      email: emailController.text,
      phone: phoneController.text,
      experience: experienceController.text,
      isActive: widget.initialDoctor?.isActive ?? true,
      schedules: schedules,
    );

    Navigator.pop(context, result);
  }
}
