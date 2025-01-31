import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:pokemon_taskhunt_2/views/battle_screen.dart';
import 'package:pokemon_taskhunt_2/views/party.dart';
import 'package:pokemon_taskhunt_2/views/party_swap.dart';
import 'package:provider/provider.dart';


// TODO: add shiny indicator
class Encounter extends StatefulWidget {
  final Function(bool) onReturn;
  final Pokemon mon;
  
  const Encounter({required this.onReturn, required this.mon, super.key});

  @override
  State<Encounter> createState() => _EncounterState();
}

class  _EncounterState extends State<Encounter> {
  Random random = Random();
  late AccountProvider accProvider;
  bool showBag = false;
  bool showFightSelector = false;
  late Map<Items, int> items;
  Items? _bagSelectedItem;
  Items? _berryUsed;
  Pokemon? _fightSelectedMon;
  bool caught = false;
  bool exit = false;
  bool flee = false;
  bool uiLock = false;
  bool editName = false;
  /* Console State: managed by an int key
   * - 0: base state 
   *    - msg: 'A wild <mon> appeared! What will you do?'
   *    - tap does nothing
   * - 1: exit state
   *    - msg: 'Gotcha! You caught <mon>!'
   *    - tap: exit
   * - 2: use item (non-ball)
   *    - msg: 'Used a <item>.'
   *    - tap does nothing
   * - 3: use ball
   *    - msg: 'Used a <ball>.'
   *    - tap does nothing
   *    - auto: cycle to state 4 on successful shake check
   * - 4: shake check (UNUSED)
   *    - msg: '...'
   *    - tap does nothing
   *    - auto: cycle to state 4 for every successful shake check for max 4 times
   *            cycle to state 5 on failed shake check and non-flee
   *            cycle to state 6 on failed shake check and flee
   *            cycle to state 1 on last successful shake check
   * - 5: fail shake
   *    - msg: 'Oh no! The <mon> broke free!'
   *    - tap does nothing
   * - 6: flee
   *    - msg: 'Oh no! The <mon> ran away.'
   *    - tap: exit
   */
  int consoleState = 0;
  String consoleText = '';

  late TextEditingController _nameEditController;

  @override
  void dispose() {
    _nameEditController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameEditController = TextEditingController();
    _nameEditController.text = widget.mon.nickname;
    accProvider = context.read<AccountProvider>();
    items = accProvider.blitzGame.items;
    consoleText = 'A wild ${widget.mon.species.toUpperCase()} appeared! What will you do?';
  }

