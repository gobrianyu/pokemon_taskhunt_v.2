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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.filteredDex.length,
        itemBuilder: (context, index) {
          return CollectionEntry(entries: widget.entries, filteredDex: widget.filteredDex, entry: widget.filteredEntries[index], currPageIndex: widget.filteredIndexes[index]);
        },
      ),
      bottomNavigationBar: _backButton(context),
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