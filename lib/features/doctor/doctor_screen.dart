import 'package:flutter/material.dart';
import '../../store.dart';
import '../../data/models/models.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/services/adaptive_engine.dart';

class DoctorScreen extends StatefulWidget {
  final AppStore store;
  const DoctorScreen({super.key, required this.store});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  void _startTelehealthConsultation(Appointment apt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _TelehealthConsultationDialog(
        appointment: apt,
        store: widget.store,
      ),
    );
  }

  void _showBookAppointmentDialog() {
    final docCtrl = TextEditingController(text: 'Dr. R. Sharma');
    final noteCtrl = TextEditingController(text: 'Cognitive checkup and medication review');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Schedule Specialist Review', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: docCtrl,
              decoration: const InputDecoration(labelText: 'Specialist Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Clinical Notes / Purpose'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white),
            onPressed: () {
              final newApt = Appointment(
                id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
                doctorName: docCtrl.text.trim(),
                specialty: 'Geriatric Neurologist',
                dateTime: DateTime.now().add(const Duration(days: 2)),
                status: AppointmentStatus.upcoming,
                location: 'SMRITI Telehealth Consultation',
                isTelehealth: true,
                notes: noteCtrl.text.trim(),
              );
              widget.store.appointments.insert(0, newApt);
              widget.store.notifyListeners();
              Navigator.pop(ctx);
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;

    return AnimatedBuilder(
      animation: s,
      builder: (context, _) {
        final appointments = s.appointments;
        final recentSessions = s.sessions.map((m) => GameResult.fromJson(m)).toList();
        final perf = AdaptiveCognitiveEngine.summarizePerformance(recentSessions);

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clinical Portal', style: TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w600)),
                Text('Dr. R. Sharma (Geriatric Care)', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.green, size: 28),
                tooltip: 'Book Appointment',
                onPressed: _showBookAppointmentDialog,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Notice: Telehealth does not replace hands-on care
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.health_and_safety_outlined, color: AppColors.green, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Clinical decision support: Telehealth insights assist specialists and family caregivers.',
                        style: TextStyle(fontSize: 13, color: AppColors.ink, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Patient Summary Card
              SmritiCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Patient: ${s.elderProfile.name} (${s.elderProfile.age}y)',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Stable Adherence',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.green),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Caregiver: ${s.elderProfile.caregiverName} (${s.elderProfile.emergencyPhone})',
                      style: const TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    Text(
                      'Primary Address: ${s.elderProfile.address}',
                      style: const TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    const Divider(height: 20, color: AppColors.line),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildClinicalStat('Active Prescriptions', '${s.medications.length}'),
                        _buildClinicalStat('Cognitive Engagement', '${perf['totalSessions']} sessions'),
                        _buildClinicalStat('Avg Response', '${perf['averageResponseMs']}ms'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Telehealth & Appointments Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TELEHEALTH APPOINTMENTS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.muted,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showBookAppointmentDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Schedule Review'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...appointments.map((apt) {
                final isUpcoming = apt.status == AppointmentStatus.upcoming;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SmritiCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              apt.doctorName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isUpcoming
                                    ? AppColors.green.withValues(alpha: 0.15)
                                    : AppColors.muted.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                apt.status.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isUpcoming ? AppColors.green : AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${apt.specialty} • ${apt.location}',
                          style: const TextStyle(fontSize: 14, color: AppColors.muted),
                        ),
                        if (apt.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Notes: ${apt.notes}',
                            style: const TextStyle(fontSize: 14, color: AppColors.ink),
                          ),
                        ],
                        if (isUpcoming && apt.isTelehealth) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => _startTelehealthConsultation(apt),
                              icon: const Icon(Icons.video_call_rounded, size: 24),
                              label: const Text(
                                'Launch Telehealth Video Consultation',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClinicalStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ],
    );
  }
}

class _TelehealthConsultationDialog extends StatefulWidget {
  final Appointment appointment;
  final AppStore store;
  const _TelehealthConsultationDialog({required this.appointment, required this.store});

  @override
  State<_TelehealthConsultationDialog> createState() => _TelehealthConsultationDialogState();
}

class _TelehealthConsultationDialogState extends State<_TelehealthConsultationDialog> {
  int _callSeconds = 0;
  bool _micMuted = false;
  bool _cameraOn = true;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _callSeconds++);
      return true;
    });
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: Text('Telehealth: ${widget.appointment.doctorName}'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  _formatTime(_callSeconds),
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Doctor Video Feed Simulation
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF1A202C),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.green,
                          child: Icon(Icons.person, size: 64, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.appointment.doctorName,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          widget.appointment.specialty,
                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Secure Video Encrypted Session',
                          style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // Patient self-view PiP
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Container(
                      width: 110,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white30, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Image.asset('assets/images/courtyard.jpg', fit: BoxFit.cover, height: double.infinity, width: double.infinity),
                            Container(
                              color: Colors.black38,
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.all(4),
                              child: const Text('Kamala Devi', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Telehealth Control Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: _micMuted ? Colors.red : Colors.white24,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: Icon(_micMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                    onPressed: () => setState(() => _micMuted = !_micMuted),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: !_cameraOn ? Colors.red : Colors.white24,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: Icon(!_cameraOn ? Icons.videocam_off : Icons.videocam, color: Colors.white),
                    onPressed: () => setState(() => _cameraOn = !_cameraOn),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.call_end),
                    label: const Text('End Consultation', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
