import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:provider/provider.dart';

class PartySwap extends StatefulWidget {
  final Pokemon swapMon;
  
  const PartySwap({required this.swapMon, super.key});

  @override
  State<PartySwap> createState() => _PartySwapState();
}

class _PartySwapState extends State<PartySwap> {
  late AccountProvider accProvider;
  Pokemon? selectedForTransfer;
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
          body: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 35, bottom: 8),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _partyTiles(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.keyboard_arrow_up),
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Select a Pokémon to swap out',
                              style: TextStyle(
                                fontSize: 15
                              )
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_up),
                        ],
                      ),
                      Expanded(child: _swapMonTile()),
                      _selectionButtons()
                    ],
                  ),
                ),
              ),
              if (transferSwap) _swapNotif(),
              if (cancelSwap) _cancelNotif(),
            ],
          ),
        );
      }
    );
  }

  Widget _swapNotif() {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 45),
      color: Colors.black38,
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Column(
              children: [
                Icon(Icons.info_rounded, size: 30),
                SizedBox(height: 15),
                Text(
                  'Do you want to swap ${selectedForTransfer?.nickname} out of the party?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15)
                ),
                SizedBox(height: 15),
                Text(
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15)
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => transferSwap = false);
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white
                              )
                            ),
                          )
                        )
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          accProvider.partyAdd(widget.swapMon, selectedForTransfer);
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              'Swap',
                              style: TextStyle(
                                color: Colors.white
                              )
                            ),
                          )
                        )
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
          const Spacer(),
        ],
      )
    );
  }

  Widget _cancelNotif() {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 45),
      color: Colors.black38,
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Column(
              children: [
                Icon(Icons.info_rounded, size: 30),
                SizedBox(height: 15),
                Text(
                  'Do you want to release ${widget.swapMon.nickname}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15)
                ),
                SizedBox(height: 15),
                Text(
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15)
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => cancelSwap = false);
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white
                              )
                            ),
                          )
                        )
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              'Release',
                              style: TextStyle(
                                color: Colors.white
                              )
                            ),
                          )
                        )
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
          const Spacer(),
        ],
      )
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

  Widget _swapMonTile() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white
          ),
          child: Row(
            children: [
              Image(image: AssetImage(widget.swapMon.imageAsset)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(widget.swapMon.nickname, style: TextStyle(fontSize: 16)),
                      SizedBox(width: 2),
                      widget.swapMon.gender == -1 ? const SizedBox() : Icon(widget.swapMon.gender == 0 ? Icons.male : Icons.female, size: 16, color: Colors.black),
                      SizedBox(width: 2),
                      widget.swapMon.isShiny? Icon(Icons.auto_awesome, size: 16, color: Colors.black) : const SizedBox(),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Lv.${widget.swapMon.level}', style: TextStyle(fontSize: 12),),
                      SizedBox(width: 20),
                      Text(widget.swapMon.heldItem == null ? 'No Held Items' : 'Held Item: ${widget.swapMon.heldItem?.name}', style: TextStyle(fontSize: 12),),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    height: 10,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(5)
                    ),
                  )
                ],
              )
            ],
          )
        ),
        Transform.rotate(
          angle: 1/3,
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle
            ),
            child: Text(
              'NEW', 
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold
              )
            )
          ),
        )
      ],
    );
  }

  Widget _partyTile(Pokemon? mon) {
    if (mon == null) {
      return _emptyTile();
    }
    final int lvlProgress = (mon.exp / mon.nextExpCap() * 512).round();
    return GestureDetector(
      onTap: () {
        if (selectedForTransfer == mon) {
          setState(() => selectedForTransfer = null);
        } else {
          setState(() => selectedForTransfer = mon);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: selectedForTransfer == mon ? 2.5 : 1),
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
                      Icon(selectedForTransfer == mon ? Icons.check_circle_rounded : Icons.catching_pokemon, size: 30, color: Colors.black), // TODO: change to poke ball asset image
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

  Widget _selectionButtons() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => cancelSwap = true);
              },
              child: Container(
                height: 40,
                padding: EdgeInsets.all(2.5),
                margin: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white
                    )
                  ),
                )
              )
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (selectedForTransfer != null) {
                  setState(() => transferSwap = true);
                }
              },
              child: Container(
                height: 40,
                padding: EdgeInsets.all(2.5),
                margin: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedForTransfer != null ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: selectedForTransfer != null ? null : Border.all(color: Colors.black45)
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text(
                    'Swap',
                    style: TextStyle(
                      color: selectedForTransfer != null ? Colors.white : Colors.black45
                    )
                  ),
                )
              )
            ),
          ),
        ],
      ),
    );
  }
}