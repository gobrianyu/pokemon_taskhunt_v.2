enum Items { 
  // balls (key below 5)
  pokeBall(1, 'Poké Ball', 'A device for catching wild Pokémon. It\'s thrown like a ball at a Pokémon, comfortably encapsulating its target.', 50, 25, 100, false, {}),
  greatBall(2, 'Great Ball', 'A good, high-performance Poké Ball that provides a higher success rate for catching Pokémon than a standard Poké Ball.', 100, 50, 200, false, {}),
  ultraBall(3, 'Ultra Ball', 'An ultra-high-performance Poké Ball that provides a higher success rate for catching Pokémon than a Great Ball.', 200, 100, 500, false, {}),
  masterBall(4, 'Master Ball', 'The very best Poké Ball with the ultimate level of performance. With it, you will catch any wild Pokémon without fail.', 5000, 500, 10000, false, {}),
  // booster items
  luckyEgg(10.1, 'Lucky Egg', 'An item to be held by a Pokémon. It\'s an egg filled with happiness that earns extra Exp. Points.', 75, 20, 100, true, {}),
  amuletCoin(10.2, 'Amulet Coin', 'An item to be held by a Pokémon. It doubles any prize money received.', 75, 20, 100, true, {}),
  shinyCharm(10.3, 'Shiny Charm', 'A shiny charm said to increase the chance of finding a Shiny Pokémon in the wild.', 10000, 0, 20000, true, {}),
  
  // evo items
  fireStone(10.8, 'Fire Stone', 'A peculiar stone that can make certain species of Pokémon evolve. It has a fiery orange heart.', 0, 400, 700, false, {}),
  waterStone(10.89, 'Water Stone', 'A peculiar stone that can make certain species of Pokémon evolve. It is the clear blue of a deep pool.', 0, 400, 700, false, {}),
  thunderStone(10.9, 'Thunder Stone', 'A peculiar stone that can make certain species of Pokémon evolve. It has a distinct thunderbolt pattern.', 0, 400, 700, false, {}),
  leafStone(11, 'Leaf Stone', 'A peculiar stone that can make certain species of Pokémon evolve. It has an unmistakable leaf pattern.', 0, 400, 700, false, {}),
  moonStone(12, 'Moon Stone', 'A peculiar stone that can make certain species of Pokémon evolve. It is dark like the night sky.', 0, 400, 700, false, {}),
  sunStone(13, 'Sun Stone', 'A peculiar stone that can make certain species of Pokémon evolve. It burns as red as the evening sun.', 0, 400, 700, false, {}),
  shinyStone(14, 'Shiny Stone', 'A peculiar stone that can make certain species of Pokémon evolve. It shines with a dazzling light.', 0, 400, 700, false, {}),
  duskStone(15, 'Dusk Stone', '	A peculiar stone that can make certain species of Pokémon evolve. It holds dark shadows within it.', 0, 400, 700, false, {}),
  dawnStone(16, 'Dawn Stone', 'A peculiar stone that can make certain species of Pokémon evolve. It sparkles like a glittering eye.', 0, 400, 700, false, {}),
  iceStone(17, 'Ice Stone', 'A peculiar stone that can make certain species of Pokémon evolve. It has a snowflake pattern in it.', 0, 400, 700, false, {}),
  auspiciousArmour(18, 'Auspicious Armour', 'A peculiar set of armor that can make a certain species of Pokémon evolve. Auspicious wishes live within it.', 0, 750, 2500, false, {}),
  blackAugurite(19, 'Black Augurite', 'A glassy black stone that produces a sharp cutting edge when split. It\'s loved by a certain Pokémon.', 0, 750, 2500, false, {}),
  chippedPot(20, 'Chipped Pot', 'A peculiar teapot that can make a certain species of Pokémon evolve. It may be chipped, but tea poured from it is delicious.', 0, 500, 3000, false, {}),
  crackedPot(21, 'Cracked Pot', 'A peculiar teapot that can make a certain species of Pokémon evolve. It may be cracked, but tea poured from it is delicious.', 0, 50, 300, false, {}),
  galaricaCuff(22, 'Galarica Cuff', 'A cuff made from woven-together Galarica Twigs. Giving it to Galarian Slowpoke makes the Pokémon very happy.', 0, 300, 1000, false, {}),
  galaricaWreath(22.5, 'Galarica Wreath', 'A wreath made from woven-together Galarica Twigs. Placing it on the head of a Galarian Slowpoke makes the Pokémon very happy.', 0, 300, 1000, false, {}),
  maliciousArmour(23, 'Malicious Armour', 'A peculiar set of armor that can make a certain species of Pokémon evolve. Malicious will lurks within it.', 0, 750, 2500, false, {}),
  masterpieceTeacup(24, 'Masterpiece Teacup', '	A peculiar teacup that can make a certain species of Pokémon evolve. It may be chipped, but tea drunk from it is delicious.', 0, 500, 3000, false, {}),
  unremarkableTeacup(24.5, 'Unremarkable Teacup', 'A peculiar teacup that can make a certain species of Pokémon evolve. It may be cracked, but tea drunk from it is delicious.', 0, 50, 300, false, {}),
  metalAlloy(25, 'Metal Alloy', 'A peculiar metal that can make certain species of Pokémon evolve. It is composed of many layers.', 0, 0, 0, false, {}),
  peatBlock(26, 'Peat Block', 'A block of muddy material that can be used as fuel for burning when it is dried. It\'s loved by a certain Pokémon.', 0, 0, 0, false, {}),
  scrollOfDarkness(27, 'Scroll of Darkness', 'A peculiar scroll that can make a certain species of Pokémon evolve. Written upon it are the true secrets of the path of darkness.', 0, 0, 0, false, {}),
  scrollOfWaters(28, 'Scroll of Waters', '	A peculiar scroll that can make a certain species of Pokémon evolve. Written upon it are the true secrets of the path of water.', 0, 0, 0, false, {}),
  sweetApple(29, 'Sweet Apple', 'A peculiar apple that can make a certain species of Pokémon evolve. It\'s exceptionally sweet.', 0, 0, 0, false, {}),
  syrupyApple(30, 'Syrupy Apple', 'A peculiar apple that can make a certain species of Pokémon evolve. It\'s exceptionally syrupy.', 0, 0, 0, false, {}),
  tartApple(31, 'Tart Apple', 'A peculiar apple that can make a certain species of Pokémon evolve. It\'s exceptionally tart.', 0, 0, 0, false, {}),
  deepSeaScale(32, 'Deep Sea Scale', 'An item to be held by Clamperl. This scale shines with a faint pink and boosts Clamperl\'s Sp. Def stat.', 0, 0, 0, true, {}),
  deepSeaTooth(33, 'Deep Sea Tooth', 'An item to be held by Clamperl. This fang gleams a sharp silver and boosts Clamperl\'s Sp. Atk stat.', 0, 0, 0, true, {}),
  dragonScale(34, 'Dragon Scale', 'A very tough and inflexible scale. Dragon-type Pokémon may be holding this item when caught.', 0, 0, 0, true, {}),
  dubiousDisc(35, 'Dubious Disc', 'A transparent device overflowing with dubious data. It\'s loved by a certain Pokémon.', 0, 0, 0, true, {}),
  electirizer(36, 'Electirizer', 'A box packed with a tremendous amount of electric energy. It\'s loved by a certain Pokémon.', 0, 0, 0, true, {}),
  kingsRock(37, 'King\'s Rock', 'An item to be held by a Pokémon. It may cause the target to flinch whenever the holder successfully inflicts damage on them with an attack.', 0, 0, 0, true, {}),
  magmarizer(38, 'Magmarizer', 'A box packed with a tremendous amount of magma energy. It\'s loved by a certain Pokémon.', 0, 0, 0, true, {}),
  metalCoat(39, 'Metal Coat', 'An item to be held by a Pokémon. It\'s a special metallic coating that boosts the power of the holder\'s Steel-type moves.', 0, 0, 0, true, {}),
  ovalStone(40, 'Oval Stone', 'A peculiar stone that can make a certain species of Pokémon evolve. It is round and smooth.', 0, 0, 0, true, {}),
  prismScale(41, 'Prism Scale', 'A mysterious scale that causes a certain Pokémon to evolve. It shines in rainbow colors.', 0, 0, 0, true, {}),
  protector(42, 'Protector', '	A protective item of some sort. It is extremely stiff and heavy. It\'s loved by a certain Pokémon.', 0, 0, 0, true, {}),
  razorClaw(43, 'Razor Claw', 'An item to be held by a Pokémon. This sharply hooked claw boosts the critical-hit ratio of the holde\'s moves.', 0, 0, 0, true, {}),
  razorFang(44, 'Razor Fang', 'An item to be held by a Pokémon. When the holder successfully inflicts damage, the target may also flinch.', 0, 0, 0, true, {}),
  reaperCloth(45, 'Reaper Cloth', 'A cloth imbued with horrifyingly strong spiritual energy. It\'s loved by a certain Pokémon.', 0, 0, 0, true, {}),
  sachet(46, 'Sachet', 'A sachet filled with fragrant perfumes that are just slightly overwhelming. Yet it\'s loved by a certain Pokémon.', 0, 0, 0, true, {}),
  upgrade(47, 'Upgrade', 'A transparent device somehow filled with all sorts of data. It was produced by Silph Co.', 0, 0, 0, true, {}),
  whippedDream(48, 'Whipped Dream', 'A soft and sweet treat made of fluffy, puffy, whipped, and whirled cream. It\'s loved by a certain Pokémon.', 0, 0, 0, true, {}),
  strawberrySweet(49, 'Strawberry Sweet', 'A strawberry-shaped sweet. When a Milcery holds this, it spins around happily.', 0, 0, 0, true, {}),
  loveSweet(50, 'Love Sweet', 'A heart-shaped sweet. When a Milcery holds this, it spins around happily.', 0, 0, 0, true, {}),
  berrySweet(51, 'Berry Sweet', 'A berry-shaped sweet. When a Milcery holds this, it spins around happily.', 0, 0, 0, true, {}),
  cloverSweet(52, 'Clover Sweet', 'A clover-shaped sweet. When a Milcery holds this, it spins around happily.', 0, 0, 0, true, {}),
  flowerSweet(53, 'Flower Sweet', 'A flower-shaped sweet. When a Milcery holds this, it spins around happily.', 0, 0, 0, true, {}),
  starSweet(54, 'Star Sweet', 'A star-shaped sweet. When a Milcery holds this, it spins around happily.', 0, 0, 0, true, {}),
  ribbonSweet(55, 'Ribbon Sweet', 'A ribbon-shaped sweet. When a Milcery holds this, it spins around happily.', 0, 0, 0, true, {}),
  // berries 5 < key <= 10
  goldenPinapBerry(10, 'Golden Pinap Berry', 'A Berry that makes you drastically more likely to get an item when given to Pokémon you\'re trying to catch.', 350, 100, 400, false, {}),
  goldenRazzBerry(9, 'Golden Razz Berry', 'A Berry that makes it drastically easier to catch Pokémon when given to them.', 350, 100, 400, false, {}),
  silverPinapBerry(8, 'Silver Pinap Berry', 'A Berry that makes you more likely to get an item when given to Pokémon you\'re trying to catch.', 110, 50, 120, false, {}),
  silverRazzBerry(7, 'Silver Razz Berry', 'A Berry that makes it easier to catch Pokémon when given to them.', 110, 50, 120, false, {}),
  pinapBerry(6, 'Pinap Berry', 'A Berry that makes you slightly more likely to get an item when given to Pokémon you\'re trying to catch.', 30, 10, 35, false, {}),
  razzBerry(5, 'Razz Berry', 'A Berry that makes it slightly easier to catch Pokémon when given to them.', 30, 10, 35, false, {}),
  // eggs
  egg(62, 'Mystery Egg', 'An odd Pokémon egg. What will hatch from this?', 500, 0, 750, false, {}),

  // lures
  lure(1000, 'Lure', 'A glass bottle of perfume that can be configured to make certain type Pokémon slightly more likely to appear.', 300, 0, 350, false, {}),
        lureNormal(1000, 'Lure (Normal)', 'A preconfigured glass bottle of perfume that makes Normal-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureFire(1000, 'Lure (Fire)', 'A preconfigured glass bottle of perfume that makes Fire-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureWater(1000, 'Lure (Water)', 'A preconfigured glass bottle of perfume that makes Water-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureElectric(1000, 'Lure (Electric)', 'A preconfigured glass bottle of perfume that makes Electric-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureGrass(1000, 'Lure (Grass)', 'A preconfigured glass bottle of perfume that makes Grass-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureIce(1000, 'Lure (Ice)', 'A preconfigured glass bottle of perfume that makes Ice-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureFighting(1000, 'Lure (Fighting)', 'A preconfigured glass bottle of perfume that makes Fighting-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lurePoison(1000, 'Lure (Poison)', 'A preconfigured glass bottle of perfume that makes Poison-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureGround(1000, 'Lure (Ground)', 'A preconfigured glass bottle of perfume that makes Ground-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureFlying(1000, 'Lure (Flying)', 'A preconfigured glass bottle of perfume that makes Flying-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lurePsychic(1000, 'Lure (Psychic)', 'A preconfigured glass bottle of perfume that makes Psychic-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureBug(1000, 'Lure (Bug)', 'A preconfigured glass bottle of perfume that makes Bug-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureRock(1000, 'Lure (Rock)', 'A preconfigured glass bottle of perfume that makes Rock-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureGhost(1000, 'Lure (Ghost)', 'A preconfigured glass bottle of perfume that makes Ghost-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureDragon(1000, 'Lure (Dragon)', 'A preconfigured glass bottle of perfume that makes Dragon-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureDark(1000, 'Lure (Dark)', 'A preconfigured glass bottle of perfume that makes Dark-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureSteel(1000, 'Lure (Steel)', 'A preconfigured glass bottle of perfume that makes Steel-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),
        lureFairy(1000, 'Lure (Fairy)', 'A preconfigured glass bottle of perfume that makes Fairy-type Pokémon slightly more likely to appear.', 0, 0, 200, false, {}),

  superLure(1000, 'Super Lure', 'A glass bottle of perfume that can be configured to make certain type Pokémon more likely to appear.', 500, 0, 600, false, {}),
        superLureNormal(1000, 'Super Lure (Normal)', 'A preconfigured glass bottle of perfume that makes Normal-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureFire(1000, 'Super Lure (Fire)', 'A preconfigured glass bottle of perfume that makes Fire-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureWater(1000, 'Super Lure (Water)', 'A preconfigured glass bottle of perfume that makes Water-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureElectric(1000, 'Super Lure (Electric)', 'A preconfigured glass bottle of perfume that makes Electric-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureGrass(1000, 'Super Lure (Grass)', 'A preconfigured glass bottle of perfume that makes Grass-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureIce(1000, 'Super Lure (Ice)', 'A preconfigured glass bottle of perfume that makes Ice-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureFighting(1000, 'Super Lure (Fighting)', 'A preconfigured glass bottle of perfume that makes Fighting-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLurePoison(1000, 'Super Lure (Poison)', 'A preconfigured glass bottle of perfume that makes Poison-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureGround(1000, 'Super Lure (Ground)', 'A preconfigured glass bottle of perfume that makes Ground-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureFlying(1000, 'Super Lure (Flying)', 'A preconfigured glass bottle of perfume that makes Flying-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLurePsychic(1000, 'Super Lure (Psychic)', 'A preconfigured glass bottle of perfume that makes Psychic-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureBug(1000, 'Super Lure (Bug)', 'A preconfigured glass bottle of perfume that makes Bug-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureRock(1000, 'Super Lure (Rock)', 'A preconfigured glass bottle of perfume that makes Rock-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureGhost(1000, 'Super Lure (Ghost)', 'A preconfigured glass bottle of perfume that makes Ghost-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureDragon(1000, 'Super Lure (Dragon)', 'A preconfigured glass bottle of perfume that makes Dragon-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureDark(1000, 'Super Lure (Dark)', 'A preconfigured glass bottle of perfume that makes Dark-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureSteel(1000, 'Super Lure (Steel)', 'A preconfigured glass bottle of perfume that makes Steel-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
        superLureFairy(1000, 'Super Lure (Fairy)', 'A preconfigured glass bottle of perfume that makes Fairy-type Pokémon more likely to appear.', 0, 0, 450, false, {}),
  
  maxLure(1000, 'Max Lure', 'A glass bottle of perfume that can be configured to make certain type Pokémon drastically more likely to appear.', 1000, 0, 1200, false, {}), //TODO: reset keys
        maxLureNormal(1000, 'Max Lure (Normal)', 'A preconfigured glass bottle of perfume that makes Normal-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureFire(1000, 'Max Lure (Fire)', 'A preconfigured glass bottle of perfume that makes Fire-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureWater(1000, 'Max Lure (Water)', 'A preconfigured glass bottle of perfume that makes Water-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureElectric(1000, 'Max Lure (Electric)', 'A preconfigured glass bottle of perfume that makes Electric-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureGrass(1000, 'Max Lure (Grass)', 'A preconfigured glass bottle of perfume that makes Grass-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureIce(1000, 'Max Lure (Ice)', 'A preconfigured glass bottle of perfume that makes Ice-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureFighting(1000, 'Max Lure (Fighting)', 'A preconfigured glass bottle of perfume that makes Fighting-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLurePoison(1000, 'Max Lure (Poison)', 'A preconfigured glass bottle of perfume that makes Poison-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureGround(1000, 'Max Lure (Ground)', 'A preconfigured glass bottle of perfume that makes Ground-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureFlying(1000, 'Max Lure (Flying)', 'A preconfigured glass bottle of perfume that makes Flying-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLurePsychic(1000, 'Max Lure (Psychic)', 'A preconfigured glass bottle of perfume that makes Psychic-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureBug(1000, 'Max Lure (Bug)', 'A preconfigured glass bottle of perfume that makes Bug-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureRock(1000, 'Max Lure (Rock)', 'A preconfigured glass bottle of perfume that makes Rock-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureGhost(1000, 'Max Lure (Ghost)', 'A preconfigured glass bottle of perfume that makes Ghost-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureDragon(1000, 'Max Lure (Dragon)', 'A preconfigured glass bottle of perfume that makes  Dragon-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureDark(1000, 'Max Lure (Dark)', 'A preconfigured glass bottle of perfume that makes Dark-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureSteel(1000, 'Max Lure (Steel)', 'A preconfigured glass bottle of perfume that makes Steel-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
        maxLureFairy(1000, 'Max Lure (Fairy)', 'A preconfigured glass bottle of perfume that makes Fairy-type Pokémon drastically more likely to appear.', 0, 0, 825, false, {}),
  
  // held items

  // type boosts
  blackBelt(20.01, 'Black Belt', '', 0, 0, 0, true, {'Fighting-type boost': 20}),
  blackGlasses(20.02, 'Black Glasses', '', 0, 0, 0, true, {'Dark-type boost': 20}),
  charcoal(20.03, 'Charcoal', '', 0, 0, 0, true, {'Fire-type boost': 20}),
  dragonFang(20.04, 'Dragon Fang', '', 0, 0, 0, true, {'Dragon-type boost': 20}),
  fairyFeather(20.05, 'Fairy Feather', '', 0, 0, 0, true, {'Fairy-type boost': 20}),
  hardStone(20.06, 'Hard Stone', '', 0, 0, 0, true, {'Rock-type boost': 20}),
  magnet(20.07, 'Magnet', '', 0, 0, 0, true, {'Electric-type boost': 20}),
  // metal coat
  miracleSeed(20.09, 'Miracle Seed', '', 0, 0, 0, true, {'Grass-type boost': 20}),
  mysticWater(20.10, 'Mystic Water', '', 0, 0, 0, true, {'Water-type boost': 20}),
  neverMeltIce(20.11, 'Never-Melt Ice', '', 0, 0, 0, true, {'Ice-type boost': 20}),
  poisonBarb(20.12, 'Poison Barb', '', 0, 0, 0, true, {'Poison-type boost': 20}),
  sharpBeak(20.13, 'Sharp Beak', '', 0, 0, 0, true, {'Flying-type boost': 20}),
  silkScarf(20.14, 'Silk Scarf', '', 0, 0, 0, true, {'Normal-type boost': 20}),
  silverPowder(20.15, 'Silver Powder', '', 0, 0, 0, true, {'Bug-type boost': 20}),
  softSand(20.16, 'Soft Sand', '', 0, 0, 0, true, {'Ground-type boost': 20}),
  spellTag(20.17, 'Spell Tag', '', 0, 0, 0, true, {'Ghost-type boost': 20}),
  twistedSpoon(20.18, 'Twisted Spoon', '', 0, 0, 0, true, {'Psychic-type boost': 20}),

  // anti-type boosts
  // cellBattery(20.01, 'Black Glasses', '', 0, 0, 0, true, {}),
  // chartiBerry(20.01, 'Black Glasses', '', 0, 0, 0, true, {}),
  // chilanBerry(20.01, 'Black Glasses', '', 0, 0, 0, true, {}),
  // chopleBerry(20.01, 'Black Glasses', '', 0, 0, 0, true, {}),
  
  // gems ?
  // bugGem(20.25, 'Bug Gem', '', 0, 0, 0, true),
  // darkGem(20.26, 'Dark Gem', '', 0, 0, 0, true),
  // dragonGem(20.27, 'Dragon Gem', '', 0, 0, 0, true),
  // electricGem(20.28, 'Electric Gem', '', 0, 0, 0, true),
  // fairyGem(20.29, 'FairyGem', '', 0, 0, 0, true),
  // fightingGem(20.30, 'Fighting Gem', '', 0, 0, 0, true),
  // fireGem(20.31, 'Fire Gem', '', 0, 0, 0, true),
  // flyingGem(20.32, 'Flying Gem', '', 0, 0, 0, true),
  // ghostGem(20.33, 'Ghost Gem', '', 0, 0, 0, true),
  // grassGem(20.34, 'Grass Gem', '', 0, 0, 0, true),
  // groundGem(20.35, 'Ground Gem', '', 0, 0, 0, true),
  // iceGem(20.36, 'Ice Gem', '', 0, 0, 0, true),
  // normalGem(20.37, 'Normal Gem', '', 0, 0, 0, true),
  // poisonGem(20.38, 'Poison Gem', '', 0, 0, 0, true),
  // psychicGem(20.39, 'Psychic Gem', '', 0, 0, 0, true),
  // rockGem(20.40, 'Rock Gem', '', 0, 0, 0, true),
  // steelGem(20.41, 'Steel Gem', '', 0, 0, 0, true),
  // waterGem(20.42, 'Water Gem', '', 0, 0, 0, true),
  ;
  
  const Items(this.key, this.name, this.description, this._cost, this._sellCost, this._blackCost, this.holdable, this.effects);
  final num key;
  final String name;
  final String description;
  final int _cost; // cost = 0 means ineligible
  final int _sellCost;
  final int _blackCost;
  final bool holdable;
  final Map<String, int> effects;

  int get blackMarketCost {
    return _blackCost;
  }

  int get sellCost {
    return _sellCost;
  }

  int get cost {
    return _cost;
  }
}