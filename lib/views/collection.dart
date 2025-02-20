import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart' as dex;
import 'package:pokemon_taskhunt_2/models/regions.dart';
import 'package:pokemon_taskhunt_2/models/types.dart';
import 'package:pokemon_taskhunt_2/views/collection_page_view.dart';

// TODO: unlock count

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
  final TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool inSearch = false;
  
  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchUpdate);
  }

  void _onSearchUpdate() {
    setState(() => searchText = searchController.text);
  }
  
  @override
  Widget build(BuildContext context) {
    filteredDex = _filter();
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      extendBody: true,
      appBar: _header(context),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() => inSearch = false);
        },
        child: Stack(
          children: [
            filteredDex.isEmpty 
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nothing to show',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300
                        )
                      ),
                      SizedBox(height: 450)
                    ]
                  ),
                ) 
              : NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ListView(
                  primary: true,
                  children: <Widget>[
                    const SizedBox(height: 5),
                    _regionGrid(Regions.kanto), // TODO: fill out dex
                    _regionGrid(Regions.johto),
                    _regionGrid(Regions.hoenn),
                    _regionGrid(Regions.sinnoh),
                  ]
                ),
              ),
            inSearch 
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color.fromARGB(100, 0, 0, 0)
                  )
                : const SizedBox(),
          ],
        ),
      ),
      bottomNavigationBar: _backButton(context)
    );
  }

  Widget _regionDivider(Regions region) {
    return Padding(
      padding: const EdgeInsets.only(left: 11, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            color: Colors.black,
            thickness: 2,
            height: 0,
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Text(
              '${region.name.substring(0, 1).toUpperCase()}${region.name.substring(1)}  |  0/${region.dexSize}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget _regionGrid(Regions region) {
    final tiles = _navigateToEntry(region.dexFirst, region.dexFirst + region.dexSize - 1);
    if (tiles.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        _regionDivider(region),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          primary: false,
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 6,
          children: _navigateToEntry(region.dexFirst, region.dexFirst + region.dexSize - 1)
        ),
      ],
    );
  }

  PreferredSize _header(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() => inSearch = false);
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            inSearch 
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color.fromARGB(100, 0, 0, 0)
                )
              : const SizedBox(),
            Column(
              children: [
                const SizedBox(height: 40),
                const Expanded(
                  flex: 3,
                  child: SizedBox(
                    child: Text(
                      'Collection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                      color: Colors.black,
                      // boxShadow: [BoxShadow(
                      //   color: Colors.black.withOpacity(0.5),
                      //   spreadRadius: 0,
                      //   blurRadius: 2,
                      //   offset: const Offset(0, 2),
                      // )]),
                    ),
                    width: MediaQuery.of(context).size.width - 22,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 12,
                          child: GestureDetector(
                            onTap: () => setState(() {}),
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              padding: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: const BorderRadius.all(Radius.circular(20))
                              ),
                              child: TextField(
                                onTap: () => setState(() => inSearch = true),
                                onSubmitted: (String _) => setState(() => inSearch = false),
                                controller: searchController,
                                cursorColor: Colors.white,
                                showCursor: false,
                                cursorWidth: 1.3,
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.white,),
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() => searchController.clear());
                                    },
                                    child: const Icon(Icons.clear, size: 18, color: Colors.white)
                                  )
                                ),
                                style: const TextStyle(color: Colors.white)
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            child: const Icon(Icons.filter_alt, color: Colors.white, size: 20), // TODO: Dynamnic icon?
                            onTap: () {
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) {
                                  return _filterDrawer();
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _navigateToEntry(int min, int max) {
    List<Widget> list = [];
    List<dex.DexEntry> filteredList = filteredDex.keys.map((e) => e).toList();

    for (dex.DexEntry entry in filteredList) {
      if (entry.dexNum >= min && entry.dexNum <= max) {
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
            child: Image(image: AssetImage(entry.forms[filteredDex[entry] ?? 0].imageAssetM))
          )
        );
      } else if (entry.dexNum > max) {
        break;
      }
    }
    return list;
  }

  Widget _backButton(BuildContext context) {
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
    );
  }

  Widget _filterType(StateSetter setter) {
    List<Widget> types = [];
    types.add(_filterTypeButton(Types.normal, setter));
    types.add(_filterTypeButton(Types.fire, setter));
    types.add(_filterTypeButton(Types.water, setter));
    types.add(_filterTypeButton(Types.electric, setter));
    types.add(_filterTypeButton(Types.grass, setter));
    types.add(_filterTypeButton(Types.ice, setter));
    types.add(_filterTypeButton(Types.fighting, setter));
    types.add(_filterTypeButton(Types.poison, setter));
    types.add(_filterTypeButton(Types.ground, setter));
    types.add(_filterTypeButton(Types.flying, setter));
    types.add(_filterTypeButton(Types.psychic, setter));
    types.add(_filterTypeButton(Types.bug, setter));
    types.add(_filterTypeButton(Types.rock, setter));
    types.add(_filterTypeButton(Types.ghost, setter));
    types.add(_filterTypeButton(Types.dragon, setter));
    types.add(_filterTypeButton(Types.dark, setter));
    types.add(_filterTypeButton(Types.steel, setter));
    types.add(_filterTypeButton(Types.fairy, setter));
    types.add(_placeholderButton());
    types.add(_placeholderButton());
    return Column(
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.only(left: 20, right: 20),
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
                  color: Color.fromARGB(200, 255, 255, 255),
                )
              ),
              const Spacer(),
              GestureDetector(
                child: const Icon(Icons.do_disturb_on_outlined, color: Color.fromARGB(200, 255, 255, 255)),
                onTap: () {
                  setState(() => typeFilters.clear());
                  setter(() {});
                },
              )
            ],
          )
        ),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 15),
          childAspectRatio: 2.3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          crossAxisCount: 5,
          children: types
        ),
      ]
    );
  }

  Widget _filterRegion(StateSetter setter) {
    List<Widget> regions = [];
    regions.add(_filterRegionButton(Regions.kanto, setter));
    regions.add(_filterRegionButton(Regions.johto, setter));
    regions.add(_filterRegionButton(Regions.hoenn, setter));
    regions.add(_filterRegionButton(Regions.sinnoh, setter));
    regions.add(_filterRegionButton(Regions.unova, setter));
    regions.add(_filterRegionButton(Regions.kalos, setter));
    regions.add(_filterRegionButton(Regions.alola, setter));
    regions.add(_filterRegionButton(Regions.galar, setter));
    regions.add(_filterRegionButton(Regions.hisui, setter));
    regions.add(_filterRegionButton(Regions.paldea, setter));
    return Column(
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.only(left: 20, right: 20),
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
                  color: Color.fromARGB(200, 255, 255, 255),
                )
              ),
              const Spacer(),
              GestureDetector(
                child: const Icon(Icons.do_disturb_on_outlined, color: Color.fromARGB(200, 255, 255, 255)),
                onTap: () {
                  setState(() => regionFilters.clear());
                  setter(() {});
                },
              )
            ],
          )
        ),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
          childAspectRatio: 2.3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          crossAxisCount: 5,
          children: regions
        ),
      ]
    );
  }

  Widget _placeholderButton() {
    return Container(
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(200, 255, 255, 255)),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: const Icon(Icons.clear, color: Color.fromARGB(200, 255, 255, 255), weight: 0.5, size: 18)
      // Placeholder(color: const Color.fromARGB(200, 255, 255, 255), strokeWidth: 0.9,)
    );
  }

  Widget _filterRegionButton(Regions region, StateSetter setter) {
    final has = regionFilters.contains(region);
    return GestureDetector(
      onTap:() {
        setState(() {
          if (has) {
            regionFilters.remove(region);
          } else {
            regionFilters.add(region);
          }
        });
        setter(() {});
      },
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: has ? Colors.transparent : const Color.fromARGB(200, 255, 255, 255)),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          color: has ? const Color.fromARGB(255, 186, 186, 186) : null,
        ),
        child: Text(
          region.name.capitalize(),
          style: TextStyle(
            color: has ? Colors.black : const Color.fromARGB(200, 255, 255, 255), 
            fontWeight: FontWeight.w500
          )
        )
      )
    );
  }

  Widget _filterTypeButton(Types type, StateSetter setter) {
    final has = typeFilters.contains(type);
    return GestureDetector(
      onTap:() {
        setState(() {
          if (has) {
            typeFilters.remove(type);
          } else {
            typeFilters.add(type);
          }
        });
        setter(() {});
      },
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: has ? null : Border.all(color: const Color.fromARGB(200, 255, 255, 255)),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          color: has ? type.colour : null,
        ),
        child: Text(
          type.name.capitalize(), 
          style: TextStyle(
            color: has ? Colors.white : const Color.fromARGB(200, 255, 255, 255), 
            fontWeight: FontWeight.w500
          )
        )
      )
    );
  }

  Widget _filterDrawer() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          height: 477,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  height: 450,
                  width: MediaQuery.of(context).size.width - 22,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      _filterType(setState),
                      const SizedBox(height: 20),
                      _filterRegion(setState)
                    ]
                  ),
                ),
              ),
              GestureDetector( // close drawer button
                onTap: (() {Navigator.pop(context);}),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      const Icon(Icons.expand_more, size: 25, color: Color.fromARGB(200, 255, 255, 255)),
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color.fromARGB(200, 255, 255, 255), width: 1.3), 
                          shape: BoxShape.circle
                        )
                      )
                    ]
                  )
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Map<dex.DexEntry, int> _filter() {
    final rtFilteredDex = _filterRT();
    if (searchText != '') {
      Map<dex.DexEntry, int> filteredDex = {};
      for (dex.DexEntry entry in rtFilteredDex.keys) {
        if (searchText == entry.dexNum.toString() || entry.forms[0].name.toLowerCase().contains(searchText.toLowerCase())) {
          filteredDex[entry] = rtFilteredDex[entry] as int;
        }
      }
      return filteredDex;
    }
    return rtFilteredDex;
  }

  Map<dex.DexEntry, int> _filterRT() {
    bool entryFilled = false;
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
              entryFilled = true;
              break;
            }
          }
          if (entryFilled) {
            entryFilled = false;
            break;
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