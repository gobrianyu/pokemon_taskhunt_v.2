import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/models/types.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:provider/provider.dart';

class PartyDetails extends StatefulWidget {
  final Pokemon mon;
  const PartyDetails({required this.mon, super.key});

  @override
  State<PartyDetails> createState() => _PartyDetailsState();
}

class _PartyDetailsState extends State<PartyDetails> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          body: _fullScaffold(),
          bottomNavigationBar: _backButton()
        );
      }
    );
  }

  Widget _fullScaffold() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 40),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 10),
            child: Row(
              children: [
                Icon(Icons.catching_pokemon, size: 20),
                SizedBox(width: 5),
                Text(widget.mon.species, style: TextStyle(fontSize: 16)),
                widget.mon.gender == -1 ? const SizedBox() : Icon(widget.mon.gender == 0 ? Icons.male : Icons.female, size: 17),
                Spacer(),
                Text('Lv.${widget.mon.level}', style: TextStyle(fontSize: 16))
              ]
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            flex: 3,
            child: Image(image: AssetImage(widget.mon.imageAsset))
          ),
          Expanded(
            flex: 8,
            child: _infoPanel(),
          )
        ],
      ),
    );
  }

  Container _infoPanel() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15)
        )
      ),
      child: Column(
        children: [
          _tags(),
          _expInfo(),
          SizedBox(height: 30),
          _heldItem(),
          // SizedBox(height: 50),
          // Expanded(flex: 1, child: SizedBox()),
          Expanded(flex: 2, child: StatSpreadHexagon(width: 200, stats: widget.mon.getStats(), maxStats: widget.mon.maxStats(),)),
          SizedBox(height: 70)
        ],
      )
    );
  }

  Widget _expInfo() {
    int lvlProgress = (widget.mon.exp / widget.mon.nextExpCap() * 1024).round();
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Row(
            children: [
              Text('Exp. Points: ${widget.mon.totalExp()}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              Spacer(),
              widget.mon.level >= 100 ? SizedBox() : Text('${widget.mon.nextExpCap() - widget.mon.exp} Exp. Points until next level', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w300), overflow: TextOverflow.ellipsis,)
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(6)
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: widget.mon.level == 100 ? 1 : lvlProgress,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border(bottom: BorderSide(), top: BorderSide())
                      ),
                    ),
                  ),
                  Expanded(
                    flex: widget.mon.level == 100 ? 0 : 1024 - lvlProgress,
                    child: SizedBox()
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }

  Widget _tags() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(4)
          ),
          child: Text(
            widget.mon.key.round() > 999 ? 'No. ${widget.mon.key.round()}'
              : widget.mon.key.round() > 99 ? 'No. 0${widget.mon.key.round()}'
                : widget.mon.key.round() > 9 ? 'No. 00${widget.mon.key.round()}'
                  : 'No. 000${widget.mon.key.round()}'
          )
        ),
        Container(
          margin: EdgeInsets.only(left: 5),
          padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(4)
          ),
          child: Text(widget.mon.speciesExtended)
        ),
        Spacer(),
        ..._typeTags()
      ]
    );
  }

  Widget _heldItem() {
    return Container(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(), bottom: BorderSide())
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(top: 3, bottom: 3),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all()
              ),
              child: Icon(Icons.add) // TODO: variable held items
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.mon.heldItem == null ? 'No Held Item' : 'Held Item: ${widget.mon.heldItem!.name}', style: TextStyle(fontSize: 13)),
                widget.mon.heldItem == null ? SizedBox() : Text(widget.mon.heldItem!.description, softWrap: true, style: TextStyle(fontSize: 11.5))
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _typeTags() {
    List<Widget> tags = [];
    for (Types type in widget.mon.types) {
      tags.add(
        Container(
          margin: EdgeInsets.only(left: 5),
          padding: EdgeInsets.only(left: 7, right: 7, top: 3, bottom: 3),
          decoration: BoxDecoration(
            // border: Border.all(),
            borderRadius: BorderRadius.circular(4),
            color: type.colour
          ),
          child: Text(type.type, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }
    return tags;
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

class Labels extends StatefulWidget {
  const Labels({required this.stats, required this.radius, required this.diameter, super.key});

  final double radius, diameter;
  final Stats stats;

  @override
  _LabelsState createState() => _LabelsState();
}

class _LabelsState extends State<Labels> {
  Size? size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          size = renderBox.size;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 9.5,
        );
    final textStyleBold = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        );
    const textAlign = TextAlign.center;

    if (size == null) {
      return Container(); // Return an empty container until size is available
    }

    final center = Offset(size!.width / 2, size!.height / 2);

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 / 12) + center.dx + 16,
              widget.radius * sin(pi * 2 / 12) + center.dy + 5,
            ),
            width: 50,
            height: 32,
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Def', textAlign: textAlign, style: textStyle),
                Text(widget.stats.def.toString(), textAlign: textAlign, style: textStyleBold),
              ],
            ),
          ),
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 / 4) + center.dx,
              widget.radius * sin(pi * 2 / 4) + center.dy + 18,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              children: [
                Text('Speed', textAlign: textAlign, style: textStyle),
                Text(widget.stats.speed.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 * 5 / 12) + center.dx - 22,
              widget.radius * sin(pi * 2 * 5 / 12) + center.dy + 5,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Sp. Def', textAlign: textAlign, style: textStyle),
                Text(widget.stats.spDef.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 * 7 / 12) + center.dx - 20,
              widget.radius * sin(pi * 2 * 7 / 12) + center.dy - 5,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Sp.Atk', textAlign: textAlign, style: textStyle),
                Text(widget.stats.spAtk.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 2 * 3 / 4) + center.dx,
              widget.radius * sin(pi * 2 * 3 / 4) + center.dy - 15,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              children: [
                Text('HP', textAlign: textAlign, style: textStyle),
                Text(widget.stats.hp.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(
              widget.radius * cos(pi * 22 / 12) + center.dx + 16,
              widget.radius * sin(pi * 22 / 12) + center.dy - 5,
            ),
            width: 50,
            height: 32
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Atk', textAlign: textAlign, style: textStyle),
                Text(widget.stats.atk.toString(), textAlign: textAlign, style: textStyleBold)
              ]
            )
          )
        )
      ]
    );
  }
}

