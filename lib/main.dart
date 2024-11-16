import 'package:budgetbuddy/components/appconfig.dart';
import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/widgets/filterwidget.dart';
import 'package:budgetbuddy/widgets/monthlypiechart.dart';
import 'package:budgetbuddy/widgets/monthlybarchart.dart';
import 'package:budgetbuddy/widgets/profileview.dart';
import 'package:budgetbuddy/widgets/transactionswidget.dart';
import 'package:flutter/material.dart';
import 'package:budgetbuddy/widgets/account_bar.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  // Initialize databaseFactory for desktop platforms
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    windowManager.setMinimumSize(const Size(1200,860));
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Appconfig appconfig = Appconfig();
  final dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetBuddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 58, 148, 183),
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // initialize data pipeline
  final Datadistributer datadistributer = Datadistributer();
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // get the key to the transaction widget state
  final GlobalKey<TransactionWidgetState> _transactionWidgetStateKey = GlobalKey<TransactionWidgetState>();
  final GlobalKey<ProfileViewState> _profileViewStateKey = GlobalKey<ProfileViewState>();
  final GlobalKey<FilterWidgetState> _filterWidgetStateKey = GlobalKey<FilterWidgetState>();

  void handleUpdate() {
    // trigger the widget to reload its state
    _transactionWidgetStateKey.currentState?.loadTransactions();
    _profileViewStateKey.currentState?.loadData();
    _filterWidgetStateKey.currentState?.loadData();
  }

  void handleFilter(String? year, String? month) {
    // trigger the widgets to reload their filters
    if (year != null && month != null) {
      _transactionWidgetStateKey.currentState?.applyFilters(year, month);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    AccountBar(newDataTrigger: () => handleUpdate(), datadistributer: widget.datadistributer),
                    ProfileView(key: _profileViewStateKey, datadistributer: widget.datadistributer)
                  ]
                ),
                Column(
                  children: [
                    FilterWidget(newFilterTrigger: (year, month) => handleFilter(year, month), datadistributer: widget.datadistributer),
                    TransactionWidget(key: _transactionWidgetStateKey, datadistributer: widget.datadistributer),
                    MonthlyBarChart()
                  ]
                ),
                MonthlyPieChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
