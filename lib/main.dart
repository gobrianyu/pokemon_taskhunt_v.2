import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/models/dex_db.dart';
import 'package:pokemon_taskhunt_2/views/landing.dart';

//喻晟

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]) // locks screen in portrait orientation
    .then((value) => runApp(const MainApp())
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  late final DexDB _dexDB;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDexDB();
  }

  Future<void> _loadDexDB() async {
    const dataPath = 'assets/dex.json';
    final loadedDB = DexDB.initializeFromJson(await rootBundle.loadString(dataPath));
    setState(() {
      _dexDB = loadedDB;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Landing(_dexDB),
      ),
    );
  }
}