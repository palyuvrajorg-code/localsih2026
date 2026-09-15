import 'package:flutter/material.dart';
import '../../store.dart';
import '../../data/models/models.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/smriti_card.dart';

class RoleSelectScreen extends StatelessWidget {
  final AppStore store;
  final VoidCallback onRoleSelected;

  const RoleSelectScreen({super.key, required this.store, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Header logo & title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.spa_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMRITI',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Smart India Hackathon 2026',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '“An AI-powered, culturally adaptive, offline-first and closed-loop care companion for elderly people living with dementia.”',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'SELECT PROTOTYPE DEMO ROLE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 14),

              // Role 1: Elder
              _buildRoleCard(
                context,
                role: UserRole.elder,
                title: 'Elder: Kamala Devi',
                subtitle: 'Living with mild-moderate dementia. Simple, high-contrast, voice-friendly interface with large touch targets.',
                icon: Icons.elderly_rounded,
                color: AppColors.green,
                isSelected: store.currentRole == UserRole.elder,
              ),
              const SizedBox(height: 14),

              // Role 2: Caregiver
              _buildRoleCard(
                context,
                role: UserRole.caregiver,
                title: 'Caregiver: Ananya',
                subtitle: 'Granddaughter & primary caregiver. Needs Attention alerts, adherence tracking, telemetry, and shared activities.',
                icon: Icons.favorite_rounded,
                color: AppColors.terracotta,
                isSelected: store.currentRole == UserRole.caregiver,
              ),
              const SizedBox(height: 14),

              // Role 3: Doctor
              _buildRoleCard(
                context,
                role: UserRole.doctor,
                title: 'Doctor: Dr. R. Sharma',
                subtitle: 'Geriatric Neurologist. Clinical cognitive insights, longitudinal trends, and telehealth video consultation.',
                icon: Icons.medical_services_rounded,
                color: const Color(0xFF2B6CB0),
                isSelected: store.currentRole == UserRole.doctor,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 3,
                  ),
                  onPressed: onRoleSelected,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 24),
                  label: const Text(
                    'Enter SMRITI Prototype',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return SmritiCard(
      backgroundColor: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
      border: Border.all(
        color: isSelected ? color : AppColors.line,
        width: isSelected ? 2.5 : 1.5,
      ),
      onTap: () {
        store.switchRole(role);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? color : AppColors.ink,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: color, size: 22),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
