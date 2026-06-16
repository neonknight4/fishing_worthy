const _fishIconMap = {
  'som': 'assets/icons/som.png',
  'smuđ': 'assets/icons/smudj.png',
  'šaran': 'assets/icons/saran.png',
  'štuka': 'assets/icons/stuka.png',
  'deverika': 'assets/icons/deverika.png',
  'babuška': 'assets/icons/babuska.png',
  'amur': 'assets/icons/amur.png',
  'bodorka': 'assets/icons/bodorka.png',
  'bucov': 'assets/icons/bucov.png',
  'plotica': 'assets/icons/plotica.png',
  'klen': 'assets/icons/klen.png',
  'mrena': 'assets/icons/mrena.png',
  'skobalj': 'assets/icons/skobalj.png',
  'šljivar': 'assets/icons/sljivar.png',
};

// Display names of all species we have icons for — used in pickers.
const iconFishNames = [
  'Som', 'Smuđ', 'Šaran', 'Štuka', 'Deverika', 'Babuška', 'Amur',
  'Bodorka', 'Bucov', 'Plotica', 'Klen', 'Mrena', 'Skobalj', 'Šljivar',
];

String? fishIconAsset(String name) {
  final lower = name.toLowerCase();
  for (final entry in _fishIconMap.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}
