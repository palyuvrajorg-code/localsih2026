import 'package:flutter/material.dart';

const ink = Color(0xFF233E36);
const green = Color(0xFF315C49);
const cream = Color(0xFFFAF8F2);
const muted = Color(0xFF59675F);
const sage = Color(0xFFE8EEDC);
const line = Color(0xFFDFE3D8);
const rust = Color(0xFF884934);

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: cream,
  colorScheme: ColorScheme.fromSeed(
    seedColor: green,
    primary: green,
    surface: cream,
    onSurface: ink,
  ),
  fontFamily: 'NotoSansBengali',
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 20, color: ink, height: 1.5),
    bodyLarge: TextStyle(fontSize: 20, color: ink, height: 1.5),
    titleLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    bodySmall: TextStyle(fontSize: 18, color: muted),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: cream,
    foregroundColor: ink,
    centerTitle: false,
    toolbarHeight: 76,
    scrolledUnderElevation: 0,
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(minimumSize: const Size(56, 56)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(56, 64),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(56, 64),
      foregroundColor: ink,
      side: const BorderSide(color: line),
      padding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: const TextStyle(fontSize: 20),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: const Size(56, 56),
      textStyle: const TextStyle(fontSize: 18),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: line),
    ),
  ),
);

class Panel extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  const Panel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(24),
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: line),
    ),
    child: child,
  );
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  final double width;
  const PageBody({super.key, required this.children, this.width = 620});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        children: children,
      ),
    ),
  );
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color color;
  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color = Colors.white,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: green, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(fontSize: 18, color: muted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    ),
  );
}

const gap = SizedBox(height: 20);
