import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:pokemon_taskhunt_2/views/party_details.dart';
import 'package:provider/provider.dart';

class Party extends StatefulWidget {
  final List<Pokemon> party;
  final bool isBlitz;
  
  const Party({required this.party, required this.isBlitz, super.key});

  @override
  State<Party> createState() => _PartyState();
}

class _PartyState extends State<Party> {

  @override
  void initState() {
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
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height - 100) * 3 / 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                primary: false,
                crossAxisCount: 2,
                children: _partyTiles()
              ),
            ),
          ),
          bottomNavigationBar: _backButton()
        );
      }
    );
  }

  List<Widget> _partyTiles() {
    List<Widget> tiles = [];
    for (Pokemon mon in widget.party) {
      tiles.add(_partyTile(mon));
    }
    for (int i = 0; i < 6 - widget.party.length; i++) {
      tiles.add(_emptyTile());
    }
    return tiles;
  }

  Widget _partyTile(Pokemon mon) {
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
      }, // TODO: open detailed view
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Expanded(
                  flex: 15,
                  child: Image(image: AssetImage(mon.imageAsset))
                ),
                SizedBox(height: 5),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(mon.speciesExtended),
                        mon.gender == -1 ? const SizedBox() : Icon(mon.gender == 0 ? Icons.male : Icons.female, size: 15),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Row(
                      children: [
                        Text('Lv.${mon.level}'),
                        SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              border: Border.all()
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: mon.level == 100 ? 1 : lvlProgress,
                                  child: Container(
                                    height: 12,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  flex: mon.level == 100 ? 0 : 512 - min(lvlProgress, 512),
                                  child: SizedBox(
                                    height: 12
                                  ),
                                )
                              ],
                            )
                          ),
                        ),
                        SizedBox(width: 2.5),
                        Container(
                          padding: EdgeInsets.all(1),
                          height: 12,
                          alignment: Alignment.center,
                          color: Colors.black,
                          child: Text('Exp.', style: TextStyle(fontSize: 8, color: Colors.white),))
                      ],
                    )
                  ),
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
                      Icon(Icons.catching_pokemon, size: 30), // TODO: change to poke ball asset image
                      Spacer(),
                      mon.isShiny? Icon(Icons.auto_awesome, size: 20) : SizedBox(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {}, // TODO: open bag
                        child: Container(
                          margin: EdgeInsets.only(right: 5),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.white,
                            shape: BoxShape.circle
                          ),
                          child: mon.heldItem == null ? Icon(Icons.add, color: Colors.black54) : Icon(Icons.question_mark) // TODO: change to item asset
                        ),
                      ),
                    ],
                  )
                ),
                Expanded(
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
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
      )
    );
  }

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
              borderRadius: BorderRadius.circular(20)
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
                    borderRadius: BorderRadius.circular(20)
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