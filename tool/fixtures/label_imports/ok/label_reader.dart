// Fixture of tool/check_label_imports_test.sh: label code with no cloud
// import. A comment naming package:cloud_firestore/ does not count.
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../cellar/cellar_actions.dart';

final TextRecognizer recognizer = TextRecognizer();
const String note = "import 'package:firebase_storage/firebase_storage.dart'";
CellarActions? actions;
