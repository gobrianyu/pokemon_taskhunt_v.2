import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/models/dex_db.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:pokemon_taskhunt_2/views/landing.dart';
import 'package:provider/provider.dart';

//喻晟

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]) // locks screen in portrait orientation
    .then((_) => runApp(const MainApp())
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light
      )
    );
    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            top: false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => AccountProvider(),
      child: Consumer<AccountProvider>(
        builder: (context, accountProvider, _) {
          return MaterialApp(
            theme: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.black, // Customize the cursor color globally
                selectionColor: const Color.fromARGB(255, 218, 218, 218), // Background color of selected text
                selectionHandleColor: Colors.transparent, // Color of the selection handles (teardrop)
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: SafeArea(top: false, child: Landing(_dexDB)),
            ),
          );
        },
      )
    );
  }
}