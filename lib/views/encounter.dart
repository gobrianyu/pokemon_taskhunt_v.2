import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:pokemon_taskhunt_2/views/party.dart';
import 'package:provider/provider.dart';


// TODO: add shiny indicator
class Encounter extends StatefulWidget {
  final Function(bool) onReturn;
  final Pokemon mon;
  
  const Encounter({required this.onReturn, required this.mon, super.key});

  @override
  State<Encounter> createState() => _EncounterState();
}

class _EncounterState extends State<Encounter> {
  Random random = Random();
  bool showBag = false;
  bool showFightSelector = false;
  late Map<Items, int> items;
  Items? _bagSelectedItem;
  Items? _berryUsed;
  Pokemon? _fightSelectedMon;
  bool caught = false;
  bool exit = false;
  String consoleText = '';

  @override
  void initState() {
    super.initState();
    AccountProvider accProvider = context.read<AccountProvider>();
    items = accProvider.blitzGame.items;
    consoleText = 'A wild ${widget.mon.species.toUpperCase()} appeared! What will you do?';
  }

  @override
  Widget build(BuildContext context) {
    Pokemon mon = widget.mon;
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              _mainUI(mon),
              showBag ? _bag() : const SizedBox(),
              showFightSelector ? _fightSelection() : const SizedBox(),
              caught && exit ? _addPartyScreen() : const SizedBox(),
            ],
          )
        );
      }
    );
  }

  Widget _addPartyScreen() {
    final AccountProvider account = context.read<AccountProvider>();
    final int exp = (widget.mon.baseExpYield * widget.mon.level / 7).round();
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 45),
      color: Colors.black38,
      child: Column(
        children: [
          Spacer(),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Column(
              children: [
                Text('Add ${widget.mon.species.toUpperCase()} to your party?'),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (account.blitzGame.party.length > 0) {
                          account.addCatchExp(exp);
                        }
                        account.partyAdd(widget.mon, null);
                        widget.onReturn(true);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.2),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white, width: 1.3),
                            borderRadius: BorderRadius.circular(5.5)
                          ),
                          child: Text('Yes', style: TextStyle(color: Colors.white))
                        ),
                      )
                    ),
                    GestureDetector(
                      onTap: () {
                        if (account.blitzGame.party.length > 0) {
                          account.addCatchExp(exp);
                        }
                        widget.onReturn(true);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.2),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white, width: 1.3),
                            borderRadius: BorderRadius.circular(5.5)
                          ),
                          child: Text('No', style: TextStyle(color: Colors.white))
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ),
          Spacer()
        ],
      )
    );
  }

  Widget _fightSelection() {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 45),
      color: Colors.black38,
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 10),
                  child: const Text('Opponent')
                ),
                _opponentTile(),
                const Text('vs.'),
                Column(
                  children: _fightSelectorTiles()
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 10),
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: _fightSelectedMon == null ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (_fightSelectedMon != null) {
                        // TODO
                      }
                    },
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _fightSelectedMon == null ? Colors.black : Colors.white,
                          width: _fightSelectedMon == null ? 1 : 1.3
                        ),
                        borderRadius: BorderRadius.circular(15),
                        color: _fightSelectedMon == null ? Colors.white: Colors.black
                      ),
                      child: Text(
                        _fightSelectedMon == null ? 'Choose a Pokémon' : 'Start Battle',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _fightSelectedMon == null ? Colors.black : Colors.white,
                          fontWeight: _fightSelectedMon == null ? FontWeight.normal : FontWeight.w500
                        )
                      ),
                    ),
                  ),
                )
              ],
            )
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => setState(() {
              showFightSelector = false;
              _fightSelectedMon = null;
            }),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
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
          ),
          const Spacer()
        ],
      )
    );
  }

  Widget _opponentTile() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(5),
        color: Colors.black
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            padding: const EdgeInsets.all(2),
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white
            ),
            child: Image(image: AssetImage(widget.mon.imageAsset))
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 0),
                  Text(widget.mon.species, style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 1),
                  widget.mon.gender == -1 ? const SizedBox() : Icon(widget.mon.gender == 0 ? Icons.male : Icons.female, size: 14, color: Colors.white),
                ],
              ),
              Text(
                'Lv.${widget.mon.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10
                )
              )
            ],
          ),
          const Spacer(),
        ]
      )
    );
  }

  List<Widget> _fightSelectorTiles() {
    List<Widget> tiles = [];
    for (Pokemon mon in context.read<AccountProvider>().blitzGame.party) {
      tiles.add(_fightSelectorTile(mon));
    }
    return tiles;
  }

  Widget _fightSelectorTile(Pokemon mon) {
    return GestureDetector(
      onTap: () => setState(() {
        if (_fightSelectedMon != mon) {
          _fightSelectedMon = mon;
        } else {
          _fightSelectedMon = null;
        }
      }),
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 3),
        padding: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(5),
          color: _fightSelectedMon == mon ? Colors.black : Colors.white
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              padding: const EdgeInsets.all(2),
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
              ),
              child: Image(image: AssetImage(mon.imageAsset))
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 0),
                    Text(mon.species, style: TextStyle(color: _fightSelectedMon == mon ? Colors.white : Colors.black)),
                    const SizedBox(width: 1),
                    mon.gender == -1 ? const SizedBox() : Icon(mon.gender == 0 ? Icons.male : Icons.female, size: 14, color: _fightSelectedMon == mon ? Colors.white : Colors.black),
                  ],
                ),
                Text(
                  'Lv.${mon.level}',
                  style: TextStyle(
                    color: _fightSelectedMon == mon ? Colors.white : Colors.black,
                    fontSize: 10
                  )
                )
              ],
            ),
            const Spacer(),
            mon.heldItem != null ? Container(
              height: 30,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(),
                color: Colors.white
              ),
              child: const Icon(Icons.question_mark)
            ) : Container()
          ]
        )
      ),
    );
  }

  Widget _bag() {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 45),
      color: Colors.black38,
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 20),
            width: double.infinity,
            height: 465,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Bag')
                ),
                SizedBox(
                  height: 305,
                  child: items.keys.isNotEmpty ? MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: ListView(
                        primary: true,
                        children: _bagTiles()
                      ),
                    ),
                  )
                  : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Wow',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                          )
                        ),
                        SizedBox(height: 5),
                        Text(
                          'There\'s nothing in here...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300
                          )
                        ),
                      ],
                    )
                  ),
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(5),
                            height: 85,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white
                            ),
                            child: Text(
                              _bagSelectedItem == null ? 'Select an item to view more information.' : _bagSelectedItem!.description, 
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w300,
                              )
                            )
                          ),
                        ),
                      ],
                    ),
                    _bagSelectedItem != null && (_bagSelectedItem!.key < 5 || _bagSelectedItem!.key <= 10 && _berryUsed == null) 
                      ? GestureDetector(
                        onTap: () {
                          Items itemUsed = _bagSelectedItem!;
                          setState(() {
                            showBag = false;
                            _bagSelectedItem = null;
                            if (itemUsed.key >= 5) {
                              _berryUsed = itemUsed;
                            }
                          });
                          context.read<AccountProvider>().blitzGame.useItem(itemUsed);
                          if (itemUsed.key < 5) {
                            // TODO
                            final AccountProvider account = context.read<AccountProvider>();
                            if (account.blitzGame.party.isEmpty) {
                              setState(() {
                                caught = true;
                                exit = true;
                              });
                            } else {
                              final int rate = account.blitzGame.shakeRate(widget.mon, _berryUsed, itemUsed);
                              int counter = 0;
                              while (counter < 4 && !caught) {
                                setState(() => caught = account.blitzGame.shakeCheck(rate));
                                if (caught) {
                                  setState(() {
                                    consoleText = 'Gotcha! ${widget.mon.species.toUpperCase()} was caught!';
                                    exit = true;
                                  });
                                  // await user tap
                                  // show new widget
                                  // TODO: current progress
                                  if (account.blitzGame.party.length < 6) {
                                    // account.addCatchExp((widget.mon.baseExpYield * widget.mon.level / 7).round());
                                  } else {
                                    // TODO: bring up switch party ui
                                  }
                                }
                                counter++;
                              }
                              // flee chance calc
                              if (!caught && random.nextInt(100) <= widget.mon.fleeRate) {
                                widget.onReturn(true);
                                Navigator.pop(context);
                              }
                            }
                          }
                        },
                        child: Container(
                          height: 28,
                          width: 50,
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8), 
                              bottomRight: Radius.circular(8)
                            ),
                            border: Border.all()
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6), 
                                bottomRight: Radius.circular(6)
                              ),
                              border: Border.all(color: Colors.white, width: 1.3)
                            ),
                            child: const Text(
                              'Use',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )
                            ),
                          )
                        ),
                      ) 
                      : const SizedBox(),
                  ],
                )
              ],
            )
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => setState(() {
              showBag = false;
              _bagSelectedItem = null;
            }),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
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
          ),
          const Spacer()
        ],
      )
    );
  }

  List<Widget> _bagTiles() {
    List<Widget> tiles = [];
    for (Items item in items.keys) {
      tiles.add(_bagTile(item, items[item] ?? 0));
    }
    tiles.add(const SizedBox(height: 2));
    return tiles;
  }

  Widget _bagTile(Items item, int amount) {
    return GestureDetector(
      onTap: () => setState(() {
        if (_bagSelectedItem != item) {
          _bagSelectedItem = item;
        } else {
          _bagSelectedItem = null;
        }
      }),
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 3),
        padding: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(5),
          color: _bagSelectedItem == item ? Colors.black : Colors.white
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.question_mark, color: _bagSelectedItem == item ? Colors.white : Colors.black) // TODO: replace with image asset
            ),
            Expanded(
              flex: 5,
              child: Text(item.name, style: TextStyle(color: _bagSelectedItem == item ? Colors.white : Colors.black))
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text('×', style: TextStyle(color: _bagSelectedItem == item ? Colors.white : Colors.black, fontSize: 16)))
            ),
            Expanded(
              flex: 1,
              child: Text(
                '$amount',
                textAlign: TextAlign.end,
                style: TextStyle(color: _bagSelectedItem == item ? Colors.white : Colors.black),
                overflow: TextOverflow.ellipsis
              ) 
            )
          ]
        )
      ),
    );
  }

  Widget _mainUI(Pokemon mon) {
    return Column(
      children: [
        Row(
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
            const Spacer()
          ],
        ),
        const Spacer(),
        _assetAnimations(mon),
        const Spacer(),
        _bottomUI(mon, context)
      ],
    );
  }

  Widget _assetAnimations(Pokemon mon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 3 / 4,
      height: MediaQuery.of(context).size.width * 3 / 4,
      child: Image(image: AssetImage(mon.imageAsset))
    );
  }
  
  Container _bottomUI(Pokemon mon, BuildContext context) {
    AccountProvider account = context.read<AccountProvider>();
    return Container(
      height: 150,
      padding: const EdgeInsets.all(7),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _console(mon),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      if (account.blitzGame.party.isNotEmpty) {
                        showFightSelector = true;
                      }
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: account.blitzGame.party.isEmpty ? Colors.grey : Colors.black),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('FIGHT', style: TextStyle(color: account.blitzGame.party.isEmpty ? Colors.grey : Colors.black))
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (account.blitzGame.party.isNotEmpty) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => Party(party: account.blitzGame.party, isBlitz: true),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: account.blitzGame.party.isEmpty ? Colors.grey : Colors.black),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('PARTY', style: TextStyle(color: account.blitzGame.party.isEmpty ? Colors.grey : Colors.black))
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      showBag = true;
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: const Text('BAG')
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.onReturn(false);
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: const Text('RUN')
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  Container _console(Pokemon mon) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Text(
        consoleText
      )
    );
  }
}