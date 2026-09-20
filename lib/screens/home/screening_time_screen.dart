import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/screening_time_api_service.dart';

class ScreeningTimeScreen extends StatefulWidget {
  const ScreeningTimeScreen({super.key});

  @override
  State<ScreeningTimeScreen> createState() =>
      _ScreeningTimeScreenState();
}

class _ScreeningTimeScreenState
    extends State<ScreeningTimeScreen> {
  // ============================================================
  // TIME VALUES
  // Stored as seconds from midnight.
  // ============================================================

  int morningStart =
      12 * 60 * 60;

  int morningEnd =
      12 * 60 * 60 + 7 * 60;

  int morningPhoneEnd =
      15 * 60 * 60;

  int eveningStart =
      19 * 60 * 60;

  int eveningEnd =
      19 * 60 * 60 + 7 * 60;

  int eveningPhoneEnd =
      23 * 60 * 60;

  // ============================================================
  // STATE
  // ============================================================

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    _loadTimes();
  }

  // ============================================================
  // LOAD FROM API
  // ============================================================

  Future<void> _loadTimes() async {
    setState(() {
      loading = true;
    });

    try {
      final records =
      await ScreeningTimeApiService
          .getScreeningTimes();

      for (final record in records) {
        final timeId =
        int.tryParse(
          record['timeId']?.toString() ?? '',
        );

        if (timeId == 1) {
          final start =
          _parseTime(
            record['screeningStart'],
          );

          final end =
          _parseTime(
            record['screeningEnd'],
          );

          final phoneEnd =
          _parseTime(
            record['phoneBookingEnd'],
          );

          if (start != null) {
            morningStart = start;
          }

          if (end != null) {
            morningEnd = end;
          }

          if (phoneEnd != null) {
            morningPhoneEnd = phoneEnd;
          }
        }

        if (timeId == 2) {
          final start =
          _parseTime(
            record['screeningStart'],
          );

          final end =
          _parseTime(
            record['screeningEnd'],
          );

          final phoneEnd =
          _parseTime(
            record['phoneBookingEnd'],
          );

          if (start != null) {
            eveningStart = start;
          }

          if (end != null) {
            eveningEnd = end;
          }

          if (phoneEnd != null) {
            eveningPhoneEnd = phoneEnd;
          }
        }
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to load screening times: $e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (saving) return;

    setState(() {
      saving = true;
    });

    try {
      // ----------------------------------------------------------
      // MORNING - TimeID 1
      // ----------------------------------------------------------

      await ScreeningTimeApiService
          .updateScreeningTime(
        timeId: 1,
        screeningStart:
        _formatTime(morningStart),
        screeningEnd:
        _formatTime(morningEnd),
        phoneBookingEnd:
        _formatTime(morningPhoneEnd),
      );

      // ----------------------------------------------------------
      // EVENING - TimeID 2
      // ----------------------------------------------------------

      await ScreeningTimeApiService
          .updateScreeningTime(
        timeId: 2,
        screeningStart:
        _formatTime(eveningStart),
        screeningEnd:
        _formatTime(eveningEnd),
        phoneBookingEnd:
        _formatTime(eveningPhoneEnd),
      );

      if (!mounted) return;

      _showMessage(
        'Screening times saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save screening times: $e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        saving = false;
      });
    }
  }

  // ============================================================
  // PERIOD SECTION
  // ============================================================

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
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 20),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // TIME SPINNER
  // ============================================================

  Widget _buildTimeSpinner({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade500,
                    ),
                    borderRadius:
                    BorderRadius.circular(6),
                  ),
                  alignment:
                  Alignment.centerLeft,
                  child: Text(
                    _formatTime(value),
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8),

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius:
                  BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: saving || loading
                            ? null
                            : () {
                          onChanged(
                            _increaseTime(
                              value,
                            ),
                          );
                        },
                        child: Center(
                          child: Icon(
                            Icons
                                .keyboard_arrow_up,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      height: 1,
                      color:
                      Colors.grey.shade400,
                    ),

                    Expanded(
                      child: InkWell(
                        onTap: saving || loading
                            ? null
                            : () {
                          onChanged(
                            _decreaseTime(
                              value,
                            ),
                          );
                        },
                        child: Center(
                          child: Icon(
                            Icons
                                .keyboard_arrow_down,
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

  // ============================================================
  // INCREASE TIME
  // ============================================================

  int _increaseTime(int value) {
    int newValue = value + 60;

    if (newValue >= 24 * 60 * 60) {
      newValue = 0;
    }

    return newValue;
  }

  // ============================================================
  // DECREASE TIME
  // ============================================================

  int _decreaseTime(int value) {
    int newValue = value - 60;

    if (newValue < 0) {
      newValue =
          (24 * 60 * 60) - 60;
    }

    return newValue;
  }

  // ============================================================
  // PARSE HH:mm:ss
  // ============================================================

  int? _parseTime(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString();

    final parts = text.split(':');

    if (parts.length != 3) {
      return null;
    }

    final hours =
    int.tryParse(parts[0]);

    final minutes =
    int.tryParse(parts[1]);

    final seconds =
    int.tryParse(parts[2]);

    if (hours == null ||
        minutes == null ||
        seconds == null) {
      return null;
    }

    if (hours < 0 ||
        hours > 23 ||
        minutes < 0 ||
        minutes > 59 ||
        seconds < 0 ||
        seconds > 59) {
      return null;
    }

    return hours * 3600 +
        minutes * 60 +
        seconds;
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(
      int totalSeconds,
      ) {
    final hours =
        totalSeconds ~/ 3600;

    final minutes =
        (totalSeconds % 3600) ~/ 60;

    final seconds =
        totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(AppTranslations.tr('Screening Time')),
      ),
      body: loading
          ? Center(
        child:
        CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,
          children: [
            // ==================================================
            // MORNING
            // ==================================================

            _buildPeriodSection(
              title: 'Morning Period',
              children: [
                _buildTimeSpinner(
                  label:
                  'Screening Start',
                  value:
                  morningStart,
                  onChanged:
                      (value) {
                    setState(() {
                      morningStart =
                          value;
                    });
                  },
                ),

                _buildTimeSpinner(
                  label:
                  'Screening End',
                  value:
                  morningEnd,
                  onChanged:
                      (value) {
                    setState(() {
                      morningEnd =
                          value;
                    });
                  },
                ),

                _buildTimeSpinner(
                  label:
                  'Phone Booking Ends',
                  value:
                  morningPhoneEnd,
                  onChanged:
                      (value) {
                    setState(() {
                      morningPhoneEnd =
                          value;
                    });
                  },
                ),
              ],
            ),

            SizedBox(
              height: 24,
            ),

            // ==================================================
            // EVENING
            // ==================================================

            _buildPeriodSection(
              title: 'Evening Period',
              children: [
                _buildTimeSpinner(
                  label:
                  'Screening Start',
                  value:
                  eveningStart,
                  onChanged:
                      (value) {
                    setState(() {
                      eveningStart =
                          value;
                    });
                  },
                ),

                _buildTimeSpinner(
                  label:
                  'Screening End',
                  value:
                  eveningEnd,
                  onChanged:
                      (value) {
                    setState(() {
                      eveningEnd =
                          value;
                    });
                  },
                ),

                _buildTimeSpinner(
                  label:
                  'Phone Booking Ends',
                  value:
                  eveningPhoneEnd,
                  onChanged:
                      (value) {
                    setState(() {
                      eveningPhoneEnd =
                          value;
                    });
                  },
                ),
              ],
            ),

            SizedBox(
              height: 24,
            ),

            // ==================================================
            // SAVE
            // ==================================================

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                saving
                    ? null
                    : _save,
                child: Text(
                  saving
                      ? 'Saving...'
                      : 'Save',
                  style:
                  const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}