import 'package:devtask/presentation/widgets/floating_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const items = [
    FloatingNavItem(
      key: Key('nav-a'),
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    FloatingNavItem(
      key: Key('nav-b'),
      icon: Icons.list_outlined,
      selectedIcon: Icons.list,
      label: 'List',
    ),
    FloatingNavItem(
      key: Key('nav-c'),
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: 'History',
    ),
  ];

  Future<List<int>> pump(WidgetTester tester, {int selected = 0}) async {
    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: FloatingNavBar(
            items: items,
            selectedIndex: selected,
            onSelected: taps.add,
            onAdd: () => taps.add(-1),
            addTooltip: 'Add',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return taps;
  }

  testWidgets('mostra o nome só na aba selecionada', (tester) async {
    await pump(tester, selected: 1);

    expect(find.text('List'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('History'), findsNothing);
    expect(find.byIcon(Icons.list), findsOneWidget); // ícone de selecionado
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });

  testWidgets('avisa os toques nas abas e no botão +', (tester) async {
    final taps = await pump(tester);

    await tester.tap(find.byKey(const Key('nav-c')));
    await tester.tap(find.byKey(const Key('add-task')));

    expect(taps, [2, -1]);
    expect(find.byTooltip('Add'), findsOneWidget);
  });

  testWidgets('as abas funcionam com leitor de tela', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    expect(
      tester.getSemantics(find.byKey(const Key('nav-b'))),
      matchesSemantics(label: 'List', isButton: true, hasSelectedState: true),
    );
    handle.dispose();
  });
}
