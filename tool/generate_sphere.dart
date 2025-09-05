import 'dart:convert';
import 'dart:io';

void main() {
  // ✅ Real Base64 content ng isang maliit na sphere.glb dapat dito
  const base64Sphere = """
<REAL_BASE64_DATA>
""";

  final bytes = base64Decode(base64Sphere.replaceAll("\n", ""));
  File("assets/sphere.glb").writeAsBytesSync(bytes);

  print("✅ sphere.glb generated at assets/sphere.glb");
}
