import 'package:budgetbuddy/config/appconfig.dart';
import 'package:budgetbuddy/widgets/monthlypiechart.dart';
import 'package:budgetbuddy/widgets/transactionswidget.dart';
import 'package:flutter/material.dart';
import 'package:budgetbuddy/widgets/account_bar.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  // Initialize databaseFactory for desktop platforms
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
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

  @override
  void initState() {
    super.initState();
    testDatabase(); // Call the test function when the app starts
  }

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
      home: const MyHomePage(title: 'Home'),
    );
  }

  // Function to test database insert and print all data
  Future<void> testDatabase() async {
    final dbService = DatabaseService.instance;

    // Add a new transaction
    bool isSuccess = await dbService.addTransaction('Sample Transaction');
    if (isSuccess) {
      print('Transaction added successfully.');
    } else {
      print('Failed to add transaction.');
    }

    // Print all transactions to verify data storage
    await dbService.printAllTransactions();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Column(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountBar(),
                TransactionWidget(),
                MonthlyPieChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
