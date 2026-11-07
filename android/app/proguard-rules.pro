# R8 rules of the app, added with u6-label-recognition.
#
# google_mlkit_text_recognition references the Chinese, Devanagari, Japanese
# and Korean recognizers as compileOnly dependencies. The app uses only the
# bundled Latin model (tech-stack-decisions.md), so those classes are never
# loaded; without these lines R8 stops the release build on the missing
# classes. Only these exact classes are silenced.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
