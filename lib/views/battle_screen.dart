import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/models/types.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
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

// class _BattleScreenState extends State<BattleScreen> {
//   late final AccountProvider accProvider;

//   @override
//   void initState() {
//     accProvider = context.read<AccountProvider>();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AccountProvider>(
//       builder: (context, accountProvider, _) {
//         return Scaffold(
//           extendBody: true,
//           backgroundColor: Colors.white,
//           body: Stack(
//             alignment: Alignment.center,
//             children: [
//               Column(
//                 children: [
//                   _opponentNameBar(),
//                   Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: Row(
//                       children: [
//                         Image(image: AssetImage(widget.opponent.imageAsset), width: MediaQuery.of(context).size.width / 2),
//                         Spacer(),
//                       ],
//                     ),
//                   ),
//                   Spacer(),
//                   Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: Row(
//                       children: [
//                         Spacer(),
//                         Image(image: AssetImage(widget.mon.imageAsset), width: MediaQuery.of(context).size.width / 2),
//                       ],
//                     ),
//                   ),
//                   _monNameBar(),
//                 ],
//               ),
//               _vsBar(),
//             ],
//           )
//         );
//       }
//     );
//   }

//   Widget _vsBar() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Container(
//           height: 110,
//           decoration: BoxDecoration(
//             color: Colors.black,
//             shape: BoxShape.circle,
//           ),
//         ),
//         ClipPath(
//           clipper: ParallelogramShape(),
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: 150,
//             color: Colors.black,
//             alignment: Alignment.center,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Rotated white horizontal line through the middle
//                 Transform.rotate(
//                   angle: -tan(SKEW / MediaQuery.of(context).size.width), // 15 degrees skew
//                   child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     height: 7, // Height of the line
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.white,
//                     ),
//                     transform: Matrix4.skew(-0.2, 0),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(5),
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 5)
//                   ),
//                   child: RotatedBox(
//                     quarterTurns: 2,
//                     child: Icon(Icons.catching_pokemon, color: Colors.white, size: 50),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _monNameBar() {
//     Pokemon mon = widget.mon;
//     return Row(
//       children: [
//         Spacer(),
//         Container(
//           width: MediaQuery.of(context).size.width * 2 / 3,
//           alignment: Alignment.centerRight,
//           margin: const EdgeInsets.only(bottom: 20),
//           padding: const EdgeInsets.only(left: 25, right: 15, bottom: 15, top: 15),
//           decoration: const BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.only(bottomLeft: Radius.circular(150), topLeft: Radius.circular(30))
//           ),
//           child: Row(
//             children: [
//               Text(
//                 mon.species.toUpperCase(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500
//                 )
//               ),
//               const SizedBox(width: 3),
//               mon.gender == -1 ? const SizedBox() : Icon(mon.gender == 0 ? Icons.male : Icons.female, color: Colors.white, size: 15),
//               const SizedBox(width: 3),
//               if (mon.isShiny) const Icon(Icons.auto_awesome, color: Colors.yellow, size: 15),
//               const Spacer(),
//               Text(
//                 'Lv.${mon.level}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                 )
//               ),
//             ],
//           )
//         ),
//       ],
//     );
//   }

//   Widget _opponentNameBar() {
//     Pokemon mon = widget.opponent;
//     return Row(
//       children: [
//         Container(
//           width: MediaQuery.of(context).size.width * 2 / 3,
//           alignment: Alignment.centerLeft,
//           margin: const EdgeInsets.only(top: 50),
//           padding: const EdgeInsets.only(left: 15, right: 25, bottom: 15, top: 15),
//           decoration: const BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.only(bottomRight: Radius.circular(150), topRight: Radius.circular(30))
//           ),
//           child: Row(
//             children: [
//               Text(
//                 mon.species.toUpperCase(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500
//                 )
//               ),
//               const SizedBox(width: 3),
//               mon.gender == -1 ? const SizedBox() : Icon(mon.gender == 0 ? Icons.male : Icons.female, color: Colors.white, size: 15),
//               const SizedBox(width: 3),
//               if (mon.isShiny) const Icon(Icons.auto_awesome, color: Colors.yellow, size: 15),
//               const Spacer(),
//               Text(
//                 'Lv.${mon.level}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                 )
//               ),
//             ],
//           )
//         ),
//         Spacer(),
//       ],
//     );
//   }
// }

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  late final AccountProvider accProvider;
  late final AnimationController _controller;
  late final Animation<double> _heightAnimation;

    double? screenHeight;

  @override
  void initState() {
    super.initState();
    accProvider = context.read<AccountProvider>();

    // Initialize the animation controller, but defer height initialization
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize screen height after context is fully available
    screenHeight = MediaQuery.of(context).size.height;

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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Image(image: AssetImage(widget.opponent.imageAsset), width: MediaQuery.of(context).size.width / 2),
                        Spacer(),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Spacer(),
                        Image(image: AssetImage(widget.mon.imageAsset), width: MediaQuery.of(context).size.width / 2),
                      ],
                    ),
                  ),
                  _monNameBar(),
                ],
              ),
              _vsBar(),
            ],
          )
        );
      }
    );
  }

  Widget _monNameBar() {
    Pokemon mon = widget.mon;
    return Row(
      children: [
        Spacer(),
        Container(
          width: MediaQuery.of(context).size.width * 2 / 3,
          alignment: Alignment.centerRight,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.only(left: 25, right: 15, bottom: 15, top: 15),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(150), topLeft: Radius.circular(30))
          ),
          child: Row(
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
          )
        ),
      ],
    );
  }

  Widget _opponentNameBar() {
    Pokemon mon = widget.opponent;
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 2 / 3,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.only(left: 15, right: 25, bottom: 15, top: 15),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(150), topRight: Radius.circular(30))
          ),
          child: Row(
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
          )
        ),
        Spacer(),
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
            width: MediaQuery.of(context).size.width,
            height: 150,
            color: Colors.black,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotated white horizontal line through the middle
                Transform.rotate(
                  angle: -tan(SKEW / MediaQuery.of(context).size.width), // 15 degrees skew
                  child: Container(
                    width: MediaQuery.of(context).size.width,
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
              width: MediaQuery.of(context).size.width,
              color: Colors.black
            );
          },
        ),
      ],
    );
  }

  // Other methods (build(), etc.) remain unchanged.
}