enum Regions { 
  kanto('Kanto'),
  johto('Johto'),
  hoenn('Hoenn'),
  sinnoh('Sinnoh'),
  unova('Unova'),
  kalos('Kalos'),
  alola('Alola'),
  galar('Galar'),
  hisui('Hisui'),
  paldea('Paldea'),
  unknown('Unknown');

  const Regions(this.region);
  final String region;

  int get dexSize {
    switch (region.toLowerCase()) {
      case 'kanto': return 151;
      case 'johto': return 100;
      case 'hoenn': return 135;
      case 'sinnoh': return 107;
      case 'unova': return 156;
      case 'kalos': return 72;
      case 'alola': return 86;
      case 'galar': return 89;
      case 'hisui': return 7;
      case 'paldea': return 120;
      case 'unknown': return 2;
    }
    throw Exception('Invalid region');
  }
}