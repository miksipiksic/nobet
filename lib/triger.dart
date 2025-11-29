int checkTrigger({
  required double distanceInMeters,
  required bool usedBettingAppRecently,
  required int currentHour,
  required int criticalPeriodStart,
  required int criticalPeriodEnd,
}) {
  // Vraća 1 ako je udaljenost manja od 10m
  if (distanceInMeters < 10 && (currentHour > criticalPeriodEnd + 1 || currentHour < criticalPeriodStart - 1)) {
    return 1;
  }
  if (distanceInMeters < 5 && (currentHour < criticalPeriodEnd + 1 && currentHour > criticalPeriodStart - 1)) {
    return 1;
  }

  // Vraća 1 ako je korištena betting app u poslednjih 5min
  if (usedBettingAppRecently) {
    return 1;
  }

  // Vraća 1 ako je trenutno vrijeme u kritičnom periodu
  if (currentHour >= criticalPeriodStart && currentHour <= criticalPeriodEnd) {
    return 1;
  }

  return 0;
}
