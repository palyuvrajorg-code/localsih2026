import 'package:flutter/material.dart';

class CulturalSymbol {
  final String id;
  final String name;
  final String region;
  final String description;
  final IconData icon;
  final Color accentColor;

  const CulturalSymbol({
    required this.id,
    required this.name,
    required this.region,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class CulturalMotifs {
  static const List<CulturalSymbol> matchSymbols = [
    CulturalSymbol(
      id: 'japi',
      name: 'Assamese Japi',
      region: 'Assam',
      description: 'Traditional woven conical hat made of cane and bamboo.',
      icon: Icons.wb_sunny_outlined,
      accentColor: Color(0xFFC05621),
    ),
    CulturalSymbol(
      id: 'mandala',
      name: 'Sikkimese Mandala',
      region: 'Sikkim',
      description: 'Sacred geometric artwork representing the cosmos.',
      icon: Icons.all_inclusive,
      accentColor: Color(0xFF805AD5),
    ),
    CulturalSymbol(
      id: 'longpi',
      name: 'Manipuri Longpi Pot',
      region: 'Manipur',
      description: 'Black serpent stone pottery handcrafted without a potter wheel.',
      icon: Icons.coffee_maker_outlined,
      accentColor: Color(0xFF2D3748),
    ),
    CulturalSymbol(
      id: 'naga_shield',
      name: 'Naga Shield',
      region: 'Nagaland',
      description: 'Traditional ceremonial wooden shield with dyed cane hair.',
      icon: Icons.shield_outlined,
      accentColor: Color(0xFF9B2C2C),
    ),
    CulturalSymbol(
      id: 'mizo_puan',
      name: 'Mizo Puan',
      region: 'Mizoram',
      description: 'Intricately handwoven textile with bold striped geometries.',
      icon: Icons.grid_view_rounded,
      accentColor: Color(0xFF2B6CB0),
    ),
    CulturalSymbol(
      id: 'garo_drum',
      name: 'Garo Drum (Dama)',
      region: 'Meghalaya',
      description: 'Long wooden drum played during the Wangala harvest festival.',
      icon: Icons.speaker_group_outlined,
      accentColor: Color(0xFF744210),
    ),
    CulturalSymbol(
      id: 'hornbill',
      name: 'Great Hornbill',
      region: 'Arunachal Pradesh',
      description: 'Majestic forest bird celebrated in folklore and festivals.',
      icon: Icons.cruelty_free_outlined,
      accentColor: Color(0xFFDD6B20),
    ),
    CulturalSymbol(
      id: 'rhino',
      name: 'One-Horned Rhinoceros',
      region: 'Kaziranga, Assam',
      description: 'Proud gentle giant thriving in the Brahmaputra grasslands.',
      icon: Icons.terrain_rounded,
      accentColor: Color(0xFF319795),
    ),
    CulturalSymbol(
      id: 'sangai',
      name: 'Sangai Deer',
      region: 'Loktak Lake, Manipur',
      description: 'The dancing deer residing upon the floating phumdis.',
      icon: Icons.pets_outlined,
      accentColor: Color(0xFFD69E2E),
    ),
    CulturalSymbol(
      id: 'monpa_mask',
      name: 'Monpa Mask',
      region: 'Tawang, Arunachal',
      description: 'Carved wooden mask worn during Cham Buddhist dances.',
      icon: Icons.theater_comedy_outlined,
      accentColor: Color(0xFFE53E3E),
    ),
  ];

  static const List<Map<String, dynamic>> instruments = [
    {
      'id': 'dhol',
      'name': 'Bihu Dhol',
      'region': 'Assam',
      'icon': Icons.album_outlined,
      'color': Color(0xFF884934),
      'noteFrequency': 220.0,
    },
    {
      'id': 'pepa',
      'name': 'Buffalo Horn Pepa',
      'region': 'Assam',
      'icon': Icons.audiotrack,
      'color': Color(0xFF315C49),
      'noteFrequency': 330.0,
    },
    {
      'id': 'gogona',
      'name': 'Bamboo Gogona',
      'region': 'Assam',
      'icon': Icons.graphic_eq,
      'color': Color(0xFFD4AF37),
      'noteFrequency': 440.0,
    },
    {
      'id': 'tokari',
      'name': 'Folk Tokari',
      'region': 'Northeast',
      'icon': Icons.music_note,
      'color': Color(0xFF2B6CB0),
      'noteFrequency': 550.0,
    },
  ];
}
