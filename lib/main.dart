import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';
import 'package:pokemon_taskhunt_2/providers/dex_db_provider.dart';
import 'package:pokemon_taskhunt_2/providers/moves_db_provider.dart';
import 'package:pokemon_taskhunt_2/providers/moves_map_db_provider.dart';
import 'package:pokemon_taskhunt_2/views/landing.dart';
import 'package:provider/provider.dart';

//喻晟

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])  // locks screen in portrait orientation
    .then((_) => runApp(const MainApp())
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light
      )
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => DexDBProvider()),
        ChangeNotifierProvider(create: (_) => MovesDBProvider()),
        ChangeNotifierProvider(create: (_) => MovesMapDBProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black,  // Customize the cursor color globally
            selectionColor: Color.fromARGB(255, 218, 218, 218),  // Background color of selected text
            selectionHandleColor: Colors.transparent,  // Color of the selection handles (teardrop)
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: Consumer4<DexDBProvider, MovesDBProvider, MovesMapDBProvider, AccountProvider>(
          builder: (context, dexProvider, movesProvider, movesMapProvider, accProvider, _) {
            if (dexProvider.isLoading || movesProvider.isLoading || movesMapProvider.isLoading) {
              return const Scaffold(
                resizeToAvoidBottomInset: false,
                body: SafeArea(
                  top: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            return Scaffold(
              body: SafeArea(top: false, child: Landing()),
            );
          }
        ),
      ),
    );
  }
}