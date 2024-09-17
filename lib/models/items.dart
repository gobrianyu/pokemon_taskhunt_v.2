enum Items { 
  // balls
  pokeBall(1, "Poké Ball", 50),
  greatBall(2, "Great Ball", 100),
  ultraBall(3, "Ultra Ball", 200),
  masterBall(4, "Master Ball", 5000),
  // booster items
  luckyEgg(5, "Lucky Egg", 75),
  amuletCoin(6, "Amulet Coin", 75),
  shinyCharm(7, "Shiny Charm", 10000),
  
  // evo items
  fireStone(8, "Fire Stone", 700),
  waterStone(9, "Water Stone", 700),
  thunderStone(10, "Thunder Stone", 700),
  leafStone(11, "Leaf Stone", 700),
  moonStone(12, "Moon Stone", 700),
  sunStone(13, "Sun Stone", 700),
  shinyStone(14, "Shiny Stone", 700),
  duskStone(15, "Dusk Stone", 700),
  dawnStone(16, "Dawn Stone", 700),
  iceStone(17, "Ice Stone", 700),
  auspiciousArmor(18, "Auspicious Armour", 0),
  blackAugurite(19, "Black Augurite", 0),
  chippedPot(20, "Chipped Pot", 0),
  crackedPot(21, "Cracked Pot", 0),
  galaricaCuff(22, "Galarica Cuff", 0),
  galaricaWreath(22.5, "Galarica Wreath", 0),
  maliciousArmor(23, "Malicious Armour", 0),
  masterpieceTeacup(24, "Masterpiece Teacup", 100000),
  unremarkableTeacup(24.5, "Unremarkable Teacup", 0),
  metalAlloy(25, "Metal Alloy", 0),
  peatBlock(26, "Peat Block", 0),
  scrollOfDarkness(27, "Scroll of Darkness", 0),
  scrollOfWaters(28, "Scroll of Waters", 0),
  sweetApple(29, "Sweet Apple", 0),
  syrupyApple(30, "Syrupy Apple", 0),
  tartApple(31, "Tart Apple", 0),
  deepSeaScale(32, "Deep Sea Scale", 0),
  deepSeaTooth(33, "Deep Sea Tooth", 0),
  dragonScale(34, "Dragon Scale", 0),
  dubiousDisc(35, "Dubious Disc", 0),
  electirizer(36, "Electirizer", 0),
  kingsRock(37, "King's Rock", 0),
  magmarizer(38, "Magmarizer", 0),
  metalCoat(39, "Metal Coat", 0),
  ovalStone(40, "Oval Stone", 0),
  prismScale(41, "Prism Scale", 0),
  protector(42, "Protector", 0),
  razorClaw(43, "Razor Claw", 0),
  razorFang(44, "Razor Fang", 0),
  reaperCloth(45, "Reaper Cloth", 0),
  sachet(46, "Sachet", 0),
  upgrade(47, "Upgrade", 0),
  whippedDream(48, "Whipped Dream", 0),
  strawberrySweet(49, "Strawberry Sweet", 0),
  loveSweet(50, "Love Sweet", 0),
  berrySweet(51, "Berry Sweet", 0),
  cloverSweet(52, "Clover Sweet", 0),
  flowerSweet(53, "Flower Sweet", 0),
  starSweet(54, "Star Sweet", 0),
  ribbonSweet(55, "Ribbon Sweet", 0),
  // berries
  goldenPinapBerry(60, "Golden Pinap Berry", 350),
  goldenRazzBerry(61, "Golden Razz Berry", 350),
  silverPinapBerry(58, "Silver Pinap Berry", 110),
  silverRazzBerry(59, "Silver Razz Berry", 110),
  pinapBerry(56, "Pinap Berry", 30),
  razzBerry(57, "Razz Berry", 30),
  // eggs
  egg(62, "Mystery Egg", 0),
  // lures
  ;
  
  const Items(this.key, this.name, this._cost);
  final num key;
  final String name;
  final int _cost;

  int get cost {
    return _cost;
  }
}