  @override
  Widget build(BuildContext context) {
    Pokemon mon = widget.mon;
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              _mainUI(mon),
              if (showBag) _bag(),
              if (flee) _fleeNotif(),
              if (showFightSelector) _fightSelection(),
              if (caught && exit) _caughtNotif(),
              if (editName) _nameEdit(),
            ],
          )
        );
      }
    );
  }

  Widget _fleeNotif() {
    int expGain = accProvider.blitzGame.averageLevel();
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
                const Text('Better luck next time!', textAlign: TextAlign.center,),
                const SizedBox(height: 8),
                Text('+$expGain Exp.'),
                const Text('+10 Coins'),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        accProvider.incrementBalance(10, 0);
                        accProvider.addExp(expGain);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.2),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white, width: 1.3),
                            borderRadius: BorderRadius.circular(5.5)
                          ),
                          child: const Text('OK', style: TextStyle(color: Colors.white))
                        ),
                      )
                    ),
                  ],
                ),
              ],
            )
          ),
          const Spacer()
        ],
      )
    );
  }

  void _handleNameEdit(String name) {
    if (name.trim() != '') widget.mon.setName(name);
    setState(() => editName = false);
  }

  Widget _nameEdit() {
    _nameEditController.text = widget.mon.nickname;
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 45),
      color: Colors.black38,
      child: Column(
        children: [
          const Spacer(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Text('What is ${widget.mon.species.toUpperCase()}\'s nickname?'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(7)
                          ),
                          height: 35,
                          clipBehavior: Clip.hardEdge,
                          child: Center(
                            child: TextField(
                              controller: _nameEditController,
                              autofocus: true,
                              autocorrect: false,
                              maxLength: 12,
                              showCursor: true,
                              // enableInteractiveSelection: false,
                              // contextMenuBuilder: null,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                counterText: '',
                                border: InputBorder.none
                              ),
                              style: TextStyle(fontSize: 15)
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 7),
                    GestureDetector(
                      onTap: () {
                        _handleNameEdit(_nameEditController.text);
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle
                        ),
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            const Icon(Icons.check, color: Colors.white, size: 20),
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1.3), 
                                shape: BoxShape.circle
                              )
                            )
                          ]
                        )
                      ),
                    )
                  ],
                ),
              ],
            )
          ),
          const Spacer(),
          const Spacer(),
          const Spacer()
        ],
      )
    );
  }

  // pulls up widget prompting user to add mon to party;
  // also processes exp gain for user's party 
  Widget _caughtNotif() {
    final int exp = (widget.mon.baseExpYield * widget.mon.level / 7).round();
    int coins = 100;
    for (Pokemon mon in accProvider.blitzGame.party) {
      if (mon.heldItem == Items.amuletCoin /* TODO: || mon.heldItem == Items.luckIncense */) {
        coins *= 2;
        break;
      }
    }
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 45),
      color: Colors.black38,
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  padding: EdgeInsets.only(left: 12, right: 10, bottom: 5, top: 5),
                  child: Row(
                    children: [
                      // TODO: wrap with gesture detector to bring up name editor
                      GestureDetector(
                        onTap: () {
                          setState(() => editName = true);
                        },
                        child: Container(
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white))
                          ),
                          child: Row(
                            children: [
                              Text(
                                widget.mon.nickname.toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 3),
                              Icon(Icons.edit, size: 11, color: Colors.white)
                            ]
                          ),
                        )
                      ),
                      
                      Spacer(),
                      Text('Lv.${widget.mon.level}', style: TextStyle(color: Colors.white, fontSize: 12)),
                      Spacer(),
                      Spacer(),
                      widget.mon.gender == -1 ? const SizedBox() : Icon(widget.mon.gender == 0 ? Icons.male : Icons.female, size: 13, color: Colors.white),
                      SizedBox(width: 3),
                      if (widget.mon.isShiny) const Icon(Icons.auto_awesome, color: Colors.yellow, size: 14),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 4.5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _ivStatsColumn(),
                      )),
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: double.infinity,
                          margin: const EdgeInsets.only(left: 5, top: 10, bottom: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all()
                          ),
                          child: Image(image: AssetImage(widget.mon.imageAsset))),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  margin: EdgeInsets.only(bottom: 2),
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 2, top: 2),
                  child: Row(
                    children: [
                      Text('Exp. Points'),
                      Spacer(),
                      Text('+$exp')
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 2, top: 2),
                  child: Row(
                    children: [
                      Text('Coins'),
                      Spacer(),
                      Text('+100')
                    ]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7, bottom: 2),
                  child: Row(
                    children: [
                      Text('Bonus', style: TextStyle(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                // TODO: add bonuses (coins and items)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 2, top: 2),
                  child: Row(
                    children: [
                      Text('Coins'),
                      Spacer(),
                      Text('+${coins - 100}')
                    ]
                  ),
                ),
                const SizedBox(height: 15),
                accProvider.blitzGame.party.length < 6
                  ? _exitButton(exp, coins)
                  : _addPartyScreen(exp, coins),
              ],
            )
          ),
          const Spacer()
        ],
      )
    );
  }

  Widget _exitButton(int exp, int coins) {
    return GestureDetector(
      onTap: () {
        accProvider.addCatchExp(exp);
        accProvider.incrementBalance(coins, 1);
        accProvider.partyAdd(widget.mon, null);
        widget.onReturn(true);
        Navigator.pop(context);
      },
      child: Container(
        width: 35,
        height: 35,
        margin: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle
        ),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            const Icon(Icons.check, color: Colors.white, size: 20),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.3), 
                shape: BoxShape.circle
              )
            )
          ]
        )
      ),
    );
  }

  Widget _addPartyScreen(int exp, int coins) {
    return Container(
      padding: EdgeInsets.only(bottom: 15, top: 12, left: 15, right: 15),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          Text('Your party is full! Add ${widget.mon.species.toUpperCase()} to your party?', textAlign: TextAlign.center,),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // button: yes
              GestureDetector(
                onTap: () {
                  accProvider.addCatchExp(exp);
                  accProvider.incrementBalance(coins, 1);
                  // accProvider.partyAdd(widget.mon, null);
                  widget.onReturn(true);
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => PartySwap(swapMon: widget.mon), // Replace with your next screen widget
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 1.3),
                      borderRadius: BorderRadius.circular(5.5)
                    ),
                    child: const Text('Yes', style: TextStyle(color: Colors.white))
                  ),
                )
              ),
      
              // button: no
              GestureDetector(
                onTap: () {
                  accProvider.addCatchExp(exp);
                  accProvider.incrementBalance(coins, 1);
                  widget.onReturn(true);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 1.3),
                      borderRadius: BorderRadius.circular(5.5)
                    ),
                    child: const Text('No', style: TextStyle(color: Colors.white))
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ivStatsColumn() {
    Pokemon mon = widget.mon;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 2.5,
                child: Container(
                  margin: EdgeInsets.only(right: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: mon.types[0].colour,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Text(mon.types[0].type, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))
                ),
              )
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 2.5,
                child: mon.types.length == 1
                    ? Container(
                      margin: EdgeInsets.only(right: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Icon(Icons.clear, size: 16, color: Colors.black)
                    )
                    : Container(
                      margin: EdgeInsets.only(right: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: mon.types[1].colour,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Text(mon.types[1].type, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))
                    ),
              )
            )
          ],
        ),
        const SizedBox(height: 8),
        _ivStat('HP', mon.ivs.hp),
        _ivStat('Atk', mon.ivs.atk),
        _ivStat('Def', mon.ivs.def),
        _ivStat('Sp. Atk', mon.ivs.spAtk),
        _ivStat('Sp. Def', mon.ivs.spDef),
        _ivStat('Speed', mon.ivs.speed),
        _ivRating()
      ]
    );
  }

  Widget _ivRating() {
    List<Widget> stars = [];
    int numStars = widget.mon.getNumStars();
    for (int i = 0; i < min(numStars, 3); i++) {
      stars.add(
        Icon(Icons.star_rounded, color: Colors.white)
      );
    }
    for (int i = 0; i < (3 - numStars); i++) {
      stars.add(Icon(Icons.star_outline_rounded, color: Colors.white));
    }
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              numStars == 4 ? Color.fromARGB(255, 241, 207, 35) : Colors.black,
              numStars == 4 ? Color.fromARGB(255, 233, 234, 166) : Colors.black,
            ],
          ),
          borderRadius: BorderRadius.circular(7)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: stars,
        )
      ),
    );
  }

  Widget _ivStat(String name, int value) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        SizedBox(width: 3),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(6)
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border(bottom: BorderSide(), top: BorderSide())
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 15 - value,
                    child: SizedBox()
                  )
                ],
              )
            ),
          )
        ),
        SizedBox(width: 3)
      ],
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
            padding: const EdgeInsets.only(left: 18, right: 18, top: 15, bottom: 15),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Column(
              children: [
                _opponentTile(),
                const Padding(
                  padding: EdgeInsets.all(3),
                  child: Text(
                    'vs.',
                    style: TextStyle(
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5, bottom: 8, left: 8, right: 8),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    children: _fightSelectorTiles()
                  ),
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
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => BattleScreen(mon: _fightSelectedMon!, opponent: widget.mon),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
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
          ),
          const Spacer()
        ],
      )
    );
  }

  Widget _opponentTile() {
    return Container(
      // height: 50,
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.only(right: 5, top: 10, bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(12), topRight: Radius.circular(3), bottomLeft: Radius.circular(3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            padding: const EdgeInsets.all(2),
            height: 45,
            width: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
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
                  Text(widget.mon.species),
                  const SizedBox(width: 1),
                  widget.mon.gender == -1 ? const SizedBox() : Icon(widget.mon.gender == 0 ? Icons.male : Icons.female, size: 14),
                  const SizedBox(width: 1),
                  if (widget.mon.isShiny) const Icon(Icons.auto_awesome, color: Colors.yellow, size: 14),
                ],
              ),
              Text(
                'Lv.${widget.mon.level}',
                style: const TextStyle(
                  fontSize: 10
                )
              )
            ],
          ),
          const Spacer(),
          Icon(Icons.brightness_7_rounded),
          SizedBox(width: 10)
        ]
      )
    );
  }

  List<Widget> _fightSelectorTiles() {
    List<Widget> tiles = [];
    for (Pokemon mon in accProvider.blitzGame.party) {
      tiles.add(_fightSelectorTile(mon));
    }
    for (int i = accProvider.blitzGame.party.length; i < 6; i++) {
      tiles.add(_emptyFightSelectorTile());
    }
    return tiles;
  }
  
  Widget _emptyFightSelectorTile() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(
        'EMPTY',
        style: TextStyle(
          color: Colors.black26,
          fontWeight: FontWeight.bold,
          fontSize: 12
        )
      )
    );
  }

  Widget _fightSelectorTile(Pokemon mon) {
    bool isSelected = _fightSelectedMon == mon;
    return GestureDetector(
      onTap: () => setState(() {
        if (!isSelected) {
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
          color: isSelected ? Colors.black : Colors.white
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
                    Text(mon.nickname, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                    const SizedBox(width: 1),
                    mon.gender == -1 ? const SizedBox() : Icon(mon.gender == 0 ? Icons.male : Icons.female, size: 14, color: isSelected ? Colors.white : Colors.black),
                    const SizedBox(width: 1),
                    if (widget.mon.isShiny) const Icon(Icons.auto_awesome, color: Colors.yellow, size: 14),
                  ],
                ),
                Text(
                  'Lv.${mon.level}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 10
                  )
                )
              ],
            ),
            const Spacer(),
            mon.heldItem == null ? Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.white : Colors.black),
                color: isSelected ? Colors.black : Colors.white
              ),
              child: isSelected ? const Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              ) : const Icon(
                Icons.question_mark,
                size: 18,
                color: Colors.black
              )
            ) : Container(),
            const SizedBox(width: 10)
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
                        onTap: () async {
                          Items itemUsed = _bagSelectedItem!;
                          setState(() {
                            uiLock = true;
                            showBag = false;
                            _bagSelectedItem = null;
                            consoleText = 'Used a ${itemUsed.name}';
                            consoleState = 3;
                            if (itemUsed.key >= 5) {
                              _berryUsed = itemUsed;
                              consoleState = 2;
                              uiLock = false;
                            }
                          });
                          accProvider.blitzGame.removeItem(itemUsed);
                          if (itemUsed.key < 5) {
                            // TODO
                            if (accProvider.blitzGame.party.isEmpty) {  // Party is empty; first catch guaranteed success
                              setState(() {
                                caught = true;
                              });
                            } else {  // Party not empty
                              final int rate = accProvider.blitzGame.shakeRate(widget.mon, _berryUsed, itemUsed);
                              print(rate);
                              setState(() => _berryUsed = null);
                              int counter = 0;
                              while (counter < 3 && !caught) {
                                setState(() {
                                  caught = accProvider.blitzGame.shakeCheck(rate);
                                });
                                if (caught) break;
                                await Future.delayed(const Duration(seconds: 1), () {
                                  counter++;
                                  setState(() {
                                    consoleText += ' .';
                                  });
                                });
                              }
                              await Future.delayed(const Duration(seconds: 1));
                              // flee chance calc
                              if (!caught) {
                                setState(() => uiLock = false);
                                print(widget.mon.fleeRate);
                                if (!caught && random.nextInt(100) < widget.mon.fleeRate) {
                                  widget.onReturn(false);
                                  setState(() {
                                    consoleState = 6;
                                    consoleText = 'Oh no! The wild ${widget.mon.species.toUpperCase()} ran away.';
                                  });
                                } else {
                                  setState(() {
                                    consoleText = 'Oh no! The ${widget.mon.species.toUpperCase()} broke free.';
                                    consoleState = 5;
                                  });
                                }
                              }
                            }
                            if (caught) {
                              setState(() {
                                consoleState = 1;
                                consoleText = 'Gotcha! You caught ${widget.mon.species.toUpperCase()}!';
                              });
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
            _nameBar(mon),
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

  Widget _nameBar(Pokemon mon) {
    return Container(
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
                      if (accProvider.blitzGame.party.isNotEmpty && !uiLock) {
                        showFightSelector = true;
                      }
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: accProvider.blitzGame.party.isEmpty || uiLock ? Colors.grey : Colors.black),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('BATTLE', style: TextStyle(color: accProvider.blitzGame.party.isEmpty || uiLock ? Colors.grey : Colors.black))
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (accProvider.blitzGame.party.isNotEmpty && !uiLock) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => Party(),
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
                        border: Border.all(color: accProvider.blitzGame.party.isEmpty || uiLock ? Colors.grey : Colors.black),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('PARTY', style: TextStyle(color: accProvider.blitzGame.party.isEmpty || uiLock ? Colors.grey : Colors.black))
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
                      if (!uiLock) showBag = true;
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: uiLock ? Colors.grey : Colors.black),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('BAG', style: TextStyle(color: uiLock ? Colors.grey : Colors.black))
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!uiLock) {
                        widget.onReturn(false);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: uiLock ? Colors.grey : Colors.black),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('RUN', style: TextStyle(color: uiLock ? Colors.grey : Colors.black))
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

  Widget _console(Pokemon mon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (consoleState == 1) {
            exit = true;
          } else if (consoleState == 6) {
            flee = true;
            exit = true;
          }
        });
      },
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Text(
              consoleText
            ),
            if (consoleState == 1 || consoleState == 6) Column(children: [
              Spacer(),
              Row(children: [
                Spacer(),
                Container(
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.3), 
                          shape: BoxShape.circle
                        )
                      )
                    ]
                  )
                ),
              ],)
            ])
          ],
        )
      ),
    );
  }
}