import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:pokemon_taskhunt_2/views/party_details.dart';
import 'package:provider/provider.dart';

class Party extends StatefulWidget {
  const Party({super.key});

  @override
  State<Party> createState() => _PartyState();
}

class _PartyState extends State<Party> {
  late AccountProvider accProvider;
  bool transferSwap = false;
  bool cancelSwap = false;

  @override
  void initState() {
    accProvider = context.read<AccountProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 35, bottom: 20),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: _partyTiles(),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _backButton(),
        );
      }
    );
  }

  Widget _partyTiles() {
    final List<Pokemon?> party = List.from(accProvider.blitzGame.party);
    int partyLength = party.length;
    for (int i = 0; i < 6 - partyLength; i++) {
      party.add(null);
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
        // color: const Color.fromARGB(20, 0, 0, 0)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(flex: 5, child: _partyTile(party[0])),
                Expanded(flex: 5, child: _partyTile(party[2])),
                Expanded(flex: 5, child: _partyTile(party[4])),
                const Expanded(child: SizedBox())
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Expanded(child: SizedBox()),
                Expanded(flex: 5, child: _partyTile(party[1])),
                Expanded(flex: 5, child: _partyTile(party[3])),
                Expanded(flex: 5, child: _partyTile(party[5])),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _partyTile(Pokemon? mon) {
    if (mon == null) {
      return _emptyTile();
    }
    final int lvlProgress = (mon.exp / mon.nextExpCap() * 512).round();
    return GestureDetector(
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
        padding: const EdgeInsets.all(5),
        margin: EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5), topRight: Radius.circular(5)),
          color: Colors.white
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle
                    ),
                    padding: const EdgeInsets.only(top: 5, bottom: 2),
                    child: Image(image: AssetImage(mon.imageAsset)),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(mon.nickname, style: TextStyle(color: Colors.black)),
                      mon.gender == -1 ? const SizedBox() : Icon(mon.gender == 0 ? Icons.male : Icons.female, size: 15, color: Colors.black),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    children: [
                      Text('Lv.${mon.level}', style: TextStyle(color: Colors.black)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black)
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: mon.level == 100 ? 1 : lvlProgress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border(bottom: BorderSide(color: Colors.black,), top: BorderSide(color: Colors.black,))
                                    ),
                                    height: 12
                                  ),
                                ),
                                Expanded(
                                  flex: mon.level == 100 ? 0 : 512 - min(lvlProgress, 512),
                                  child: const SizedBox(
                                    height: 12
                                  ),
                                )
                              ],
                            )
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ],
            ),
            Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.catching_pokemon, size: 30, color: Colors.black), // TODO: change to poke ball asset image
                      const Spacer(),
                      mon.isShiny? Icon(Icons.auto_awesome, size: 20, color: Colors.black) : const SizedBox(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (mon.heldItem != null) Container(
                        margin: const EdgeInsets.only(right: 5),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: Colors.white,
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.question_mark) // TODO: change to item asset
                      ),
                    ],
                  )
                ),
                const Expanded(
                  flex: 2,
                  child: SizedBox()
                )
              ],
            )
          ],
        )
      ),
    );
  }

  Widget _emptyTile() {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5), topRight: Radius.circular(5))
      )
    );
  }

// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:pokemon_taskhunt_2/models/pokemon.dart';
// import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
// import 'package:pokemon_taskhunt_2/views/party_details.dart';
// import 'package:provider/provider.dart';

// class Party extends StatefulWidget {
//   final List<Pokemon> party;
//   final bool isBlitz;
  
//   const Party({required this.party, required this.isBlitz, super.key});

//   @override
//   State<Party> createState() => _PartyState();
// }

