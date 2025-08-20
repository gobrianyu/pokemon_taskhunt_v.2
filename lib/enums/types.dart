import 'package:flutter/material.dart';

enum Types { 
  water('Water'),
  grass('Grass'),
  fire('Fire'), 
  normal('Normal'), 
  ground('Ground'), 
  rock('Rock'),
  flying('Flying'), 
  psychic('Psychic'), 
  poison('Poison'), 
  fairy('Fairy'), 
  steel('Steel'), 
  bug('Bug'), 
  dragon('Dragon'), 
  dark('Dark'), 
  fighting('Fighting'), 
  electric('Electric'), 
  ice('Ice'), 
  ghost('Ghost');

  const Types(this.type);
  final String type;
  
  List<Types> get weaknesses {
    switch(type.toLowerCase()) {
      case 'water': return [grass, electric];
      case 'grass': return [fire, ice, poison, flying, bug];
      case 'fire': return [water, ground, rock];
      case 'normal': return [fighting];
      case 'ground': return [water, grass, ice];
      case 'rock': return [ground, water, grass, fighting, steel];
      case 'flying': return [rock, electric, ice];
      case 'psychic': return [bug, ghost, dark];
      case 'poison': return [ground, psychic];
      case 'fairy': return [steel, poison];
      case 'steel': return [fire, ground, fighting];
      case 'bug': return [fire, rock, flying];
      case 'dragon': return [fairy, dragon, ice];
      case 'dark': return [fighting, fairy, bug];
      case 'fighting': return [psychic, fairy, flying];
      case 'electric': return [ground];
      case 'ice': return [fire, fighting, rock, steel];
      case 'ghost': return [ghost, dark];
    }
    throw Exception('Invalid type');
  }

  List<Types> get resistances {
    switch(type.toLowerCase()) {
      case 'water': return [fire, water, ice, steel];
      case 'grass': return [water, grass, electric, ground];
      case 'fire': return [fire, grass, ice, bug, steel, fairy];
      case 'normal': return [];
      case 'ground': return [poison, rock];
      case 'rock': return [normal, fire, poison, flying];
      case 'flying': return [grass, fighting, bug];
      case 'psychic': return [fighting, psychic];
      case 'poison': return [grass, fighting, poison, bug, fairy];
      case 'fairy': return [fighting, bug, dark];
      case 'steel': return [normal, grass, ice, flying, psychic, bug, rock, dragon, steel, fairy];
      case 'bug': return [grass, fighting, ground];
      case 'dragon': return [fire, water, grass, electric];
      case 'dark': return [ghost, dark];
      case 'fighting': return [bug, rock, dark];
      case 'electric': return [electric, steel];
      case 'ice': return [ice];
      case 'ghost': return [poison, bug];
    }
    throw Exception('Invalid type');
  }

  List<Types> get immunities {
    switch(type.toLowerCase()) {
      case 'normal': return [ghost];
      case 'ground': return [electric];
      case 'flying': return [ground];
      case 'ghost': return [normal, fighting];
      case 'dark': return [psychic];
      case 'steel': return [poison];
      case 'fairy': return [dragon];
      default: return [];
    }
  }

  Color get colour {
    switch(type.toLowerCase()) {
      case 'water': return const Color(0xFF437EE7);
      case 'grass': return const Color(0xFF5B9F3D);
      case 'fire': return const Color(0xFFD33D34);
      case 'normal': return const Color(0xFF9FA19F);
      case 'ground': return const Color(0xFF88542B);
      case 'rock': return const Color(0xFFAEA985);
      case 'flying': return const Color(0xFF8DB8EA);
      case 'psychic': return const Color(0xFFDC5079);
      case 'poison': return const Color(0xFF8746C4);
      case 'fairy': return const Color(0xFFDF77E9);
      case 'steel': return const Color(0xFF6F9FB5);
      case 'bug': return const Color(0xFF94A138);
      case 'dragon': return const Color(0xFF5360D9);
      case 'dark': return const Color(0xFF4E423F);
      case 'fighting': return const Color(0xFFEF8732);
      case 'electric': return const Color(0xFFF1C241);
      case 'ice': return const Color(0xFF70D5FB);
      case 'ghost': return const Color(0xFF69436D);
    }
    throw Exception('Invalid type');
  }

  String get iconAsset {
    switch(type.toLowerCase()) {
      case 'water': return 'assets/type-icons/water_icon.png';
      case 'grass': return 'assets/type-icons/grass_icon.png';
      case 'fire': return 'assets/type-icons/fire_icon.png';
      case 'normal': return 'assets/type-icons/normal_icon.png';
      case 'ground': return 'assets/type-icons/ground_icon.png';
      case 'rock': return 'assets/type-icons/rock_icon.png';
      case 'flying': return 'assets/type-icons/flying_icon.png';
      case 'psychic': return 'assets/type-icons/psychic_icon.png';
      case 'poison': return 'assets/type-icons/poison_icon.png';
      case 'fairy': return 'assets/type-icons/fairy_icon.png';
      case 'steel': return 'assets/type-icons/steel_icon.png';
      case 'bug': return 'assets/type-icons/bug_icon.png';
      case 'dragon': return 'assets/type-icons/dragon_icon.png';
      case 'dark': return 'assets/type-icons/dark_icon.png';
      case 'fighting': return 'assets/type-icons/fighting_icon.png';
      case 'electric': return 'assets/type-icons/electric_icon.png';
      case 'ice': return 'assets/type-icons/ice_icon.png';
      case 'ghost': return 'assets/type-icons/ghost_icon.png';
    }
    throw Exception('Invalid type');
  }

  static Types tryFromString(String value) {
    return Types.values.firstWhere(
      (e) => e.type.toLowerCase() == value.toLowerCase()
    );
  }
}