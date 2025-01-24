import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart' as dex;
import 'package:pokemon_taskhunt_2/models/types.dart';

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
              const SizedBox(height: 100)
            ]
          )
        ),
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
          child: Image(image: AssetImage(head.image), width: 100),
        )
      ]));
    } else {
      columns[head.evoStage - 1].children.add(
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
          child: Image(image: AssetImage(head.image), width: 100)
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
      padding: EdgeInsets.only(left: 10, top: 5),
      child: Row(
        children: types.map((type) => _typeContainer(type)).toList()
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
          child: Text(
            statName
          )
        ),
        SizedBox(
          width: 30,
          child: Text(
            '$amount',
            style: TextStyle(
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


  Widget _typeContainer(Types type) {
    return Container(
      width: 100,
      height: 30,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: type.colour
      ),
      child: Text(
        type.type,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      )
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
            padding: EdgeInsets.only(left: 4, top: 15),
            child: Text(
              '$category Pokémon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)
            ),
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(child: Icon(Icons.search)),
              SizedBox(width: 5),
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
        children: [
          Row(
            children: [
              if (forms.length > 1) GestureDetector(
                onTap: () {
                  _pageController.previousPage(curve: Curves.linear, duration: Duration(milliseconds: 1));
                },
                child: Icon(Icons.chevron_left_rounded)
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
                  _pageController.nextPage(curve: Curves.decelerate, duration: Duration(milliseconds: 1));
                },
                child: Icon(Icons.chevron_right_rounded)
              ),
            ],
          ),
          Container(), //TODO
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