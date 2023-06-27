import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wl_lead_generator/utils.dart';

class CountDown extends StatefulWidget {
  const CountDown({Key? key}) : super(key: key);

  @override
  CountDownState createState() => CountDownState();
}

class CountDownState extends State<CountDown> {
  DateTime? targetDateTime; // The fetched target date and time
  Timer? timer; // Timer to update the countdown every second

  @override
  void initState() {
    super.initState();
    fetchTargetDateTime();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchTargetDateTime() async {
    // Make an HTTP GET request to fetch the target date and time
    final response = await http.get(Uri.parse(Utils.getDateEndpoint()));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final serverDateTime = DateTime.parse(jsonResponse['date']);
      targetDateTime = serverDateTime.toUtc();

      // Start the timer to update the countdown every second
      startTimer();
    } else {
      throw Exception('Failed to fetch target date and time');
    }
  }

  void startTimer() {
    // Cancel the previous timer if it exists
    timer?.cancel();

    // Start a new timer to update the countdown every second
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  String getRemainingTime() {
    final now = DateTime.now().toUtc();
    final difference = targetDateTime?.difference(now);
    if (difference == null) return 'Fetching...';

    if (difference.isNegative) {
      timer?.cancel();
      return 'Countdown Ended';
    }

    final days = difference.inDays;
    final hours =
        difference.inHours % 24; // Remaining hours after subtracting days
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    String timeText = '';

    if (days > 0) {
      timeText += '$days : ';
    }

    timeText += '${hours.toString().padLeft(2, '0')} : ';
    timeText += '${minutes.toString().padLeft(2, '0')} : ';
    timeText += '${seconds.toString().padLeft(2, '0')}';

    return timeText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Countdown for NFT Drop',
          style: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 28),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!,
                Colors.black,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                spreadRadius: 4, // Increase the spread radius
                blurRadius: 7,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  getRemainingTime(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
