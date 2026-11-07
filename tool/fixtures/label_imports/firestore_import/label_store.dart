// Fixture of tool/check_label_imports_test.sh: a label file that reaches
// Firestore directly, which the check must refuse.
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
