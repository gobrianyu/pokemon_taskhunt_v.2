import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart' as dex;
import 'package:pokemon_taskhunt_2/models/regions.dart';
import 'package:pokemon_taskhunt_2/models/types.dart';
import 'package:pokemon_taskhunt_2/views/collection_page_view.dart';

class Collection extends StatefulWidget{
  final List<dex.DexEntry> fullDex;

  const Collection(this.fullDex, {super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Types> typeFilters = [];
  List<Regions> regionFilters = [];
  late Map<dex.DexEntry, int> filteredDex;
  
  
  @override
  Widget build(BuildContext context) {
    filteredDex = _filter();
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: _filterDrawer(), // TODO: replace with filter drawer
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          child: const Icon(Icons.filter_alt),
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
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
    List<dex.DexEntry> filteredList = filteredDex.keys.map((e) => e).toList();


    for (dex.DexEntry entry in filteredDex.keys) {
      list.add(    
        GestureDetector(
          onTap: () => {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => CollectionPageView(
                  entries: widget.fullDex, 
                  filteredDex: filteredDex,
                  initialPageIndex: filteredList.indexOf(entry), 
                )
              )
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
      onTap: () => Navigator.pop(context),
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
    );
  }

  Widget _filterType() {
    List<Widget> types = [];
    types.add(_filterTypeButton(Types.normal));
    types.add(_filterTypeButton(Types.fire));
    types.add(_filterTypeButton(Types.water));
    types.add(_filterTypeButton(Types.electric));
    types.add(_filterTypeButton(Types.grass));
    types.add(_filterTypeButton(Types.ice));
    types.add(_filterTypeButton(Types.fighting));
    types.add(_filterTypeButton(Types.poison));
    types.add(_filterTypeButton(Types.ground));
    types.add(_filterTypeButton(Types.flying));
    types.add(_filterTypeButton(Types.psychic));
    types.add(_filterTypeButton(Types.bug));
    types.add(_filterTypeButton(Types.rock));
    types.add(_filterTypeButton(Types.ghost));
    types.add(_filterTypeButton(Types.dragon));
    types.add(_filterTypeButton(Types.dark));
    types.add(_filterTypeButton(Types.steel));
    types.add(_filterTypeButton(Types.fairy));
    return Column(
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.only(left: 20, right: 20),
          padding: const EdgeInsets.only(bottom: 10),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide()
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Types',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )
              ),
              const Spacer(),
              GestureDetector(
                child: const Icon(Icons.clear),
                onTap: () => setState(() => typeFilters.clear()),
              )
            ],
          )
        ),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          crossAxisCount: 3,
          children: types
        ),
      ]
    );
  }

  Widget _filterRegion() {
    List<Widget> regions = [];
    regions.add(_filterRegionButton(Regions.kanto));
    regions.add(_filterRegionButton(Regions.johto));
    regions.add(_filterRegionButton(Regions.hoenn));
    regions.add(_filterRegionButton(Regions.sinnoh));
    regions.add(_filterRegionButton(Regions.unova));
    regions.add(_filterRegionButton(Regions.kalos));
    regions.add(_filterRegionButton(Regions.alola));
    regions.add(_filterRegionButton(Regions.galar));
    regions.add(_filterRegionButton(Regions.hisui));
    regions.add(_filterRegionButton(Regions.paldea));
    return Column(
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.only(left: 20, right: 20),
          padding: const EdgeInsets.only(bottom: 10),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide()
            )
          ),
          child: Row(
            children: [
              const Text(
                'Regions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )
              ),
              const Spacer(),
              GestureDetector(
                child: const Icon(Icons.clear),
                onTap: () => setState(() => regionFilters.clear()),
              )
            ],
          )
        ),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          crossAxisCount: 3,
          children: regions
        ),
      ]
    );
  }

  Widget _filterRegionButton(Regions region) {
    final has = regionFilters.contains(region);
    return GestureDetector(
      onTap:() => setState(() {
        if (has) {
          regionFilters.remove(region);
        } else {
          regionFilters.add(region);
        }
      }),
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          color: has ? Colors.black : null,
        ),
        child: Text(
          region.name.capitalize(),
          style: TextStyle(
            color: has ? Colors.white : Colors.black, 
            fontWeight: FontWeight.w500
          )
        )
      )
    );
  }

  Widget _filterTypeButton(Types type) {
    final has = typeFilters.contains(type);
    return GestureDetector(
      onTap:() => setState(() {
        if (has) {
          typeFilters.remove(type);
        } else {
          typeFilters.add(type);
        }
      }),
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: has ? null : Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: has ? type.colour : null,
        ),
        child: Text(
          type.name.capitalize(), 
          style: TextStyle(
            color: has ? Colors.white : Colors.black, 
            fontWeight: FontWeight.w500
          )
        )
      )
    );
  }

  Widget _filterDrawer() {
    return Drawer(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          const SizedBox(height: 40),
          _filterType(),
          const SizedBox(height: 25),
          _filterRegion()
        ]
      )
    );
  }

  Map<dex.DexEntry, int> _filter() {
    Map<dex.DexEntry, int> filteredDex = {};
    if (typeFilters.isEmpty && regionFilters.isEmpty) {
      for (dex.DexEntry entry in widget.fullDex) {
        filteredDex[entry] = 0;
      }
      return filteredDex;
    } else if (typeFilters.isEmpty) {
      for (dex.DexEntry entry in widget.fullDex) {
        if (regionFilters.contains(entry.forms[0].region)) {
          filteredDex[entry] = 0;
        }
      }
      return filteredDex;
    } else if (regionFilters.isEmpty) {
      for (dex.DexEntry entry in widget.fullDex) {
        for (dex.Form form in entry.forms) {
          for (Types type in form.type) {
            if (typeFilters.contains(type)) {
              filteredDex[entry] = form.key.getDecimals();
              break;
            }
          }
        }
      }
      return filteredDex;
    }
    for (dex.DexEntry entry in widget.fullDex) {
      if (regionFilters.contains(entry.forms[0].region)) {
        for (Types type in entry.forms[0].type) {
          if (typeFilters.contains(type)) {
            filteredDex[entry] = 0;
          }
        }
      }
    }
    return filteredDex;
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension DoubleExtensions on double {
  int getDecimals() {
    return ((this * 100 - toInt() * 100).abs()).toInt();
  }
}