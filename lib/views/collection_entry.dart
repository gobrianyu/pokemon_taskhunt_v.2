import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart' as dex;
import 'package:pokemon_taskhunt_2/models/move.dart';
import 'package:pokemon_taskhunt_2/models/moves_map_db.dart';
import 'package:pokemon_taskhunt_2/enums/types.dart';
import 'package:pokemon_taskhunt_2/providers/moves_db_provider.dart';
import 'package:pokemon_taskhunt_2/providers/moves_map_db_provider.dart';
import 'package:provider/provider.dart';

import 'collection_page_view.dart';

class CollectionEntry extends StatefulWidget {
  final List<dex.DexEntry> entries;
  final dex.DexEntry entry;
  final Map<dex.DexEntry, int> filteredDex;
  final int currPageIndex;
  final bool displayShiny;
  final bool displayMale;

  const CollectionEntry({required this.entries, required this.entry, required this.filteredDex, this.currPageIndex = 0, required this.displayShiny, required this.displayMale, super.key});

  List<dex.DexEntry> get filteredEntries {
    List<dex.DexEntry> newList = [];
    for (dex.DexEntry dexEntry in filteredDex.keys.map((e) => e).toList()) {
      newList.add(dexEntry);
    }
    return newList;
  }

  List<int> get filteredIndexes {
    List<int> newList = [];
    for (int index in filteredDex.values.map((e) => e).toList()) {
      newList.add(index);
    }
    return newList;
  }

  Map<dex.DexEntry, int> get newFilteredDex {
    Map<dex.DexEntry, int> newDex = {};
    newDex.addAll(filteredDex);
    return newDex;
  }

  @override
  State<CollectionEntry> createState() => _CollectionEntryState();
}

