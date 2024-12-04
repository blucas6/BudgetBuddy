//monthly pie chart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/widgets/monthlypiechart.dart';
import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('MonthlyPieChart Tests', () {
    Datadistributer datadistributer = Datadistributer();
    testWidgets('Renders title and pie chart', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyPieChart(datadistributer: datadistributer),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the title is displayed
      expect(find.text('Monthly Spending Analysis'), findsOneWidget);

      // Verify the PieChart widget is present
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('Displays correct pie chart sections and values',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyPieChart(datadistributer: datadistributer),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the PieChart widget is present
      final pieChartFinder = find.byType(PieChart);
      expect(pieChartFinder, findsOneWidget);

      // Retrieve the PieChart widget and access its data
      final PieChart pieChart = tester.widget(pieChartFinder);
      final PieChartData pieChartData = pieChart.data;

      // Verify the pie chart sections
      expect(pieChartData.sections.length, 3);

      // Verify the values in each section
      expect(pieChartData.sections[0].value, 50); // Necessary expenses
      expect(pieChartData.sections[1].value, 30); // Wants
      expect(pieChartData.sections[2].value, 20); // Savings
    });

    testWidgets('Renders pie chart sections with correct colors',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyPieChart(datadistributer: datadistributer),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that the sections of the pie chart are rendered with the correct colors
      final pieChart = tester.widget<PieChart>(find.byType(PieChart));
      final pieChartData = pieChart.data;

      expect(pieChartData.sections.length, 3);

      // Verify the colors of each section
      expect(pieChartData.sections[0].color, Colors.blue); // Necessary expenses
      expect(pieChartData.sections[1].color, Colors.orange); // Wants
      expect(pieChartData.sections[2].color, Colors.green); // Savings
    });
  });
}
