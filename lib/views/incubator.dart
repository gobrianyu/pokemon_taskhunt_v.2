import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

// TODO: add egg shop

class Incubator extends StatefulWidget {
  const Incubator({super.key});

  @override
  State<Incubator> createState() => _IncubatorState();
}

class _IncubatorState extends State<Incubator> {
  late AccountProvider accProvider;
  List<Egg> eggs = [];
  int numUnlocked = 0;
  bool _showPurchase = false;

  @override
  void initState() {
    accProvider = context.read<AccountProvider>();
    eggs = accProvider.blitzGame.eggs;
    numUnlocked = accProvider.blitzGame.unlockedEggSlots;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _balance(),
                    Expanded(child: _eggTiles()),
                    SizedBox(height: 25),
                    _backButton(),
                  ],
                )
              ),
              if (_showPurchase) _purchaseSlot()
            ],
          ),
          // bottomNavigationBar: _backButton(),
        );
      }
    );
  }

  Widget _balance() {
    return Container(
      padding: const EdgeInsets.all(3),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Container(
        alignment: Alignment.centerRight,
        width: 77,
        padding: const EdgeInsets.only(left: 4, right: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(3)
        ),
        child: Text('\$${accProvider.blitzGame.balance}')
      ),
    );
  }

  Widget _eggTiles() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(24), topLeft: Radius.circular(24), topRight: Radius.circular(10)),
        color: Color.fromARGB(15, 0, 0, 0)
      ),
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: 20),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          if (eggs.length > index) {
            return _eggTile(eggs[index]);
          } else if (index < numUnlocked) {
            return _unlockedEggTile();
          } else if (numUnlocked == index) {
            return _lockedEggTile(true);
          }
          return _lockedEggTile(false);
        },
      ),
    );
  }

  Widget _unlockedEggTile() {
    return GestureDetector(
      onTap: () {},  // TODO
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(20, 0, 0, 0),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(15), topLeft: Radius.circular(15), topRight: Radius.circular(5))
        ),
        child: const Icon(Icons.add_rounded, color: Color.fromARGB(180, 0, 0, 0), size: 30)
      ),
    );
  }

  Widget _purchaseSlot() {
    int cost = numUnlocked * 250;
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 45, top: 35),
      color: Colors.black38,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _balance(),
          const Spacer(),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 15, right: 15, top: 25, bottom: 25),
            margin: EdgeInsets.only(left: 38, right: 38),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Column(
              children: [
                Text(
                  'Purchase a new egg slot? (\$$cost)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15)
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _showPurchase = false);
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              'No',
                              style: TextStyle(
                                color: Colors.white
                              )
                            ),
                          )
                        )
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          accProvider.unlockEggSlot(cost);
                          setState(() {
                            numUnlocked = accProvider.blitzGame.unlockedEggSlots;
                            _showPurchase = false;
                          });
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                color: Colors.white
                              )
                            ),
                          )
                        )
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
          const Spacer()
        ],
      )
    );
  }

  Widget _lockedEggTile(bool purchasable) {
    int nextCost = numUnlocked * 250;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(100, 0, 0, 0)),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(15), topLeft: Radius.circular(15), topRight: Radius.circular(5))
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (purchasable) SizedBox(height: 20),  // TODO: Do i want this?
          Icon(Icons.lock, color: Color.fromARGB(100, 0, 0, 0), size: 30),
          SizedBox(height: 3),
          if (purchasable) GestureDetector(
            onTap: () {
              if (accProvider.blitzGame.balance >= nextCost) setState(() => _showPurchase = true);
            },
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: accProvider.blitzGame.balance >= nextCost ? Colors.black : Color.fromARGB(100, 0, 0, 0)
              ),
              child: Container(
                padding: EdgeInsets.only(left: 7, right: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Text("\$${nextCost}", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500))
              ),
            )
          )
        ],
      )
    );
  }

  Widget _eggTile(Egg egg) {
    List<Widget> stars = [];
    for (int i = 0; i < min(egg.rarity, 6); i++) {
      stars.add(Icon(Icons.star, color: Color.fromARGB(220, 0, 0, 0), size: MediaQuery.of(context).size.width / 25));
    }
    return GestureDetector(
      onTap: () {
        // TODO: nav
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(20, 0, 0, 0),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(15), topLeft: Radius.circular(15), topRight: Radius.circular(5))
        ),
        child: Column(
          children: [
            Spacer(),
            Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  radius: MediaQuery.of(context).size.width / 10,
                  lineWidth: 8.0,
                  percent: min(egg.hatchCounter / egg.hatchCount, 1),
                  backgroundColor: Colors.white,
                  progressColor: Color.fromARGB(120, 0, 0, 0),
                  circularStrokeCap: CircularStrokeCap.butt,
                ),
                Icon(Icons.egg, size: 60),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: stars,
            ),
            Spacer()
          ],
        ),
      )
    );
  }

  Widget _backButton() {
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
                const Icon(Icons.keyboard_arrow_left_rounded, color: Colors.white),
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