class _CollectionEntryState extends State<CollectionEntry> {
  double moveDetailsHeight = 0.0;
  int currPageIndex = 0;
  List<dex.DexEntry> filteredEntries = [];
  List<int> filteredIndexes = [];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currPageIndex);
    currPageIndex = widget.currPageIndex;
    filteredEntries = widget.filteredEntries;
    filteredIndexes = widget.filteredIndexes;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dex.DexEntry entry = widget.entry;
    dex.Form currForm = entry.forms[currPageIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _assetWindow(entry.forms),
              _buildTypes(currForm.type),
              _flavourText(currForm.category, currForm.entry),
              _measurements(currForm.height, currForm.weight),
              _stats(currForm.stats[0]),
              _evoChart(currForm),
              _movePool(currForm.key),
              const SizedBox(height: 100)
            ]
          )
        ),
      ),
    );
  }

  Widget _movePool(double dexId) {
    MovesMapDBProvider mapProvider = context.read<MovesMapDBProvider>();
    MovesDBProvider movesProvider = context.read<MovesDBProvider>();

    final MonMovesLib? movePool = mapProvider.movesMap.all[dexId];
    if (movePool == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'This Pokémon cannot learn any moves.\nThis is likely an error.',
            textAlign: TextAlign.center,
          ),
        )
      );
    }

    final List<int> fullPool = movePool.basePool;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Learnable Moves', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...fullPool.map((moveId) => _moveWidget(movesProvider.movesDB.all[moveId]))
        ]
      )
    );
  }

  Widget _moveWidget(Move move) {
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
        height: 35,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.only(bottom: 2, top: 2, left: 2, right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.7),
          borderRadius: BorderRadius.circular(100),
          color: const Color.fromARGB(255, 240, 240, 240)
        ),
        child: Row(
          children: [
            Image(image: AssetImage(move.type.iconAsset), width: 30, height: 30),
            const SizedBox(width: 10),
            Text(move.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            catContainer(move.category)
          ],
        )
      ),
    );
  }

  Widget _evoChart(dex.Form form) {
    dex.Form basic = form;
    double? prevKey = basic.evolutions[0].prevKey;
    while (prevKey != null) {
      List<dex.Form> forms = widget.entries[prevKey.toInt() - 1].forms;
      basic = forms[forms.indexWhere((form) => form.key == prevKey)];
      prevKey = basic.evolutions[0].prevKey;
    }
    EvoAsset head = EvoAsset.fromForm(form: basic, entries: widget.entries, evoStage: 1);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Evolution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _fillAssetColumns(head, [])
          ),
        ],
      ),
    );
  }

  List<Widget> _fillAssetColumns(EvoAsset head, List<Column> columns) {
    int initialPageIndex = filteredEntries.indexWhere((e) => e.dexNum == head.key.toInt());
    Map<dex.DexEntry, int> filteredDex = widget.newFilteredDex;
    if (columns.length < head.evoStage) {
      columns.add(Column(children: [
        Row(
          children: [
            if (columns.isNotEmpty) const Padding(
              padding: const EdgeInsets.all(5),
              child: Icon(Icons.arrow_right_alt_rounded),
            ),
            GestureDetector(
              onTap: () {
                if (initialPageIndex == -1) {
                  int newIndex = filteredEntries.indexWhere((e) => e.dexNum > head.key.toInt());
                  if (newIndex == -1) {
                    filteredEntries.add(widget.entries[head.key.toInt() - 1]);
                    filteredIndexes.add(head.key.getDecimals());
                  } else {
                    filteredEntries.insert(newIndex, widget.entries[head.key.toInt() - 1]);
                    filteredIndexes.insert(newIndex, head.key.getDecimals());
                  }
                  initialPageIndex = filteredEntries.indexWhere((e) => e.dexNum == head.key.toInt());
                  filteredDex = Map.fromIterables(filteredEntries, filteredIndexes);
                } else {
                  filteredDex[filteredDex.entries.firstWhere((e) => e.key.dexNum == head.key.toInt()).key] = head.key.getDecimals();
                }
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => CollectionPageView(
                      entries: widget.entries,
                      filteredDex: filteredDex,
                      initialPageIndex: initialPageIndex,
                    ),
                  ),
                );
              },
              child: Image(image: AssetImage(head.image), width: MediaQuery.of(context).size.width / 3 - 40),
            ),
          ],
        )
      ]));
    } else {
      columns[head.evoStage - 1].children.add(
        Row(
          children: [
            if (columns.isNotEmpty) const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.arrow_right_alt_rounded),
            ),
            GestureDetector(
              onTap: () {
                if (initialPageIndex == -1) {
                  int newIndex = filteredEntries.indexWhere((e) => e.dexNum > head.key.toInt());
                  if (newIndex == -1) {
                    filteredEntries.add(widget.entries[head.key.toInt() - 1]);
                    filteredIndexes.add(head.key.getDecimals());
                  } else {
                    filteredEntries.insert(newIndex, widget.entries[head.key.toInt() - 1]);
                    filteredIndexes.insert(newIndex, head.key.getDecimals());
                  }
                  initialPageIndex = filteredEntries.indexWhere((e) => e.dexNum == head.key.toInt());
                  filteredDex = Map.fromIterables(filteredEntries, filteredIndexes);
                } else {
                  filteredDex[filteredDex.entries.firstWhere((e) => e.key.dexNum == head.key.toInt()).key] = head.key.getDecimals();
                }
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => CollectionPageView(entries: widget.entries, filteredDex: filteredDex, initialPageIndex: initialPageIndex),
                  ),
                );
              },
              child: Image(image: AssetImage(head.image), width: MediaQuery.of(context).size.width / 3 - 40)
            ),
          ],
        )
      );
    }
    
    if (head.next.isNotEmpty) {
      for (EvoAsset next in head.next) {
        _fillAssetColumns(next, columns);
      }
    }
    return columns;
  }

  Widget _buildTypes(List<Types> types) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 5),
      child: Row(
        children: types.map((type) => typeContainer(type)).toList()
      ),
    );
  }

  Widget _stats(dex.Stats stats) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Base Stats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _statLine('HP', stats.hp),
          _statLine('Attack', stats.atk),
          _statLine('Defense', stats.def),
          _statLine('Sp. Atk', stats.spAtk),
          _statLine('Sp. Def', stats.spDef),
          _statLine('Speed', stats.speed)
        ]
      ),
    );
  }

  Widget _statLine(String statName, int amount) {
    double maxWidth = MediaQuery.of(context).size.width - 140;
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(statName)
        ),
        SizedBox(
          width: 30,
          child: Text(
            '$amount',
            style: const TextStyle(
              fontWeight: FontWeight.w700
            ),
          )
        ),
        Stack(
          children: [
            Container(
              width: maxWidth / 255 * amount,
              height: 10,
              color: const Color.fromARGB(255, 39, 39, 39)
            ),
            Container(
              width: maxWidth,
              height: 10,
              decoration: BoxDecoration(
                border: Border.all()
              ),
            )
          ],
        )
      ]
    );
  }

  Widget _measurements(double height, double weight) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 15),
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(),
          bottom: BorderSide()
        )
      ),
      child: Row(
        children: [
          const Spacer(),
          const Icon(Icons.scale),
          const SizedBox(width: 7),
          Text(
            '$weight kg'
          ),
          const Spacer(),
          const Spacer(),
          const Icon(Icons.straighten),
          const SizedBox(width: 7),
          Text(
            '${height/100} m'
          ),
          const Spacer()
        ]
      ),
    );
  }

  Widget _flavourText(String category, String entryText) {
     return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(top: 5, left: 6, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 15),
            child: Text(
              '$category Pokémon',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)
            ),
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(child: const Icon(Icons.search)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  entryText,
                  softWrap: true,
                ),
              ),
            ],
          )
        ]
       ),
     );
  }

  Widget _assetWindow(List<dex.Form> forms) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(bottom: 20, top: 20),
      alignment: Alignment.center,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(15))
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Row(
            children: [
              if (forms.length > 1) GestureDetector(
                onTap: () {
                  _pageController.previousPage(curve: Curves.linear, duration: const Duration(milliseconds: 1));
                },
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 30,
                  color: currPageIndex <= 0 ? Colors.black26 : Colors.black
                )
              ),
              Expanded(
                child: PageView.builder( // TODO: ensure only unlocked forms show
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: forms.length,
                  itemBuilder: (context, index) {
                    return _getImage(forms[index]);
                  },
                  onPageChanged: (index) => {setState(() {
                    currPageIndex = index;
                  })},
                ),
              ),
              if (forms.length > 1) GestureDetector(
                onTap: () {
                  _pageController.nextPage(curve: Curves.decelerate, duration: const Duration(milliseconds: 1));
                },
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 30,
                  color: currPageIndex < forms.length - 1 ? Colors.black : Colors.black26
                )
              ),
            ],
          ),
          if (forms.length > 1) Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
            decoration: const BoxDecoration(
              color: Colors.black54
            ),
            child: Text(
              '${currPageIndex + 1}/${forms.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12
              )
            )
          ), //TODO
        ],
      ),
    );
  }

  Widget _getImage(dex.Form form) {
    if (widget.displayShiny) {
      return widget.displayMale
          ? Image(image: AssetImage(form.imageAssetMShiny)) 
          : Image(image: AssetImage(form.imageAssetFShiny));
    }
    return widget.displayMale
        ? Image(image: AssetImage(form.imageAssetM))
        : Image(image: AssetImage(form.imageAssetF));
  }
}

