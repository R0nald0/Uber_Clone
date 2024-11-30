import 'package:flutter/material.dart';
import 'package:uber/core/offline_database/impl/database_impl.dart';
import 'package:uber/core/offline_database/sql_connection.dart';

class UberCloneLifeCycle with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final database = SqlConnection();

    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        database.closeConnection();
        break;
    }

    super.didChangeAppLifecycleState(state);
  }
}
