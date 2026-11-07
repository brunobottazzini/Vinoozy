// Fixture of tool/check_rule_ids_test.sh: every ID from BR1.1 to BR1.3 is in
// a test name. Not compiled (analysis_options.yaml excludes tool/fixtures/).
void main() {
  group('BR1.1 a group', () {
    test('BR1.2 a test', () {});
  });

  testWidgets(
    'a widget test '
    'BR1.3 named over two literals',
    (tester) async {},
  );
}