class EvoAsset {
  final List<dex.DexEntry> entries;
  final String image;
  final List<EvoAsset> next;
  final int evoStage;
  final double key;

  EvoAsset({required this.entries, required this.image, required this.next, required this.evoStage, required this.key});
  
  factory EvoAsset.fromForm({required dex.Form form, required List<dex.DexEntry> entries, required int evoStage}) {
    List<dex.NextEvo> nextEvos = form.evolutions[0].next;
    if (nextEvos == []) {
      return EvoAsset(entries: entries, image: form.imageAssetM, next: [], evoStage: evoStage, key: form.key);
    }
    List<dex.Form> evoForms = nextEvos.map((nextEvo) {
        double key = nextEvo.key;
        List<dex.Form> forms = entries[key.toInt() - 1].forms;
        return forms[forms.indexWhere((form) => form.key == key)];
    }).toList();
    List<EvoAsset> evoAssets = evoForms.map((evoForm) => EvoAsset.fromForm(form: evoForm, entries: entries, evoStage: evoStage + 1)).toList();
    return EvoAsset(entries: entries, image: form.imageAssetM, next: evoAssets, evoStage: evoStage, key: form.key);
  }
}

extension DoubleExtensions on double {
  int getDecimals() {
    return ((this * 100 - toInt() * 100).abs()).toInt();
  }
}

