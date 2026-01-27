import 'package:flutter/material.dart';

class DoctorDetailPage extends StatefulWidget {
  final String name;
  final String specialist;
  final String image;
  final String doctorId;

  const DoctorDetailPage({
    super.key,
    required this.name,
    required this.specialist,
    required this.image,
    required this.doctorId,
  });

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  int selectedDateIndex = 2;
  int selectedTimeIndex = 3;

  final dates = ['23', '25', '26', '30'];
  final times = ['09:00', '12:00', '13:00', '16:00', '16:30'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_horiz, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _doctorHeader(),
            const SizedBox(height: 24),
            _stats(),
            const SizedBox(height: 24),
            _schedule(),
            const SizedBox(height: 24),
            _timePicker(),
            const SizedBox(height: 28),
            _bookButton(),
            const SizedBox(height: 24),
            _aboutDoctor(),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _doctorHeader() {
    return Row(
      children: [
        CircleAvatar(radius: 32, backgroundImage: AssetImage(widget.image)),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              widget.specialist,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stats() {
    return Row(
      children: [
        _statCard('+617', 'Patients'),
        const SizedBox(width: 12),
        _statCard('+10 year', 'Experiences'),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _schedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Praktik',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(dates.length, (index) {
            final selected = selectedDateIndex == index;
            return GestureDetector(
              onTap: () => setState(() => selectedDateIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? Colors.green : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      dates[index],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'March',
                      style: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _timePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jam Praktik',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(times.length, (index) {
            final selected = selectedTimeIndex == index;
            return GestureDetector(
              onTap: () => setState(() => selectedTimeIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected ? Colors.green : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  times[index],
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _bookButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          debugPrint(
            'Booking ${widget.name} tanggal ${dates[selectedDateIndex]} jam ${times[selectedTimeIndex]}',
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F6DF6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Booking Praktik', style: TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.double_arrow, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _aboutDoctor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Tentang Dokter', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text(
          'Pellentesque placerat arcu in risus facilisis, sed laoreet eros laoreet...',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(
          icon: CircleAvatar(child: Icon(Icons.add)),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }
}
