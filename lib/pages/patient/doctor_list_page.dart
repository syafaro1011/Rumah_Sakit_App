import 'package:flutter/material.dart';
import 'doctor_detail_page.dart';

class DoctorListPage extends StatelessWidget {
  final String poliName;

  const DoctorListPage({super.key, required this.poliName});

  @override
  Widget build(BuildContext context) {
    final doctors = _dummyDoctors[poliName] ?? []; //MASIH DUMMY

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Doctors', style: TextStyle(color: Colors.black)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              poliName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return _doctorCard(context, doctor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doctorCard(BuildContext context, Map<String, String> doctor) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorDetailPage(
                name: doctor['name']!,
                specialist: doctor['specialist']!,
                image: doctor['image']!,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(doctor['image']!),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['specialist']!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// DATA DUMMY DOKTER

final Map<String, List<Map<String, String>>> _dummyDoctors = {
  'Poli Mata': [
    {
      'name': 'Dr. Floyd Miles',
      'specialist': 'Ophthalmologist',
      'image': 'assets/images/doctor1.png',
    },
    {
      'name': 'Dr. Guy Hawkins',
      'specialist': 'Eye Specialist',
      'image': 'assets/images/doctor2.png',
    },
    {
      'name': 'Dr. Jane Cooper',
      'specialist': 'Ophthalmologist',
      'image': 'assets/images/doctor3.png',
    },
    {
      'name': 'Dr. Jacob Jones',
      'specialist': 'Eye Surgeon',
      'image': 'assets/images/doctor4.png',
    },
    {
      'name': 'Dr. Savannah Nguyen',
      'specialist': 'Eye Specialist',
      'image': 'assets/images/doctor5.png',
    },
  ],
};
