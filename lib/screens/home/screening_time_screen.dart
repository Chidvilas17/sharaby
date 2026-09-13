import 'package:flutter/material.dart';

class ScreeningTimeScreen extends StatefulWidget {
  const ScreeningTimeScreen({super.key});

  @override
  State<ScreeningTimeScreen> createState() =>
      _ScreeningTimeScreenState();
}

class _ScreeningTimeScreenState extends State<ScreeningTimeScreen> {
  // Times are stored as seconds from midnight.
  int morningStart = 0; // 12:00:00
  int morningEnd = 7 * 60; // 12:07:00
  int morningPhoneEnd = 15 * 60; // 15:00:00

  int eveningStart = 19 * 60; // 19:00:00
  int eveningEnd = 19 * 60 + 7; // 19:00:07
  int eveningPhoneEnd = 23 * 60; // 23:00:00

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening Time'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =========================
            // MORNING PERIOD
            // =========================
            _buildPeriodSection(
              title: 'Morning Period',
              children: [
                _buildTimeSpinner(
                  label: 'Screening Start',
                  value: morningStart,
                  onChanged: (value) {
                    setState(() {
                      morningStart = value;
                    });
                  },
                ),

                _buildTimeSpinner(
                  label: 'Screening End',
                  value: morningEnd,
                  onChanged: (value) {
                    setState(() {
                      morningEnd = value;
                    });
                  },
                ),

                _buildTimeSpinner(
                  label: 'Phone Booking Ends',
                  value: morningPhoneEnd,
                  onChanged: (value) {
                    setState(() {
                      morningPhoneEnd = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =========================
            // EVENING PERIOD
            // =========================
            _buildPeriodSection(
              title: 'Evening Period',
              children: [
                _buildTimeSpinner(
                  label: 'Screening Start',
                  value: eveningStart,
                  onChanged: (value) {
                    setState(() {
                      eveningStart = value;
                    });
                  },
                ),

                _buildTimeSpinner(
                  label: 'Screening End',
                  value: eveningEnd,
                  onChanged: (value) {
                    setState(() {
                      eveningEnd = value;
                    });
                  },
                ),

                _buildTimeSpinner(
                  label: 'Phone Booking Ends',
                  value: eveningPhoneEnd,
                  onChanged: (value) {
                    setState(() {
                      eveningPhoneEnd = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =========================
            // SAVE
            // =========================
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================
  // PERIOD SECTION
  // =========================

  Widget _buildPeriodSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          ...children,
        ],
      ),
    );
  }

  // =========================
  // TIME SPINNER
  // =========================

  Widget _buildTimeSpinner({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              // Time display
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade500,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatTime(value),
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Up / Down buttons
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          onChanged(
                            _increaseTime(value),
                          );
                        },
                        child: const Center(
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      height: 1,
                      color: Colors.grey.shade400,
                    ),

                    Expanded(
                      child: InkWell(
                        onTap: () {
                          onChanged(
                            _decreaseTime(value),
                          );
                        },
                        child: const Center(
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // INCREASE TIME
  // =========================

  int _increaseTime(int value) {
    // Increase by one minute.
    int newValue = value + 60;

    if (newValue >= 24 * 60 * 60) {
      newValue = 0;
    }

    return newValue;
  }

  // =========================
  // DECREASE TIME
  // =========================

  int _decreaseTime(int value) {
    // Decrease by one minute.
    int newValue = value - 60;

    if (newValue < 0) {
      newValue = (24 * 60 * 60) - 60;
    }

    return newValue;
  }

  // =========================
  // FORMAT 24-HOUR TIME
  // =========================

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;

    final minutes =
        (totalSeconds % 3600) ~/ 60;

    final seconds =
        totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // =========================
  // SAVE
  // =========================

  void _save() {
    // Database/API functionality will be connected later.
  }
}