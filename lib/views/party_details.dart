import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/enums/items.dart';
import 'package:pokemon_taskhunt_2/models/move.dart';
import 'package:pokemon_taskhunt_2/models/moves_db.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/enums/types.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:pokemon_taskhunt_2/views/collection_entry.dart';
import 'package:pokemon_taskhunt_2/widgets/alert_tab.dart';
import 'package:provider/provider.dart';

class PartyDetails extends StatefulWidget {
  final Pokemon mon;
  const PartyDetails({required this.mon, super.key});

  @override
  State<PartyDetails> createState() => _PartyDetailsState();
}

class _PartyDetailsState extends State<PartyDetails> {
  late final AccountProvider accProvider;
  final MovesDB movesDB = MovesDB();
  Items? _bagSelectedItem;
  late Map<Items, int> items;
  Items? _held;
  bool _showRemoveAlert = false;
  bool _showAddMoveAlert = false;
  bool _showCannotAddMoveAlert = false;

  @override
  void initState() {
    accProvider = context.read<AccountProvider>();
    items = accProvider.blitzGame.items;
    _held = widget.mon.heldItem;
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
            alignment: Alignment.bottomCenter,
            children: [
              _fullScaffold(),
              _backButton(),
              if (_showRemoveAlert) _removeItemAlert(),
              if (_showAddMoveAlert) _addMoveAlert(),
              if (_showCannotAddMoveAlert) _cannotAddMoveAlert(),
            ],
          ),
          
        );
      }
    );
  }

  Widget _fullScaffold() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 40),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 10),
            child: Row(
              children: [
                const Icon(Icons.catching_pokemon, size: 20),
                const SizedBox(width: 5),
                Text(widget.mon.nickname, style: const TextStyle(fontSize: 16)),
                widget.mon.gender == -1 ? const SizedBox() : Icon(widget.mon.gender == 0 ? Icons.male : Icons.female, size: 17),
                const Spacer(),
                Text('Lv.${widget.mon.level}', style: const TextStyle(fontSize: 16))
              ]
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image(image: AssetImage(widget.mon.imageAsset)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _friendshipBar(),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return _itemBag();
                          },
                        ).whenComplete(() => setState(() => _bagSelectedItem = null));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.3),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: const Icon(Icons.backpack_outlined, size: 25)
                      ),
                    ),
                  ],
                )
              ],
            )
          ),
          Expanded(
            flex: 8,
            child: _infoPanel(),
          )
        ],
      ),
    );
  }

  Widget _friendshipBar() {
    List<Widget> hearts = [];
    for (int i = 0; i < widget.mon.friendship; i++) {
      hearts.add(
        Container(
          padding: const EdgeInsets.only(bottom: 2, top: 4, left: 5, right: 5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black
          ),
          child: const Icon(Icons.favorite, size: 15, color: Colors.white)
        ),
      );
    }
    for (int i = 0; i < 5 - widget.mon.friendship; i++) {
      hearts.add(
        Container(
          padding: const EdgeInsets.only(bottom: 2, top: 4, left: 5, right: 5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(100, 0, 0, 0)
          ),
          child: const Icon(Icons.favorite, size: 15, color: Colors.white)
        ),
      );
    }
    return Row(
      children: hearts,
    );
  }

  void _updateHeldItem() {
    if (_held != null) {
      setState(() {
        accProvider.addItem(_held, 1);
      });
    }
    setState(() {
      accProvider.removeItem(_bagSelectedItem!);
      accProvider.setHeldItem(widget.mon, _bagSelectedItem!);
      _held = widget.mon.heldItem;
      items = accProvider.blitzGame.items;
    });
  }

  Widget _itemBag() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.52,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                  ),
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  padding: const EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 15),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Bag (Held Items)')
                      ),
                      Expanded(
                        child: items.keys.isNotEmpty ? NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: ListView(
                            padding: const EdgeInsets.all(0),
                            primary: true,
                            children: _bagTiles(setState)
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
                      GestureDetector(
                        onTap: () {
                          if (_bagSelectedItem != null) {
                            _updateHeldItem();
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width / 3,
                          padding: const EdgeInsets.all(2.5),
                          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _bagSelectedItem != null ? Colors.black : const Color.fromARGB(100, 0, 0, 0),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: const Text(
                              'Give',
                              style: TextStyle(
                                color: Colors.white
                              )
                            ),
                          )
                        )
                      ),
                    ]
                  ),
                ),
              ),
              GestureDetector( // close drawer button
                onTap: (() {
                  Navigator.pop(context);
                }),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle
                  ),
                  height: 45,
                  width: 45,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        const Icon(Icons.expand_more, size: 25, color: Colors.white),
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
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  List<Widget> _bagTiles(StateSetter setter) {
    List<Widget> tiles = [];
    for (Items item in items.keys) {
      tiles.add(_bagTile(item, items[item] ?? 0, setter));
    }
    tiles.add(const SizedBox(height: 2));
    return tiles;
  }

  Widget _bagTile(Items item, int amount, StateSetter setter) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (_bagSelectedItem == item) Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.only(left: 5, right: 5, top: 45, bottom: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 0.5)
          ),
          child: Text(
            item.description,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w300
            )
          )
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (_bagSelectedItem != item) {
                _bagSelectedItem = item;
              } else {
                _bagSelectedItem = null;
              }
            });
            setter(() {});
          },
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(5),
              color: _bagSelectedItem == item ? Colors.black : Colors.white,
              boxShadow: [
                if (_bagSelectedItem == item) BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                )
              ]
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
        ),
      ],
    );
  }

  Widget _infoPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 90),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(), left: BorderSide(), right: BorderSide()),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15)
        )
      ),
      child: Column(
        children: [
          _tags(),
          _expInfo(),
          _movesPanel(),
          _heldItem(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _ivStatsColumn()
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 8,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8, left: 6, right: 6),
                          child: Text(
                            'Stat Values',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Expanded(
                          child: StatSpreadHexagon(
                            width: MediaQuery.of(context).size.width / 2,
                            stats: widget.mon.getStats(),
                            maxStats: widget.mon.maxStats(),
                          ),
                        ),
                        const SizedBox(height: 0)
                      ],
                    )
                  )
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  

  Widget _movesPanel() {
    int move1Id = widget.mon.move1Id;
    int? move2Id = widget.mon.move2Id;
    Widget move2Widget = const SizedBox.shrink();
    if (move2Id == null) move2Widget = _emptyMoveBox();
    if (widget.mon.movePool.all.length <= 1) move2Widget = _nullMoveBox();  // case of mons who don't learn a second move (i.e. Ditto, Smeargle)

    return Padding(
      padding: const EdgeInsets.only(top: 13, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _moveBox(movesDB.all[move1Id])),
          const SizedBox(width: 7),
          Expanded(child: move2Id == null ? move2Widget : _moveBox(movesDB.all[move2Id])) 
        ],
      ),
    );
  }

  Widget _nullMoveBox() {
    return GestureDetector(
      onTap: () {},  // TODO: open alert with msg: 'This Pokémon cannot learn a second move.'
      child: Container(
        height: 25,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(100)
        ),
        child: const Icon(Icons.clear, size: 18)
      ),
    );
  }

  Widget _emptyMoveBox() {
    return GestureDetector(
      onTap: () {
        setState(() => _showAddMoveAlert = true);
      },
      child: Container(
        height: 25,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Icon(Icons.add, size: 18)
      ),
    );
  }

  Widget _moveBox(Move move) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            return MoveDetails(move: move);
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 1, top: 1, bottom: 1, right: 5),
        height: 25,
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 100, 100, 100)),
          borderRadius: BorderRadius.circular(100),
          color: const Color.fromARGB(255, 240, 240, 240)
        ),
        child: Row(
          children: [
            Image(image: AssetImage(move.type.iconAsset)),
            const SizedBox(width: 7),
            Text(
              move.name,
              style: const TextStyle(fontSize: 12)
            )
          ],
        )
      ),
    );
  }

  Widget _ivStatsColumn() {
    Pokemon mon = widget.mon;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 230, 230, 230),
            Colors.white
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          const Text(
            'IV Quality',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 6),
          _ivStat('HP', mon.ivs.hp),
          _ivStat('Atk', mon.ivs.atk),
          _ivStat('Def', mon.ivs.def),
          _ivStat('Sp. Atk', mon.ivs.spAtk),
          _ivStat('Sp. Def', mon.ivs.spDef),
          _ivStat('Speed', mon.ivs.speed),
          const SizedBox(height: 5),
          Flexible(child: _ivRating())
        ]
      ),
    );
  }

  Widget _ivRating() {
    List<Widget> stars = [];
    int numStars = widget.mon.getNumStars();
    for (int i = 0; i < min(numStars, 3); i++) {
      stars.add(
        const Icon(Icons.star_rounded, color: Colors.white)
      );
    }
    for (int i = 0; i < (3 - numStars); i++) {
      stars.add(const Icon(Icons.star_outline_rounded, color: Colors.white));
    }
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 50
      ),
      height: double.infinity,
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            numStars == 4 ? const Color.fromARGB(255, 241, 207, 35) : Colors.black,
            numStars == 4 ? const Color.fromARGB(255, 233, 234, 166) : Colors.black,
          ],
        ),
        borderRadius: BorderRadius.circular(7)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: stars,
      )
    );
  }

  Widget _ivStat(String name, int value) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.5),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(width: 3),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: value,
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          border: Border(bottom: BorderSide(), top: BorderSide())
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 15 - value,
                      child: const SizedBox()
                    )
                  ],
                )
              ),
            )
          ),
        ],
      ),
    );
  }


  Widget _expInfo() {
    int lvlProgress = (widget.mon.exp / widget.mon.nextExpCap() * 1024).round();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text('Exp. Points: ${widget.mon.totalExp()}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              const Spacer(),
              widget.mon.level >= 100 ? const SizedBox() : Text('${widget.mon.nextExpCap() - widget.mon.exp} Exp. Points until next level', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w300), overflow: TextOverflow.ellipsis,)
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(6)
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: widget.mon.level == 100 ? 1 : lvlProgress,
                    child: Container(
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        border: Border(bottom: BorderSide(), top: BorderSide())
                      ),
                    ),
                  ),
                  Expanded(
                    flex: widget.mon.level == 100 ? 0 : 1024 - lvlProgress,
                    child: const SizedBox()
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }

  Widget _tags() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(4)
          ),
          child: Text(
            widget.mon.key.round() > 999 ? 'No. ${widget.mon.key.round()}'
              : widget.mon.key.round() > 99 ? 'No. 0${widget.mon.key.round()}'
                : widget.mon.key.round() > 9 ? 'No. 00${widget.mon.key.round()}'
                  : 'No. 000${widget.mon.key.round()}'
          )
        ),
        Container(
          margin: const EdgeInsets.only(left: 5),
          padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(4)
          ),
          child: Text(widget.mon.species)
        ),
        const Spacer(),
        _typeTagsContainer()
      ]
    );
  }

  Widget _heldItem() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return _itemBag();
          },
        ).whenComplete(() => setState(() => _bagSelectedItem = null));
      },
      child: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(), bottom: BorderSide())
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 3, bottom: 3),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all()
              ),
              child: _held == null ? const Icon(Icons.add) : const Icon(Icons.question_mark) // TODO: variable held items
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_held == null ? 'No Held Item' : 'Held Item: ${_held!.name}', style: const TextStyle(fontSize: 13)),
                      const Spacer(),
                      if (_held != null) GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() => _showRemoveAlert = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all()
                          ),
                          child: const Icon(Icons.delete_rounded, size: 13)),
                      )
                    ],
                  ),
                  if (_held != null) Text(_held!.description, softWrap: true, style: const TextStyle(fontSize: 10))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _cannotAddMoveAlert() {
    Size alertSize = MediaQuery.of(context).size;
    double alertWidth = alertSize.width;
    double alertTabHeight = 50;
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 45, top: 50),
      color: Colors.black38,
      child: Column(
        children: [
          const Spacer(),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              AlertTab(
                height: 100,
                width: alertWidth,
                tabHeight: alertTabHeight,
                tabWidth: (alertWidth - 100) * 2 / 3 - 7,
                colour: Colors.black,
                radius: 15,
                innerRadius: 10
              )
            ]
          ),
          const Spacer(),
        ]
      )
    );
  }

  Widget _addMoveAlert() {
    int balance = accProvider.blitzGame.balance;
    Size alertSize = MediaQuery.of(context).size;
    double alertWidth = alertSize.width;
    double alertTabHeight = 50;
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 45),
      color: Colors.black38,
      child: Column(
        children: [
          const Spacer(),
          Stack(
            alignment: Alignment.topRight,
            children: [
              AlertTab(
                height: 100,
                width: alertWidth - 100,
                tabWidth: (alertWidth - 100) * 2 / 3 - 7,
                tabHeight: alertTabHeight,
                colour: Colors.black,
                radius: 15,
                innerRadius: 10
              ),
              Column(
                children: [
                  SizedBox(
                    height: alertTabHeight,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(left: 7, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: const Text(
                                'MOVE TUTOR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Container(
                            height: 100,
                            margin: const EdgeInsets.only(bottom: 7, top: 7, right: 5),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 3, left: 3),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              child: Text(
                                '\$${accProvider.blitzGame.balance}',
                                style: const TextStyle(
                                  color: Colors.white
                                ),
                              )
                            )
                          ),
                        )
                      ],
                    )
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${widget.mon.nickname} can learn a new move!',
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const Text(
                          'Select Move Tutor Method',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          )
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 13, top: 13),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 240, 240),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Text(
                                  'Spend 100 Coins'
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (balance >= 100) {
                                        widget.mon.unlockSecondMove();
                                        accProvider.decrementBalance(100);
                                        setState(() => _showAddMoveAlert = false);
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 35,
                                    padding: const EdgeInsets.all(2.5),
                                    margin: const EdgeInsets.only(left: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: balance >= 100 ? Colors.black : Colors.grey,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: const Text(
                                        'Unlock',
                                        style: TextStyle(
                                          color: Colors.white
                                        )
                                      ),
                                    )
                                  )
                                ),
                              ),
                            ],
                          )
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 13),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 240, 240),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    'Use 1 TM'
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // TODO: add functionality after implementing TM items
                                      },
                                      child: Container(
                                        height: 35,
                                        padding: const EdgeInsets.all(2.5),
                                        margin: const EdgeInsets.only(left: 10, bottom: 13),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,  // TODO: set colour based on items available
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.white),
                                            borderRadius: BorderRadius.circular(20)
                                          ),
                                          child: const Text(
                                            'Unlock',
                                            style: TextStyle(
                                              color: Colors.white
                                            )
                                          ),
                                        )
                                      )
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        '0/1',  // TODO: change to dynamic text
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        )
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showAddMoveAlert = false;
                            });
                          },
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.all(2.5),
                            margin: const EdgeInsets.only(left: 10, right: 10),
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
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white
                                )
                              ),
                            )
                          )
                        ),
                      ],
                    )
                  ),
                ],
              )
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _removeItemAlert() {
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
                const Icon(Icons.info_rounded, size: 30),
                const SizedBox(height: 15),
                Text(
                  'Remove ${_held?.name} from ${widget.mon.nickname}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15)
                ),
                const SizedBox(height: 15),
                const Text(
                  'The item will be returned to your bag.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15)
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _showRemoveAlert = false);
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.all(2.5),
                          margin: const EdgeInsets.only(left: 10, right: 10),
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
                            child: const Text(
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
                          accProvider.addItem(_held, 1);
                          accProvider.setHeldItem(widget.mon, null);
                          setState(() {
                            items = accProvider.blitzGame.items;
                            _held = widget.mon.heldItem;
                            _showRemoveAlert = false;
                          });
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.all(2.5),
                          margin: const EdgeInsets.only(left: 10, right: 10),
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
                            child: const Text(
                              'Remove',
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

  Widget _typeTagsContainer() {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 61, 60, 60),
        borderRadius: BorderRadius.circular(40)
      ),
      child: Row(
        children: _typeTags(),
      )
    );
  }

  List<Widget> _typeTags() {
    List<Widget> tags = [];
    for (Types type in widget.mon.types) {
      tags.add(
        Padding(
          padding: const EdgeInsets.all(1.5),
          child: Image(image: AssetImage(type.iconAsset), height: 21)
        )
        // Container(
        //   margin: const EdgeInsets.only(left: 5),
        //   padding: const EdgeInsets.only(left: 7, right: 7, top: 3, bottom: 3),
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(4),
        //     color: type.colour
        //   ),
        //   child: Text(type.type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        // ),
      );
    }
    return tags;
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
            decoration: const BoxDecoration(
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

class Labels extends StatefulWidget {
  const Labels({required this.stats, required this.radius, required this.diameter, super.key});

  final double radius, diameter;
  final Stats stats;

  @override
  LabelsState createState() => LabelsState();
}

class LabelsState extends State<Labels> {
  Size? size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          size = renderBox.size;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 9.5,
        );
    final textStyleBold = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        );
    const textAlign = TextAlign.center;

    if (size == null) {
      return Container(); // Return an empty container until size is available
    }

    final center = Offset(size!.width / 2, size!.height / 2);

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 / 12) + center.dx + 16,
              widget.radius * sin(pi * 2 / 12) + center.dy + 5,
            ),
            width: 50,
            height: 32,
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Def', textAlign: textAlign, style: textStyle),
                Text(widget.stats.def.toString(), textAlign: textAlign, style: textStyleBold),
              ],
            ),
          ),
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 / 4) + center.dx,
              widget.radius * sin(pi * 2 / 4) + center.dy + 18,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              children: [
                Text('Speed', textAlign: textAlign, style: textStyle),
                Text(widget.stats.speed.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 * 5 / 12) + center.dx - 22,
              widget.radius * sin(pi * 2 * 5 / 12) + center.dy + 5,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Sp. Def', textAlign: textAlign, style: textStyle),
                Text(widget.stats.spDef.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 * 7 / 12) + center.dx - 20,
              widget.radius * sin(pi * 2 * 7 / 12) + center.dy - 5,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Sp.Atk', textAlign: textAlign, style: textStyle),
                Text(widget.stats.spAtk.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 * 3 / 4) + center.dx,
              widget.radius * sin(pi * 2 * 3 / 4) + center.dy - 15,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              children: [
                Text('HP', textAlign: textAlign, style: textStyle),
                Text(widget.stats.hp.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 22 / 12) + center.dx + 16,
              widget.radius * sin(pi * 22 / 12) + center.dy - 5,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Atk', textAlign: textAlign, style: textStyle),
                Text(widget.stats.atk.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        )
      ]
    );
  }
}

