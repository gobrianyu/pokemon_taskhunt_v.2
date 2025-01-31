import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/models/task.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:pokemon_taskhunt_2/views/collection.dart';
import 'package:pokemon_taskhunt_2/views/encounter.dart';
import 'package:pokemon_taskhunt_2/views/party.dart';
import 'package:provider/provider.dart';

// TODO: add dispose() method to all files

class Board extends StatefulWidget {
  final List<DexEntry> fullDex;
  
  const Board({required this.fullDex, super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  Random random = Random();

  final List<Items> itemsMasterList = [
    Items.pokeBall, Items.greatBall, Items.ultraBall, Items.masterBall,
    Items.pinapBerry, Items.razzBerry, Items.silverPinapBerry, Items.silverRazzBerry, Items.goldenPinapBerry, Items.goldenRazzBerry,
    Items.masterpieceTeacup
  ];
  bool showShop = false;
  bool showBag = false;
  bool showTasks = false;
  bool showCompletedTasks = true;
  bool showShopSell = false;
  int buyAmount = 0;
  int sellAmount = 0;
  int balance = 0;
  late Map<Items, int> items;
  bool _isLongPressing = false;
  Items? _shopSelectedItem;
  Items? _bagSelectedItem;
  late AccountProvider accProvider;
  List<Pokemon?> spawns = [];
  bool isSpawnsInitialized = false;
  List<Task> completedTasks = [];

  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0, // or whatever offset you wish
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();

    // Read the AccountProvider instance from the context
    accProvider = context.read<AccountProvider>();

    // Using addPostFrameCallback to avoid triggering state changes during the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeSpawns();
      setState(() {
        isSpawnsInitialized = true;
      });
    });
  }

  void _incrementCounter() {
    if (showShopSell) {
      if (!_bagCapReached()) {
        setState(() {
          sellAmount++;
        });
      }
    } else {
      if (!_shopCapReached()) {
        setState(() {
          buyAmount++;
        });
      }
    }
  }

  bool _shopCapReached() {
    return _shopSelectedItem == null || (buyAmount + 1) * _shopSelectedItem!.cost > balance || buyAmount >= 99;
  }

  bool _bagCapReached() {
    return _bagSelectedItem == null || items[_bagSelectedItem!]! == sellAmount;
  }

  void _startRapidIncrement() {
    _isLongPressing = true;
    Future.doWhile(() async {
      if (!_isLongPressing) return false;
      _incrementCounter();
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    });
  }

  void _stopRapidIncrement() {
    setState(() {
      _isLongPressing = false;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (showShopSell) {
        if (sellAmount > 0) {
          sellAmount--;
        }
      } else {
        if (buyAmount > 0) {
          buyAmount--;
        }
      }
    });
  }

  void _startRapidDecrement() {
    _isLongPressing = true;
    Future.doWhile(() async {
      if (!_isLongPressing) return false;
      _decrementCounter();
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    });
  }

  void _stopRapidDecrement() {
    setState(() {
      _isLongPressing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isSpawnsInitialized) {
      return Scaffold(
        appBar: _header(),
        body: Center(child: CircularProgressIndicator()),  // Placeholder for loading state
      );
    }
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        final blitzGame = accountProvider.blitzGame;
        balance = blitzGame.balance;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _header(),
          body: Stack(
            children: [
              _spawnBoard(),
              if (showShop) _shop(),
              if (showBag) _bag(),
              if (showTasks) _tasks(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _initializeSpawns() async {
    if (accProvider.blitzGame.spawns.isEmpty) {
      accProvider.setSpawns(generateSpawns());
    }
    spawns = accProvider.blitzGame.spawns;
    items = accProvider.blitzGame.items;
    balance = accProvider.blitzGame.balance;
  }

  Widget _tasks() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => showTasks = false),
          child: Container(
            color: const Color.fromARGB(0, 0, 0, 0),
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          top: 10,
          bottom: 210,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxHeight = constraints.maxHeight;
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: AbsorbPointer(
                      absorbing: false,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxHeight,
                        ),
                        child: NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: ListView(
                            primary: false,
                            shrinkWrap: true,
                            children: _taskTiles(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Pokemon?> generateSpawns() {
    List<Pokemon?> ret = [];
    final blitz = accProvider.blitzGame;
    int key = random.nextInt(49);
    for (int i = 0; i < 49; i++) {
      if (i == key) {
        ret.add(blitz.generateEncounter(widget.fullDex));
      } else {
        int n = 5 * blitz.averageLevel() + blitz.round - 2 * blitz.party.length + 12;
        if (random.nextInt(1000) < n) {
          ret.add(blitz.generateEncounter(widget.fullDex));
        } else {
          ret.add(null);
        }
      }
    }
    return ret;
  }

  List<Widget> _taskTiles() {
    List<Widget> tiles = [];
    final List tasks = accProvider.blitzGame.taskList.tasks;
    if (tasks.isEmpty) {
      tiles.add(_emptyTaskTile());
    } else {
      for (Task task in tasks) {
        if (task.isComplete) {
          tiles.add(_claimTaskTile(task));
        } else {
          tiles.add(_taskTile(task));
        }
      }
    }
    if (completedTasks.isNotEmpty) {
      tiles.add(
        GestureDetector(
          onTap: () {
            setState(() => showCompletedTasks = !showCompletedTasks);
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(showCompletedTasks ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.white),
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ),
                Icon(showCompletedTasks ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        )
      );
      if (showCompletedTasks) {
        for (Task task in completedTasks) {
          tiles.add(_completedTaskTile(task));
        }
      }
    }
    return tiles;
  }

  Widget _emptyTaskTile() {
    return const SizedBox(
      height: 50,
      child: Center(
        child: Text(
          'No more tasks to complete!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w300
          )
        ),
      ),
    );
  }

  Widget _completedTaskTile(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white10
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                task.difficulty,
                (index) => Icon(
                  Icons.stars,
                  color: task.difficulty == 6 ? const Color.fromARGB(255, 81, 78, 63) : const Color.fromARGB(255, 48, 48, 48),
                  size: 50
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                task.text,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11.5
                ),
              ),
              const Spacer(),
              Container(
                width: 70,
                padding: const EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(30)
                ),
                child: const Text('Completed', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
              )
            ],
          ),
        ],
      )
    );
  }

  Widget _claimTaskTile(Task task) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Encounter(
              mon: accProvider.blitzGame.generateEncounter(widget.fullDex),
              onReturn: (bool claimed) {
                if (claimed) {
                  accProvider.claimTask(task);
                  completedTasks.add(task);
                }
              }
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    task.difficulty,
                    (index) => Icon(
                      Icons.stars,
                      color: task.difficulty == 6 ? const Color.fromARGB(255, 237, 235, 222) : const Color.fromARGB(255, 237, 237, 237),
                      size: 50
                    ),
                  ),
                ],
              ),
              const Text(
                'CLAIM REWARD!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500
                )
              )
            ],
          ),
        )
      )
    );
  }

  Widget _taskTile(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(4)
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                task.difficulty,
                (index) => Icon(
                  Icons.stars,
                  color: task.difficulty == 6 ? const Color.fromARGB(255, 56, 54, 44) : const Color.fromARGB(255, 30, 30, 30),
                  size: 50
                ),
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    task.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 70,
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Text('${task.progress}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold), textAlign: TextAlign.end,)
                  )
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: EdgeInsets.only(right: (MediaQuery.of(context).size.width - 61.5) * (task.progress >= task.total ? 0 : ((task.total - task.progress) / task.total))),
                  width: MediaQuery.of(context).size.width,
                  height: 8,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.white), top: BorderSide(color: Colors.white))
                    ),
                  )
                ),
              )
            ],
          ),
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
          if (showShopSell) {
            sellAmount = 1;
          }
        } else if (showShopSell) {
          if (!_bagCapReached()) {
            setState(() => sellAmount++);
          }
        } else {
          _bagSelectedItem = null;
        }
      }),
      onLongPressStart: (details) {
        if (_bagSelectedItem == item && showShopSell) {
          if (!_bagCapReached()) {
            _startRapidIncrement();
          }
        }
      },
      onLongPressEnd: (details) {
        if (_bagSelectedItem == item && showShopSell) {
          _stopRapidIncrement();
        }
      },
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

  List<Widget> _shopTiles() {
    List<Widget> tiles = [];
    for (Items item in itemsMasterList) {
      tiles.add(_shopTile(item));
    }
    tiles.add(const SizedBox(height: 2));
    return tiles;
  }

  Widget _shopTile(Items item) {
    return GestureDetector(
      onTap: () {
        if (item.cost <= balance) {
          if (_shopSelectedItem == item) {
            if (!_shopCapReached()) {
              setState(() => buyAmount++);
            }
          } else {
            setState(() {
              buyAmount = 1;
              _shopSelectedItem = item;
            });
          }
        }
      }, // TODO
      onLongPressStart: (details) {
        if (_shopSelectedItem == item) {
          if (!_shopCapReached()) {
            _startRapidIncrement();
          }
        }
      },
      onLongPressEnd: (details) {
        if (_shopSelectedItem == item) {
          _stopRapidIncrement();
        }
      },
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 3),
        padding: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          border: Border.all(color: item.cost > balance ? Colors.grey : Colors.black),
          borderRadius: BorderRadius.circular(5),
          color: _shopSelectedItem == item ? Colors.black : Colors.white 
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(Icons.question_mark, color: item.cost > balance ? Colors.grey : _shopSelectedItem == item ? Colors.white : Colors.black)
            ),
            Expanded(
              flex: 5,
              child: Text(item.name, style: TextStyle(color: item.cost > balance ? Colors.grey : _shopSelectedItem == item ? Colors.white : Colors.black))
            ),
            Expanded(
              flex: 2,
              child: Text('${item.cost}', textAlign: TextAlign.end, style: TextStyle(color: item.cost > balance ? Colors.grey : _shopSelectedItem == item ? Colors.white : Colors.black)) 
            )
          ]
        )
      ),
    );
  }

  Widget _shop() {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 140),
      color: Colors.black38,
      child: showShopSell ? _shopSell() : _shopBuy()
    );
  }

  Widget _shopSell() {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            showShopSell = false;
                            _bagSelectedItem = null;
                            sellAmount = 0;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                              color: Colors.black
                            ),
                            child: const Text('Shop', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))
                          )
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                            color: Colors.white
                          ),
                          child: const Text('Sell', textAlign: TextAlign.center)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(20),
                height: 360,
                child: items.isNotEmpty 
                    ? NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: ListView(
                        controller: scrollController,
                        children: _bagTiles()
                      ),
                    )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ho-Oh',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400
                              )
                            ),
                            SizedBox(height: 5),
                            Text(
                              'You have nothing to sell...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300
                              )
                            ),
                          ],
                        )
                      ),
              )
            ],
          )
        ),
        Row(
          children: [
            const Spacer(),
            Container(
              height: 50,
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      if (sellAmount > 0) {
                        sellAmount--;
                      }
                    }),
                    onLongPressStart: (details) => _startRapidDecrement(),
                    onLongPressEnd: (details) => _stopRapidDecrement(),
                    child: AspectRatio(
                      aspectRatio: 0.8,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sellAmount > 0 ? Colors.black : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(3),
                            bottomLeft: Radius.circular(3)
                          ),
                          border: Border.all()
                        ),
                        child: Text(
                          '−',
                          style: TextStyle(
                            color: sellAmount > 0 ? Colors.white : Colors.black
                          ),
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(), bottom: BorderSide())
                      ),
                      child: Text(
                        '$sellAmount',
                        overflow: TextOverflow.ellipsis
                      )
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      if (!_bagCapReached()) {
                        setState(() {
                          sellAmount++;
                        });
                      }
                    }),
                    onLongPressStart: (details) => _startRapidIncrement(),
                    onLongPressEnd: (details) => _stopRapidIncrement(),
                    child: AspectRatio(
                      aspectRatio: 0.8,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !_bagCapReached() ? Colors.black : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(3),
                            bottomRight: Radius.circular(3)
                          ),
                          border: Border.all()
                        ),
                        child: Text(
                          '+',
                          style: TextStyle(
                            color: !_bagCapReached() ? Colors.white : Colors.black
                          ),
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 67,
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(3), topLeft: Radius.circular(3)),
                      border: Border.all()
                    ),
                    child: Text(
                      _bagSelectedItem == null || sellAmount == 0 ? '-' : '${(_bagSelectedItem!.cost * sellAmount / 2).toInt()}',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis
                    )
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      if (sellAmount > 0) {
                        int totalCost = (sellAmount / 2 * _bagSelectedItem!.cost).toInt();                            
                        accProvider.incrementBalance(totalCost, 3);
                        for (int i = 0; i < sellAmount; i++) {
                          accProvider.removeItem(_bagSelectedItem!);
                        }
                        items = accProvider.blitzGame.items;
                        balance = accProvider.blitzGame.balance;
                        sellAmount = 0;
                        _bagSelectedItem = null;
                      }
                    }),
                    child: AspectRatio(
                      aspectRatio: 0.9,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sellAmount > 0 ? Colors.black : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(3),
                            bottomRight: Radius.circular(3)
                          ),
                          border: const Border(top: BorderSide(), right: BorderSide(), bottom: BorderSide())
                        ),
                        child: Icon(Icons.check, size: 15, color: sellAmount > 0 ? Colors.white : Colors.black)
                      ),
                    ),
                  ),
                ],
              )
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () => setState(() {
            showShop = false;
            showShopSell = false;
            sellAmount = 0;
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
    );
  }

  Widget _shopBuy() {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                            color: Colors.white
                          ),
                          child: const Text('Shop', textAlign: TextAlign.center)
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            showShopSell = true;
                            buyAmount = 0;
                            _shopSelectedItem = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topRight: Radius.circular(15)),
                              color: Colors.black
                            ),
                            child: const Text('Sell', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))
                          )
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(20),
                height: 360,
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: ListView(
                    primary: true,
                    children: _shopTiles()
                  ),
                ),
              )
            ],
          )
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const Spacer(),
            Container(
              height: 50,
              padding: const EdgeInsets.all(9),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      if (buyAmount > 0) {
                        buyAmount--;
                      }
                    }),
                    onLongPressStart: (details) => _startRapidDecrement(),
                    onLongPressEnd: (details) => _stopRapidDecrement(),
                    child: AspectRatio(
                      aspectRatio: 0.8,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: buyAmount > 0 ? Colors.black : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(3),
                            bottomLeft: Radius.circular(3)
                          ),
                          border: Border.all()
                        ),
                        child: Text(
                          '−',
                          style: TextStyle(
                            color: buyAmount > 0 ? Colors.white : Colors.black
                          ),
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(), bottom: BorderSide())
                      ),
                      child: Text(
                        '$buyAmount',
                        overflow: TextOverflow.ellipsis
                      )
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      if (!_shopCapReached()) {
                        setState(() {
                          buyAmount++;
                        });
                      }
                    }),
                    onLongPressStart: (details) => _startRapidIncrement(),
                    onLongPressEnd: (details) => _stopRapidIncrement(),
                    child: AspectRatio(
                      aspectRatio: 0.8,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !_shopCapReached() ? Colors.black : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(3),
                            bottomRight: Radius.circular(3)
                          ),
                          border: Border.all()
                        ),
                        child: Text(
                          '+',
                          style: TextStyle(
                            color: !_shopCapReached() ? Colors.white : Colors.black
                          ),
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 67,
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(3), topLeft: Radius.circular(3)),
                      border: Border.all()
                    ),
                    child: Text(
                      _shopSelectedItem == null || buyAmount == 0 ? '-' : '${_shopSelectedItem!.cost * buyAmount}',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis
                    )
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      if (buyAmount > 0) {
                        final totalCost = buyAmount * _shopSelectedItem!.cost;                            
                        accProvider.decrementBalance(totalCost);
                        accProvider.addItemThroughPurchase(_shopSelectedItem!, buyAmount, 1);
                        items = accProvider.blitzGame.items;
                        balance -= totalCost;
                        buyAmount = 0;
                        _shopSelectedItem = null;
                      }
                    }),
                    child: AspectRatio(
                      aspectRatio: 0.9,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: buyAmount > 0 ? Colors.black : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(3),
                            bottomRight: Radius.circular(3)
                          ),
                          border: const Border(top: BorderSide(), right: BorderSide(), bottom: BorderSide())
                        ),
                        child: Icon(Icons.check, size: 15, color: buyAmount > 0 ? Colors.white : Colors.black)
                      ),
                    ),
                  ),
                ],
              )
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () => setState(() {
            showShop = false;
            buyAmount = 0;
            _shopSelectedItem = null;
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
    );
  }

  Widget _bag() {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 140),
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
                  child: items.keys.isNotEmpty ? NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: ListView(
                      primary: true,
                      children: _bagTiles()
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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(5),
                        height: 85,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                          _bagSelectedItem == null ? 'Select an item to view more information.' : _bagSelectedItem!.description, 
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w300
                          )
                        )
                      ),
                    ),
                  ],
                )
              ],
            )
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => setState(() {
              showBag = false;
              buyAmount = 0;
              _shopSelectedItem = null;
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

  Widget _spawnBoard() {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            shrinkWrap: true,
            primary: false,
            crossAxisCount: 7,
            children: _buildTiles(context)
          ),
        ),
        const Spacer(),
        _bottomBlock()
      ],
    );
  }

  Widget _blockButtonFormat(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 25, 25, 25),
        border: Border.all(color: Colors.white),
        borderRadius: const BorderRadius.all(Radius.circular(5))
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.white)),
      )
    );
  }

  Widget _bottomBlock() {
    return SizedBox(
      height: (MediaQuery.of(context).size.height - 80) / MediaQuery.of(context).size.width * 77,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            height: 108,
            decoration: const BoxDecoration(
              color: Colors.black
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 9,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all()
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 10, top: 3),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          primary: false,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          crossAxisCount: 3,
                          children: _partyIcons()
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, right: 15, bottom: 15, left: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            showShop = true;
                          }),
                          child: _blockButtonFormat('Shop')
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            showBag = true;
                          }),
                          child: _blockButtonFormat('Bag')
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                          setState(() {
                            accProvider.incrementRound();
                            // accProvider.incrementFriendship(null);
                            accProvider.setSpawns(generateSpawns());
                            spawns = accProvider.blitzGame.spawns;
                          });},
                          child: _blockButtonFormat('Skip')
                        ),
                      ),
                    ]
                  ),
                )
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _partyIcons() {
    int partySize = accProvider.blitzGame.party.length;
    List<Widget> tiles = [];
    for (Pokemon mon in accProvider.blitzGame.party) {
      tiles.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => Party(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              )
            );
            setState(() => items = accProvider.blitzGame.items);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 150, 150, 150)
            ),
            child: Container(
              padding: const EdgeInsets.all(4.2),
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Color.fromARGB(255, 25, 25, 25)),
                shape: BoxShape.circle,
                color: Colors.white
              ),
              child: Image(image: AssetImage(mon.imageAsset)))
          ),
        )
      );
    }
    for (int i = 0; i < 6 - partySize; i++) {
      tiles.add(
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 50, 50, 50), width: 1),
              shape: BoxShape.circle,
              color: Colors.black
            ),
            alignment: Alignment.center,
            child: Text(
              'EMPTY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 50, 50, 50),
                fontSize: 12
              )
            )
          ),
        )
      );
    }
    return tiles;
  }

  PreferredSize _header() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              const SizedBox(height: 40),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 12, right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all()
                      ),
                      child: const Icon(Icons.person)
                    ),
                    const Text(
                      'Blitz Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    const Spacer()
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.black,
                  ),
                  width: MediaQuery.of(context).size.width - 22,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Round ${accProvider.blitzGame.round}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13
                          ),
                          textAlign: TextAlign.center,
                        )
                      ),
                      Expanded(
                        flex: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => showTasks = !showTasks),
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(left: 0),
                            padding: const EdgeInsets.only(left:10, right: 10, top: 2, bottom: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('   Tasks   |   ${accProvider.blitzGame.starsCompleted}/${accProvider.blitzGame.taskList.totalStars}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                const SizedBox(width: 2),
                                const Icon(Icons.stars, color: Colors.white, size: 11.3)
                              ],
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ),
            ],
          ),
          showShop || showBag ? Container(color: Colors.black38) : const SizedBox(),
          Column(
            children: [
              const SizedBox(height: 38),
              Expanded(
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => Collection(widget.fullDex),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: showShop || showBag ? Colors.white : null
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(),
                            ),
                            child: Icon(
                              Icons.book,
                              size: 20
                            )
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      margin: const EdgeInsets.only(right: 11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: showShop || showBag ? Colors.white : null
                      ),
                      child: Container(
                        width: 77,
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(),
                        ),
                        child: Text(
                          '\$$balance',
                          softWrap: true,
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              const Expanded(child: SizedBox())
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTiles(BuildContext context) {
    List<Widget> tiles = [];
    for (int i = 0; i < 49; i++) {
      if (spawns[i] == null) {
        tiles.add(
          Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(7)
            ),
            child: const Icon(Icons.do_not_disturb, size: 30)
          )
        );
      } else {
        tiles.add(
          GestureDetector(
            onTap: () {
              setState(() {balance += 100;});
              accProvider.incrementBalance(100, 0);  // TODO: remove
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => Encounter(
                    mon: spawns[i]!,
                    onReturn: (bool claimed) {
                      if (claimed) {
                        accProvider.incrementRound();
                        accProvider.setSpawns(generateSpawns());
                        spawns = accProvider.blitzGame.spawns;
                      }
                    },
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ).then((claimed) {
                if (claimed == true) {
                  accProvider.setSpawns(generateSpawns());
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(7)
              ),
              child: const Icon(Icons.grass_rounded, size: 30)
            ),
          )
        );
      }
    }
    return tiles;
  }
}