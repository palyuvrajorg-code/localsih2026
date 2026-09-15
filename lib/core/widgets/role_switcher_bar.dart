import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../constants/colors.dart';
import '../services/sync_engine.dart';
import 'sih_demo_sheet.dart';

class RoleSwitcherBar extends StatelessWidget {
  final UserRole currentRole;
  final Function(UserRole) onRoleSelected;
  final SyncStatus syncStatus;
  final VoidCallback onSimulateToggle;

  const RoleSwitcherBar({
    super.key,
    required this.currentRole,
    required this.onRoleSelected,
    required this.syncStatus,
    required this.onSimulateToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ink,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // SIH Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SIH 2026',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Role segmented selector
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildRoleSegment(
                      label: 'Elder',
                      role: UserRole.elder,
                      isSelected: currentRole == UserRole.elder,
                    ),
                    _buildRoleSegment(
                      label: 'Caregiver',
                      role: UserRole.caregiver,
                      isSelected: currentRole == UserRole.caregiver,
                    ),
                    _buildRoleSegment(
                      label: 'Doctor',
                      role: UserRole.doctor,
                      isSelected: currentRole == UserRole.doctor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Sync indicator
            _buildSyncBadge(syncStatus),
            const SizedBox(width: 6),

            // SIH Demo button
            IconButton(
              icon: const Icon(Icons.tune_rounded, color: AppColors.gold, size: 24),
              tooltip: 'SIH Demo Mode',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
              ),
              onPressed: () {
                SihDemoSheet.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSegment({
    required String label,
    required UserRole role,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onRoleSelected(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncBadge(SyncStatus status) {
    Color bg;
    IconData icon;
    String text;

    switch (status) {
      case SyncStatus.synced:
        bg = AppColors.safeGreen;
        icon = Icons.cloud_done_rounded;
        text = 'Synced';
        break;
      case SyncStatus.syncing:
        bg = AppColors.warmAmber;
        icon = Icons.sync_rounded;
        text = 'Syncing…';
        break;
      case SyncStatus.offline:
        bg = AppColors.alertRed;
        icon = Icons.cloud_off_rounded;
        text = 'Offline';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: bg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: bg,
            ),
          ),
        ],
      ),
    );
  }
}
