import 'package:usage_stats/usage_stats.dart';

/// Vraća listu svih korištenih aplikacija u poslednjih 10 minuta
Future<List<String>> getRecentlyUsedApps() async {
  try {
    // Dobija trenutno vrijeme
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(minutes: 10));
    
    // Dobija usage stats za poslednjih 10 minuta
    List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
      startDate,
      endDate,
    );
    
    // Izvlači imena paketa
    return usageStats.map((info) => info.packageName ?? '').where((name) => name.isNotEmpty).toList();
  } catch (e) {
    // Greška pri dohvatanju aplikacija
    return [];
  }
}

/// Lista popularnih betting i web browser aplikacija za praćenje
const List<String> defaultBettingApps = [ 
  'mozzart',
  'meridian',
  'maxbet',
  'bet365',
  'unibet',
  'betfair',
  'sportingbet',
  '1xbet',
  'pinnacle',
  'williamhill',
];

const List<String> defaultWebBrowsers = [
  'chrome',
  'firefox',
  'safari',
  'edge',
  'opera',
  'brave',
  'sbrowser',  // Samsung Internet
  'duckduckgo',
  'com.android.chrome',
  'org.mozilla.firefox',
  'com.sec.android.app.sbrowser',
  'com.duckduckgo.mobile.android',
];

/// Proverava da li je neka od betting aplikacija ili web browser korištena u poslednjih 10min
Future<bool> wasBettingOrWebAppUsedRecently({
  List<String>? bettingApps,
  List<String>? webBrowsers,
}) async {
  final recentApps = await getRecentlyUsedApps();
  
  final appsToCheck = [
    ...(bettingApps ?? defaultBettingApps),
    ...(webBrowsers ?? defaultWebBrowsers),
  ];
  
  for (String app in recentApps) {
    if (appsToCheck.any((checkApp) => app.toLowerCase().contains(checkApp.toLowerCase()))) {
      return true;
    }
  }
  
  return false;
}

