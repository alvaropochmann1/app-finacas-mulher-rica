import 'package:flutter/material.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/notes_screen/notes_screen.dart';
import '../presentation/planning_screen/planning_screen.dart';
import '../presentation/add_transaction_screen/add_transaction_screen.dart';
import '../presentation/goals_screen/goals_screen.dart';
import '../presentation/transactions_screen/transactions_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String dashboard = '/dashboard-screen';
  static const String notes = '/notes-screen';
  static const String planning = '/planning-screen';
  static const String addTransaction = '/add-transaction-screen';
  static const String goals = '/goals-screen';
  static const String transactions = '/transactions-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const DashboardScreen(),
    dashboard: (context) => const DashboardScreen(),
    notes: (context) => const NotesScreen(),
    planning: (context) => const PlanningScreen(),
    addTransaction: (context) => const AddTransactionScreen(),
    goals: (context) => const GoalsScreen(),
    transactions: (context) => const TransactionsScreen(),
    // TODO: Add your other routes here
  };
}
