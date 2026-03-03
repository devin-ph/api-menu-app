// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menu/main.dart';

void main() {
  testWidgets('Menu app shows bootstrap loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MenuApp());
    await tester.pump();

    expect(find.text('Đang khởi tạo ứng dụng...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 13));
  });
}
