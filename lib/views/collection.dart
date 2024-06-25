import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/views/collection_page_view.dart';

class Collection extends StatefulWidget{
  final List<DexEntry> dex;

  const Collection(this.dex, {super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: Drawer(), // TODO: replace with filter drawer
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.filter_alt),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Collection'),
        centerTitle: true
      ),
      body: GridView.count(
        primary: true,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 6,
        children: _navigateToEntry()
      ),
      bottomNavigationBar: _backButton(context)
    );
  }

  List<Widget> _cleffaTest() {
    List<Image> list = [];
    for (int i = 0; i < 1000; i++) {
      list.add(const Image(image: AssetImage('assets/cleffa.png')));
    }
    return list;
  }

  List<Widget> _navigateToEntry() {
    List<Widget> list = [];
    for (DexEntry entry in widget.dex) {
      list.add(
        GestureDetector(
          onTap: () => {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => CollectionPageView(widget.dex, entry.dexNum - 1))
            )
          },
          child: Image(image: AssetImage(entry.forms[0].imageAssetM))
        )
      );
    }
    return list;
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

  // TODO
  Widget _filter() {
    return Drawer(
      child: ListView(

      )
    );
  }
}