// class _PartyState extends State<Party> {

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AccountProvider>(
//       builder: (context, accountProvider, _) {
//         return Scaffold(
//           extendBody: true,
//           backgroundColor: Colors.white,
//           body: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: GridView.count(
//                 physics: const NeverScrollableScrollPhysics(),
//                 childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height - 100) * 3 / 2,
//                 mainAxisSpacing: 8,
//                 crossAxisSpacing: 8,
//                 shrinkWrap: true,
//                 primary: false,
//                 crossAxisCount: 2,
//                 children: _partyTiles()
//               ),
//             ),
//           ),
//           bottomNavigationBar: _backButton()
//         );
//       }
//     );
//   }

//   List<Widget> _partyTiles() {
//     List<Widget> tiles = [];
//     for (Pokemon mon in widget.party) {
//       tiles.add(_partyTile(mon));
//     }
//     for (int i = 0; i < 6 - widget.party.length; i++) {
//       tiles.add(_emptyTile());
//     }
//     return tiles;
//   }

//   Widget _partyTile(Pokemon mon) {
//     final int lvlProgress = (mon.exp / mon.nextExpCap() * 512).round();
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (context, animation1, animation2) => PartyDetails(mon: mon),
//             transitionDuration: Duration.zero,
//             reverseTransitionDuration: Duration.zero,
//           ),
//         );
//       }, // TODO: open detailed view
//       child: Container(
//         padding: const EdgeInsets.all(5),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           border: Border.all(),
//           borderRadius: const BorderRadius.only(topLeft: Radius.circular(20))
//         ),
//         child: Stack(
//           alignment: Alignment.topCenter,
//           children: [
//             Column(
//               children: [
//                 Expanded(
//                   flex: 15,
//                   child: Image(image: AssetImage(mon.imageAsset))
//                 ),
//                 const SizedBox(height: 5),
//                 Expanded(
//                   flex: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 5, right: 5),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(mon.nickname),
//                         mon.gender == -1 ? const SizedBox() : Icon(mon.gender == 0 ? Icons.male : Icons.female, size: 15),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 5, right: 5),
//                     child: Row(
//                       children: [
//                         Text('Lv.${mon.level}'),
//                         const SizedBox(width: 5),
//                         Expanded(
//                           child: Container(
//                             height: 12,
//                             decoration: BoxDecoration(
//                               border: Border.all()
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: mon.level == 100 ? 1 : lvlProgress,
//                                   child: Container(
//                                     height: 12,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: mon.level == 100 ? 0 : 512 - min(lvlProgress, 512),
//                                   child: const SizedBox(
//                                     height: 12
//                                   ),
//                                 )
//                               ],
//                             )
//                           ),
//                         ),
//                         const SizedBox(width: 2.5),
//                         Container(
//                           padding: const EdgeInsets.all(1),
//                           height: 12,
//                           alignment: Alignment.center,
//                           color: Colors.black,
//                           child: const Text('Exp.', style: TextStyle(fontSize: 8, color: Colors.white),))
//                       ],
//                     )
//                   ),
//                 ),
//               ],
//             ),
//             Column(
//               children: [
//                 Expanded(
//                   flex: 6,
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Icon(Icons.catching_pokemon, size: 30), // TODO: change to poke ball asset image
//                       const Spacer(),
//                       mon.isShiny? const Icon(Icons.auto_awesome, size: 20) : const SizedBox(),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       GestureDetector(
//                         onTap: () {}, // TODO: open bag
//                         child: Container(
//                           margin: const EdgeInsets.only(right: 5),
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             border: Border.all(),
//                             color: Colors.white,
//                             shape: BoxShape.circle
//                           ),
//                           child: mon.heldItem == null ? const Icon(Icons.add, color: Colors.black54) : const Icon(Icons.question_mark) // TODO: change to item asset
//                         ),
//                       ),
//                     ],
//                   )
//                 ),
//                 const Expanded(
//                   flex: 2,
//                   child: SizedBox()
//                 )
//               ],
//             )
//           ],
//         )
//       ),
//     );
//   }

//   Widget _emptyTile() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black38),
//         borderRadius: const BorderRadius.only(topLeft: Radius.circular(20))
//       )
//     );
//   }

  Widget _backButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Row(
        children: [
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(bottom: 40),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle
            ),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                const Icon(Icons.clear_rounded, color: Colors.white),
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.3), 
                    shape: BoxShape.circle
                  )
                )
              ]
            )
          ),
          const Spacer()
        ],
      )
    );
  }
}