class MoveDetails extends StatefulWidget {
  final Move move;

  const MoveDetails({super.key, required this.move});

  @override
  _MoveDetailsState createState() => _MoveDetailsState();
}

class _MoveDetailsState extends State<MoveDetails> {
  GlobalKey _moveDetailsHeightKey = GlobalKey();
  double moveDetailsHeight = 0.0;

  @override
  Widget build(BuildContext context) {
    Move move = widget.move;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_moveDetailsHeightKey.currentContext != null) {
        final RenderBox renderBox = _moveDetailsHeightKey.currentContext!.findRenderObject() as RenderBox;
        setState(() {
          moveDetailsHeight = renderBox.size.height;
        });
      }
    });
    return SizedBox(
      height: moveDetailsHeight * 3,
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
                  Padding(
                    padding: const EdgeInsets.all(13),
                    child: Text(
                      move.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      )
                    )
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _moveDetailBox(title: 'TYPE', child: typeContainer(move.type))
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _moveDetailBox(
                          title: 'CATEGORY',
                          child: Container(
                            padding: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color.fromARGB(255, 63, 63, 63)
                            ),
                            child: Row(
                              children: [
                                SizedBox(height: 30, child: catContainer(move.category)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 4),
                                  child: Text(
                                    move.category,
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          key: _moveDetailsHeightKey,
                          children: [
                            _moveDetailBox(
                              title: 'BASE POWER',
                              child: Text(
                                '${move.power == 65536 ? '∞' : move.power ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                                )
                              )
                            ),
                            const SizedBox(height: 10),
                            _moveDetailBox(
                              title: 'ACCURACY',
                              child: Text(
                                '${move.accuracy == 65536 ? '∞' : move.accuracy ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                                )
                              )
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 7),
                      if (moveDetailsHeight > 0) Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          height: moveDetailsHeight,
                          color: Color.fromARGB(255, 235, 235, 235),
                          child: Text(
                            move.flavourText?.trim().isNotEmpty ?? false ? move.flavourText! : 'This move has no additional effects.',
                            style: TextStyle(
                              color: move.flavourText?.trim().isNotEmpty ?? false ? Colors.black : Colors.grey,
                              fontSize: 13
                            )
                          )
                        ),
                      )
                    ],
                  )
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

  Widget _moveDetailBox({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.only(left: 5, right: 5),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 63, 63, 63)
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.white
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 235, 235, 235)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child
            ],
          )
        ),
      ],
    );
  }
}

Widget catContainer(String cat) {
  String moveCat = '';
  Color catColor = Colors.transparent;
  switch (cat.toLowerCase()) {
    case 'special':
      moveCat = 'assets/icons/special_icon.png';
      catColor = const Color(0xFF5067CC);
    case 'physical':
      moveCat = 'assets/icons/physical_icon.png';
      catColor = const Color(0xFFDA6038);
    case 'status':
      moveCat = 'assets/icons/status_icon.png';
      catColor = const Color(0xFF828282);
  }
  return Container(
    padding: const EdgeInsets.only(left: 5, right: 5, top: 2.5, bottom: 2.5),
    margin: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: catColor,
      borderRadius: BorderRadius.circular(3)
    ),
    child: Image(image: AssetImage(moveCat))
  );
}

Widget typeContainer(Types type) {
  return Container(
    width: 100,
    height: 30,
    alignment: Alignment.center,
    margin: const EdgeInsets.only(left: 4, right: 4),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      color: Color.fromARGB(255, 63, 63, 63)
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(2.5),
          child: Image(image: AssetImage(type.iconAsset)),
        ),
        const Spacer(),
        Text(
          type.type,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const Spacer(),
        const Spacer(),
      ],
    )
  );
}