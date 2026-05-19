import 'package:flutter_test/flutter_test.dart';
import 'package:src_cloud_mobile/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SrcCloudApp());
    await tester.pump();
    expect(find.byType(SrcCloudApp), findsOneWidget);
  });
}
