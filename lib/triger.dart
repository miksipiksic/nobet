int checkTrigger({
  required double distanceInMeters,
  required bool usedBettingAppRecently,
  required int currentHour,
  required int criticalPeriodStart,
  required int criticalPeriodEnd,
}) {
  // Vraća 1 ako je korištena betting app u poslednjih 5min
  if (usedBettingAppRecently) {
    return 1;
  }

  // Vraća 1 ako je udaljenost manja od 10m VAN kritičnog perioda
  if (distanceInMeters < 10 && (currentHour < criticalPeriodStart || currentHour > criticalPeriodEnd)) {
    return 1;
  }
  
  // Vraća 1 ako je udaljenost manja od 5m U kritičnom periodu
  if (distanceInMeters < 5 && (currentHour >= criticalPeriodStart && currentHour <= criticalPeriodEnd)) {
    return 1;
  }

  // Vraća 1 ako je trenutno vrijeme u kritičnom periodu
  if (currentHour >= criticalPeriodStart && currentHour <= criticalPeriodEnd) {
    return 1;
  }

  return 0;
}
