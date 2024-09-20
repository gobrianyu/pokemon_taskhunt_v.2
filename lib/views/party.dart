import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:provider/provider.dart';

class Party extends StatefulWidget {
  final List<Pokemon> party;
  final bool isBlitz;
  
  const Party({required this.party, required this.isBlitz, super.key});

  @override
  State<Party> createState() => _PartyState();
}

class _PartyState extends State<Party> {

  @override
  void initState() {
    super.initState();
    AccountProvider accProvider = context.read<AccountProvider>();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark
      )
    );
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                primary: false,
                crossAxisCount: 2,
                children: _partyTiles()
              ),
            ),
          ),
          bottomNavigationBar: _backButton()
        );
      }
    );
  }

  List<Widget> _partyTiles() {
    List<Widget> tiles = [];
    for (Pokemon mon in widget.party) {
      tiles.add(_partyTile(mon));
    }
    for (int i = 0; i < 6 - widget.party.length; i++) {
      tiles.add(_emptyTile());
    }
    return tiles;
  }

  Widget _partyTile(Pokemon mon) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all()
      ),
      child: Text(mon.speciesExtended)
    );
  }

  Widget _emptyTile() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all()
      )
    );
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
}