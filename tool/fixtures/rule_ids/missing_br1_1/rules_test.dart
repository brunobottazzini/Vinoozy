// Fixture of tool/check_rule_ids_test.sh: BR1.1 is never a test name. BR1.10
// is, and must not count as BR1.1; BR1.1 in this comment does not count.
void main() {
  test('BR1.10 is the tenth rule, not the first', () {
    // BR1.1 in a test body does not count either.
  });
  test('BR1.2 present', () {});
  testWidgets('BR1.3 present', (tester) async {});
}
