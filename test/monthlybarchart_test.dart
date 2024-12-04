//monthly bar chart
import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/widgets/yearlybarchart.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('MonthlyBarChart Tests', () {
    Datadistributer datadistributer = Datadistributer();
    testWidgets('Renders header, pie chart, and bar chart',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: YearlyBarChart(datadistributer: datadistributer),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the header text
      expect(find.text('Monthly Spending Analysis'), findsOneWidget);

      // Verify the pie chart placeholder
      expect(find.byIcon(Icons.pie_chart), findsOneWidget);
      expect(find.text('Pie Chart Placeholder'), findsOneWidget);

      // Verify the bar chart is rendered
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('Displays bar chart data correctly',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: YearlyBarChart(datadistributer: datadistributer),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the "Needs" bar is displayed
      expect(find.text('Needs'), findsOneWidget);

      // Verify the "Wants" bar is displayed
      expect(find.text('Wants'), findsOneWidget);

      // Verify the "Savings" bar is displayed
      expect(find.text('Savings'), findsOneWidget);
    });

    testWidgets('Interacts with the bar chart tooltip',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: YearlyBarChart(datadistributer: datadistributer),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Simulate a tap on the first bar (Needs)
      final barFinder = find.byType(BarChart);
      await tester.tap(barFinder);
      await tester.pumpAndSettle();

      // Verify tooltip for "Needs" is displayed (this requires implementation of touch handling in your actual widget)
      expect(find.textContaining('Needs'), findsOneWidget);
    });
  });
}