class StatSpreadHexagon extends StatelessWidget {
  final double width;
  final Stats stats, maxStats;

  const StatSpreadHexagon({required this.width, required this.stats, required this.maxStats, super.key});

  double get diameter => width - 100;
  double get radius => diameter / 2;

  List<double> getMultipliers() {
    List<double> multipliers = [];
    int k = 10;  // expansion constant
    multipliers.add(min((stats.def + k) / (maxStats.def + k), 1));
    multipliers.add(min((stats.speed + k) / (maxStats.speed + k), 1));
    multipliers.add(min((stats.spDef + k) / (maxStats.spDef + k), 1));
    multipliers.add(min((stats.spAtk + k) / (maxStats.spAtk + k), 1));
    multipliers.add(min((stats.hp + k) / (maxStats.hp + k), 1));
    multipliers.add(min((stats.atk + k) / (maxStats.atk + k), 1));
    return multipliers;
  } 

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Labels(
            radius: radius,
            diameter: diameter,
            stats: stats,
          ),
          CustomPaint(painter: HexagonPainter(radius: radius)),
          ClipPath(
            clipper: HexagonClipper(radius: radius, multipliers: getMultipliers()),
            child: SizedBox(
              width: diameter, 
              height: diameter,
              child: ColoredBox(
                color: Colors.blue.withOpacity(0.4)
              )
            )
          )
        ]
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  final double radius;
  final List<double> multipliers;

  HexagonClipper({required this.radius, required this.multipliers});

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.width / 2);
    final Path path = Path();
    
    final angleMul = [1, 3, 5, 7, 9, 11];
    path.addPolygon(
      [
        for (int i = 0; i < 6; i++)
          Offset(
            radius * multipliers[i] * cos(pi * 2 * angleMul[i] / 12) + center.dx,
            radius * multipliers[i] * sin(pi * 2 * angleMul[i] / 12) + center.dy,
          ),
      ],
      true,
    );
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

}

class HexagonPainter extends CustomPainter {
  final double radius;
  
  HexagonPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    Paint borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1.2;
    Paint innerPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Colors.black54
      ..strokeWidth = 0.8;

    final center = Offset(size.width / 2, size.width / 2);
    final angles = [1, 3, 5, 7, 9, 11, 1];
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(
          radius * cos(pi * 2 * angles[i] / 12) + center.dx,
          radius * sin(pi * 2 * angles[i] / 12) + center.dy,
        ),
        Offset(
          radius * cos(pi * 2 * angles[i + 1] / 12) + center.dx,
          radius * sin(pi * 2 * angles[i + 1] / 12) + center.dy,
        ),
        borderPaint,
      );
    }
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(
          radius * cos(pi * 2 * angles[i] / 12) + center.dx,
          radius * sin(pi * 2 * angles[i] / 12) + center.dy,
        ),
        Offset(
          radius * cos(pi * 2 * angles[i + 3] / 12) + center.dx,
          radius * sin(pi * 2 * angles[i + 3] / 12) + center.dy,
        ),
        innerPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}