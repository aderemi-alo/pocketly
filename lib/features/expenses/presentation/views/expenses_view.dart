import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';
import 'package:go_router/go_router.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.addExpense);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
