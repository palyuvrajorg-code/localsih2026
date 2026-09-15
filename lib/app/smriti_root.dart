import 'package:flutter/material.dart';
import '../store.dart';
import '../data/models/models.dart';
import '../core/widgets/role_switcher_bar.dart';
import '../features/elder_home/elder_shell.dart';
import '../features/caregiver/caregiver_dashboard_screen.dart';
import '../features/doctor/doctor_screen.dart';

class SmritiRoot extends StatelessWidget {
  final AppStore store;
  const SmritiRoot({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([store, store.syncEngine]),
      builder: (context, _) {
        final currentRole = store.currentRole;
        final syncStatus = store.syncEngine.status;

        Widget roleBody;
        switch (currentRole) {
          case UserRole.elder:
            roleBody = ElderShell(store: store);
            break;
          case UserRole.caregiver:
            roleBody = CaregiverDashboardScreen(store: store);
            break;
          case UserRole.doctor:
            roleBody = DoctorScreen(store: store);
            break;
        }

        return Scaffold(
          body: Column(
            children: [
              RoleSwitcherBar(
                currentRole: currentRole,
                onRoleSelected: (role) => store.switchRole(role),
                syncStatus: syncStatus,
                onSimulateToggle: () {
                  if (store.syncEngine.isOffline) {
                    store.restoreInternet();
                  } else {
                    store.simulateOfflineMode();
                  }
                },
              ),
              Expanded(child: roleBody),
            ],
          ),
        );
      },
    );
  }
}
