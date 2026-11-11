import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Opens the persistent Drift connection across native and web platforms.
QueryExecutor openLumiConnection() {
  return driftDatabase(
    name: 'lumi_db',

  );
}