class StatSpreadHexagon extends StatelessWidget {
  final double width;
  final Stats stats, maxStats;

  const StatSpreadHexagon({required this.width, required this.stats, required this.maxStats, super.key});

  double get diameter => width - 100;
  double get radius => diameter / 2;

  List<double> getMultipliers() {
    List<double> multipliers = [];
    multipliers.add(min(stats.def / maxStats.def, 1));
    multipliers.add(min(stats.speed / maxStats.speed, 1));
    multipliers.add(min(stats.spDef / maxStats.spDef, 1));
    multipliers.add(min(stats.spAtk / maxStats.spAtk, 1));
    multipliers.add(min(stats.hp / maxStats.hp, 1));
    multipliers.add(min(stats.atk / maxStats.atk, 1));
    return multipliers;
  } 

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Labels(
            radius: radius,
            diameter: diameter,
            stats: stats,
          ),
          CustomPaint(painter: HexagonPainter(radius: radius)),
          ClipPath(
            clipper: HexagonClipper(radius: radius, multipliers: getMultipliers()),
            child: SizedBox(
              width: diameter, 
              height: diameter,
              child: ColoredBox(
                color: Colors.blue.withOpacity(0.4)
              )
            )
          )
        ]
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  final double radius;
  final List<double> multipliers;

  HexagonClipper({required this.radius, required this.multipliers});

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.width / 2);
    final Path path = Path();
    
    final angleMul = [1, 3, 5, 7, 9, 11];
    path.addPolygon(
      [
        for (int i = 0; i < 6; i++)
          Offset(
            radius * multipliers[i] * cos(pi * 2 * angleMul[i] / 12) + center.dx,
            radius * multipliers[i] * sin(pi * 2 * angleMul[i] / 12) + center.dy,
          ),
      ],
      true,
    );
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

}

class HexagonPainter extends CustomPainter {
  final double radius;
  
  HexagonPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    Paint borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1.2;
    Paint innerPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Colors.black54
      ..strokeWidth = 0.8;

    final center = Offset(size.width / 2, size.width / 2);
    final angles = [1, 3, 5, 7, 9, 11, 1];
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(
          radius * cos(pi * 2 * angles[i] / 12) + center.dx,
          radius * sin(pi * 2 * angles[i] / 12) + center.dy,
        ),
        Offset(
          radius * cos(pi * 2 * angles[i + 1] / 12) + center.dx,
          radius * sin(pi * 2 * angles[i + 1] / 12) + center.dy,
        ),
        borderPaint,
      );
    }
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(
          radius * cos(pi * 2 * angles[i] / 12) + center.dx,
          radius * sin(pi * 2 * angles[i] / 12) + center.dy,
        ),
        Offset(
          radius * cos(pi * 2 * angles[i + 3] / 12) + center.dx,
          radius * sin(pi * 2 * angles[i + 3] / 12) + center.dy,
        ),
        innerPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}