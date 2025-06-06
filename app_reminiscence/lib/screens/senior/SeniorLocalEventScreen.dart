import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../module/bottomNavigationBar.dart';

class SeniorLocalEventScreen extends StatefulWidget {
  @override
  _SeniorLocalEventScreenState createState() => _SeniorLocalEventScreenState();
}

class _SeniorLocalEventScreenState extends State<SeniorLocalEventScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // TODO: 이후 Firestore 연동 또는 외부 JSON에서 행사 데이터를 불러오도록 변경
  final Map<DateTime, List<Map<String, String>>> _events = {
    DateTime.utc(2025, 5, 5): [
      {"title": "00 행사", "time": "14:00", "location": "00 장소"},
    ],
    DateTime.utc(2025, 5, 10): [
      {"title": "00 행사", "time": "14:00", "location": "00 장소"},
    ],
    DateTime.utc(2025, 5, 20): [
      {"title": "00 행사", "time": "14:00", "location": "00 장소"},
    ],
  };

  List<Map<String, String>> getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  String _formattedToday() {
    final now = DateTime.now();
    return "${now.year}년 ${now.month}월 ${now.day}일";
  }

  @override
  Widget build(BuildContext context) {
    final events = getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${_focusedDay.month}월 행사', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Colors.black),
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
              titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '이번달 참여 할 행사를 선택하세요',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? Center(child: Text('선택한 날짜에 등록된 행사가 없습니다.'))
                : ListView.builder(
              padding: EdgeInsets.only(bottom: 16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventCard(event);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        color: Colors.blue,
        homeRoute: '/home_senior',
      ),
    );
  }

  Widget _buildEventCard(Map<String, String> event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 32, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${event['time']} / ${event['title']}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('${event['location']}', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.blue),
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("자세히 보기"),
            )
          ],
        ),
      ),
    );
  }
}
