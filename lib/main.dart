import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/activity_provider.dart';
import 'providers/advice_provider.dart';
import 'providers/alert_provider.dart';
import 'providers/culture_provider.dart';
import 'screens/main_navigation.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  try {
    // Les rappels sont une fonctionnalité secondaire : si leur initialisation
    // échoue (service système de notifications indisponible sur certaines
    // machines desktop), l'application doit démarrer normalement quand même.
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('AgriSuivi: initialisation des notifications impossible ($e)');
  }
  runApp(const AgriSuiviApp());
}

class AgriSuiviApp extends StatelessWidget {
  const AgriSuiviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CultureProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => AdviceProvider()),
      ],
      child: MaterialApp(
        title: 'AgriSuivi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainNavigation(),
      ),
    );
  }
}
