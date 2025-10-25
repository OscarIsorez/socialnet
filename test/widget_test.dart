import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socialnet/main.dart';
import 'package:socialnet/presentation/routes/app_router.dart';

void main() {
  testWidgets('RedemtonApp bootstraps with splash route', (tester) async {
    await tester.pumpWidget(const RedemtonApp());

    final materialAppFinder = find.byType(MaterialApp);
    expect(materialAppFinder, findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(materialAppFinder);
    expect(materialApp.initialRoute, equals(AppRouter.splash));
    expect(materialApp.onGenerateRoute, isNotNull);
  });
}
