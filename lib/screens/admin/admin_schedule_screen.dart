import 'package:flutter/material.dart';

import '../../app/colors.dart';

class AdminScheduleScreen extends StatelessWidget {
  const AdminScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schedules = [
      {
        'name': 'Ayu Lestari',
        'date': 'Senin, 12 Mei 2025',
        'time': '09.00 - 09.30',
        'room': 'Ruang A',
      },
      {
        'name': 'Rizky Pratama',
        'date': 'Senin, 12 Mei 2025',
        'time': '09.30 - 10.00',
        'room': 'Ruang A',
      },
      {
        'name': 'Nabila Putri',
        'date': 'Senin, 12 Mei 2025',
        'time': '10.00 - 10.30',
        'room': 'Ruang B',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Jadwal Wawancara',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Atur dan pantau jadwal wawancara peserta.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        ...schedules.map((item) {
          return _ScheduleCard(
            name: item['name']!,
            date: item['date']!,
            time: item['time']!,
            room: item['room']!,
          );
        }),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String name;
  final String date;
  final String time;
  final String room;

  const _ScheduleCard({
    required this.name,
    required this.date,
    required this.time,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$time • $room',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}