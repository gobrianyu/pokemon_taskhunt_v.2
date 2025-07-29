import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/views/board.dart';
import 'package:pokemon_taskhunt_2/views/collection.dart';

class Landing extends StatelessWidget {
  final double containerWidth = 150;

  const Landing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => Board(fullDex: dex.all)));
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => const Board(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _formatButton('New Game')
              ),
              GestureDetector(
                child: _formatButton('Load Game')
              ),
              GestureDetector(
                child: _formatButton('Endless Mode')
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => Collection(dex.all)));
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => const Collection(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _formatButton('Collection')
              ),
              GestureDetector(
                child: _formatButton('Settings')
              ),
            ]
          ),
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