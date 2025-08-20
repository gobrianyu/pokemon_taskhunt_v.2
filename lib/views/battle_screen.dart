import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/enums/stats.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/models/move.dart';
import 'package:pokemon_taskhunt_2/models/moves_db.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:pokemon_taskhunt_2/views/party_details.dart'; 
import 'package:provider/provider.dart';

final double SKEW = 75;

class BattleScreen extends StatefulWidget {
  final Pokemon mon;
  final Pokemon opponent;
  // TODO: add effects (?)
  const BattleScreen({required this.mon, required this.opponent, super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class ParallelogramShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height); // Start point
    path.lineTo(size.width, size.height - SKEW); // Top-right point
    path.lineTo(size.width, 0); // Bottom-right point
    path.lineTo(0, SKEW); // Bottom-left point
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // No need to reclip in this case
  }
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  late final AccountProvider accProvider;
  late final AnimationController _controller;
  late final Animation<double> _heightAnimation;
  final MovesDB movesDB = MovesDB();
  
  late final int oppMaxHP;
  late int oppCurrHP = oppMaxHP;
  late final int monMaxHP;
  late int monCurrHP = monMaxHP;
  late Stats battleStats;

  double? screenHeight;
  double? screenWidth;
  String battleText = '';

  bool battleEnd = false;

  @override
  void initState() {
    super.initState();
    accProvider = context.read<AccountProvider>();
    oppMaxHP = widget.opponent.calcStat(Stat.hp);
    monMaxHP = widget.mon.calcStat(Stat.hp);
    // Initialize the animation controller, but defer height initialization
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    battleText = 'What will ${widget.mon.nickname} do?';
    battleStats = widget.mon.getStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize screen height after context is fully available
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    // Set the initial height to a larger value, and animate to 150
    _heightAnimation = Tween<double>(begin: screenHeight, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCirc),
    );

    // Start the animation after dependencies change (safe to use MediaQuery now)
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          body: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  _opponentNameBar(),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image(image: AssetImage(widget.opponent.imageAsset), width: screenWidth! / 1.5),
                  ),
                  Spacer(),
                  _monBar(),
                ],
              ),
            ],
          )
        );
      }
    );
  }

  Widget _monBar() {
    Pokemon mon = widget.mon;
    const double windowHeight = 90;
    double widgetHeight = screenHeight! / 3.2;
    return Row(
      children: [
        Spacer(),
        Expanded(
          flex: 16,
          child: SizedBox(
            height: widgetHeight,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: EdgeInsets.only(top: windowHeight / 2.5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                  ),
                ),
                SizedBox(
                  height: widgetHeight,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, top: windowHeight / 2.5 + 15),
                              child: Text(
                                'Lv.${mon.level}',
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            )
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => PartyDetails(mon: mon),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5),
                              height: windowHeight,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all()
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Image(
                                  image: AssetImage(mon.imageAsset), 
                                  width: screenWidth! / 2
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: windowHeight / 2.5 + 15),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: Icon(Icons.directions_run_rounded, size: 20, color: Colors.white)
                                ),
                              ),
                            ) 
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mon.nickname.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500
                              )
                            ),
                            const SizedBox(width: 3),
                            mon.gender == -1 ? const SizedBox() : Icon(mon.gender == 0 ? Icons.male : Icons.female, color: Colors.white, size: 15),
                            if (mon.isShiny) const Padding(padding: EdgeInsets.only(left: 3), child: Icon(Icons.auto_awesome, color: Colors.yellow, size: 15)),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, right: 10, top: 15),
                              child: SizedBox(
                                height: widgetHeight - windowHeight - 45,
                                child: Column(
                                  children: [
                                    _healthBar(monMaxHP, monCurrHP, true),
                                    SizedBox(height: 20),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.topLeft,
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                          color: Colors.white
                                        ),
                                        child: Text(
                                          battleText
                                        )
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15, top: 15),
                              child: Container(
                                height: widgetHeight - windowHeight - 45,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: Colors.white), left: BorderSide(color: Colors.white), right: BorderSide(color: Colors.white)),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(22.5), topRight: Radius.circular(22.5))
                                ),
                                child: Column(
                                  children: [
                                    _attackButton(movesDB.getById(mon.move1Id)),
                                    SizedBox(height: 10),
                                    mon.move2Id == null ? _emptyAttackButton() : _attackButton(movesDB.getById(mon.move2Id!)),
                                  ]
                                ),
                              ),
                            )
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )
          ),
        ),
        Spacer()
      ],
    );
  }

  Widget _emptyAttackButton() {
    return Container(
      alignment: Alignment.center,
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(
        'EMPTY',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _attackButton(Move move) {
    return GestureDetector(
      onTap: () {
        _attack(move);
      },
      child: Container(
        alignment: Alignment.center,
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white,),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 3, left: 3),
              child: Image(image: AssetImage(move.type.iconAsset)),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.only(left: 5, right: 10, top: 8, bottom: 8),
                  child: Text(
                    move.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    )
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  void _attack(Move move) {
    
  }

  Widget _opponentNameBar() {
    Pokemon mon = widget.opponent;
    return Row(
      children: [
        Container(
          width: screenWidth! * 2 / 3,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.only(left: 15, right: 25, bottom: 15, top: 15),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(150), topRight: Radius.circular(30))
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    mon.species.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500
                    )
                  ),
                  const SizedBox(width: 3),
                  mon.gender == -1 ? const SizedBox() : Icon(mon.gender == 0 ? Icons.male : Icons.female, color: Colors.white, size: 15),
                  const SizedBox(width: 3),
                  if (mon.isShiny) const Icon(Icons.auto_awesome, color: Colors.yellow, size: 15),
                  const Spacer(),
                  Text(
                    'Lv.${mon.level}',
                    style: const TextStyle(
                      color: Colors.white,
                    )
                  ),
                ],
              ),
              SizedBox(height: 7),
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: _healthBar(oppMaxHP, oppCurrHP, false)
              ),
            ],
          )
        ),
        Spacer(),
      ],
    );
  }

  Widget _healthBar(int maxHP, int currHP, bool showHP) {
    return Row(
      children: [
        Text('HP:', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
        SizedBox(width: 5),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white)
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: currHP,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.black,), top: BorderSide(color: Colors.black,))
                      ),
                      height: 10
                    ),
                  ),
                  Expanded(
                    flex: maxHP - currHP,
                    child: const SizedBox(
                      height: 10
                    ),
                  )
                ],
              )
            ),
          ),
        ),
        showHP
            ? Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                '$currHP / $maxHP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold
                )
              )
            ) 
            : const SizedBox(),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _vsBar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        ClipPath(
          clipper: ParallelogramShape(),
          child: Container(
            width: screenWidth!,
            height: 150,
            color: Colors.black,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotated white horizontal line through the middle
                Transform.rotate(
                  angle: -tan(SKEW / screenWidth!), // 15 degrees skew
                  child: Container(
                    width: screenWidth!,
                    height: 7, // Height of the line
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    transform: Matrix4.skew(-0.2, 0),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5)
                  ),
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: Icon(Icons.catching_pokemon, color: Colors.white, size: 50),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _heightAnimation,
          builder: (context, child) {
            return Container(
              height: _heightAnimation.value,
              width: screenWidth!,
              color: Colors.black
            );
          },
        ),
      ],
    );
  }

  // Other methods (build(), etc.) remain unchanged.
}