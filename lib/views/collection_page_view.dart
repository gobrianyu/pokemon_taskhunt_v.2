import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart' as dex;
import 'collection_entry.dart'; // Ensure this path is correct based on your project structure

class CollectionPageView extends StatefulWidget {
  final List<dex.DexEntry> entries;
  final int initialPageIndex;

  const CollectionPageView(this.entries, this.initialPageIndex, {super.key});

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
        itemCount: widget.entries.length,
        itemBuilder: (context, index) {
          return CollectionEntry(widget.entries[index]);
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