import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/dex_db.dart';
import 'package:pokemon_taskhunt_2/views/board.dart';
import 'package:pokemon_taskhunt_2/views/collection.dart';

class Landing extends StatelessWidget {
  final DexDB dex;
  final double containerWidth = 150;

  const Landing(this.dex, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Board(fullDex: dex.all)));
              },
              child: _formatButton('New Game')
            ),
            GestureDetector(
              child: _formatButton('Load Game')
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Collection(dex.all)));
              },
              child: _formatButton('Collection')
            ),
            GestureDetector(
              child: _formatButton('Settings')
            ),
          ]
        ),
      ),
    );
  }

  Widget _formatButton(String text) {
    return Container(
      width: containerWidth,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: const BorderRadius.all(Radius.circular(5))
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
      )
    );
  }
}