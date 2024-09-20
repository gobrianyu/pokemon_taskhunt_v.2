import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart' as dex;
import 'collection_entry.dart'; // Ensure this path is correct based on your project structure

class CollectionPageView extends StatefulWidget {
  final List<dex.DexEntry> entries;
  final Map<dex.DexEntry, int> filteredDex;
  final int initialPageIndex;

  const CollectionPageView({required this.entries, required this.filteredDex, required this.initialPageIndex, super.key});

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

  @override
  CollectionPageViewState createState() => CollectionPageViewState();
}

class CollectionPageViewState extends State<CollectionPageView> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _displayMale = true;
  bool _displayShiny = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPageIndex);
    setState(() => _currentPage = widget.initialPageIndex);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    dex.DexEntry entry = widget.filteredEntries[_currentPage];
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: Container()
            ),
            Expanded(
              flex: 10,
              child: _nameHeader(entry, entry.genderKnown)
            )
          ],
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.filteredDex.length,
        onPageChanged: (_) {
          setState(() {
            _displayMale = true;
            _displayShiny = false;
          });
        },
        itemBuilder: (context, index) {
          return CollectionEntry(entries: widget.entries, filteredDex: widget.filteredDex, entry: widget.filteredEntries[index], currPageIndex: widget.filteredIndexes[index], displayMale: _displayMale, displayShiny: _displayShiny);
        },
      ),
      bottomNavigationBar: _backButton(context),
    );
  }

  Widget _nameHeader(dex.DexEntry entry, bool genderKnown) {
    int dexNum = entry.dexNum;
    String dexNumAsString = dexNum.toString().padLeft(4, '0');
    int unlockStatus = 0;
    
    for (dex.Form form in entry.forms) {
      if (form.unlockStatus > unlockStatus) {
        unlockStatus = form.unlockStatus;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: 0, right: 10),
      padding: const EdgeInsets.only(left: 10, right: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 30),
                Icon(Icons.catching_pokemon, color: unlockStatus <= 1 ? Colors.red : Colors.red, size: 30),
                Icon(Icons.circle_outlined, color: Colors.black, size: 30),
                Icon(Icons.circle_outlined, color: Colors.black, size: 32)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              '#$dexNumAsString', 
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white
              )
            ),
          ),
          Text(
            entry.forms[0].name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white
            )
          ),
          entry.dexNum == 29 ? Icon(Icons.female, color: Colors.white, size: 18) : SizedBox(),
          entry.dexNum == 32 ? Icon(Icons.male, color: Colors.white, size: 18) : SizedBox(),
          const Spacer(),
          _nameHeaderButtons(genderKnown, entry.genderRatio)
        ]
      ),
    );
  }

  Widget _nameHeaderButtons(bool genderKnown, double? ratio) { // TODO: hide buttons if entry still locked
    if (ratio != null && ratio == 0) {
      setState(() {
        _displayMale = false;
      });
    }
    return Row(
      children: [
        (genderKnown && ratio != null && ratio != 0)
              ? _maleButton()
              : Container(),
        (genderKnown && ratio != null && ratio != 100)
              ? _femaleButton()
              : Container(),
        // (_displayShiny) 
        //       ? _shinyButton()
        //       : Container()
        _shinyButton() //TODO: remove and uncomment above
      ],
    );
  }

  Widget _shinyButton() {
    return SizedBox(
      width: 38,
      child: Row(
        children: [
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _displayShiny = !_displayShiny;
              });
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: _displayShiny ? const Color.fromARGB(255, 122, 218, 175) : Colors.white,
              minimumSize: const Size(0, 0),
              padding: const EdgeInsets.all(6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            child: Icon(Icons.auto_awesome_rounded, color: _displayShiny ? Colors.white : Colors.grey, size: 20)
          ),
        ],
      ),
    );
  }

  Widget _femaleButton() {
    return SizedBox(
      width: 35,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _displayMale = false;
          });
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.pink,
          minimumSize: const Size(0, 0),
          padding: EdgeInsets.all(_displayMale? 3 : 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap
        ),
        child: Icon(Icons.female, color: Colors.white, size: _displayMale ? 15 : 20)
      ),
    );
  }

  Widget _maleButton() {
    return SizedBox(
      width: 35,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _displayMale = true;
          });
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          minimumSize: const Size(0, 0),
          padding: EdgeInsets.all(_displayMale? 6 : 3),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap
        ),
        child: Icon(Icons.male, color: Colors.white, size: _displayMale ? 20 : 15)
      ),
    );
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () => {Navigator.pop(context)},
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
                  width: 35,
                  height: 35,
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