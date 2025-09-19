import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "https://asia-northeast3-<PROJECT_ID>.cloudfunctions.net/api";

Future<Map<String, String>> _authHeaders() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("로그인 필요");
  final token = await user.getIdToken();
  return {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };
}

Future<List<Map<String, dynamic>>> fetchRepeatList() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/repeatList/read/$uid");
  final r = await http.get(url, headers: await _authHeaders());
  if (r.statusCode == 401) {
    // 토큰 강제 갱신 후 1회 재시도 패턴 (선택)
    final token = await FirebaseAuth.instance.currentUser!.getIdToken(true);
    final r2 = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });
    if (r2.statusCode != 200) {
      throw Exception("repeatList read failed: ${r2.statusCode} ${r2.body}");
    }
    return List<Map<String, dynamic>>.from(jsonDecode(r2.body)["data"] ?? []);
  }
  if (r.statusCode != 200) {
    throw Exception("repeatList read failed: ${r.statusCode} ${r.body}");
  }
  return List<Map<String, dynamic>>.from(jsonDecode(r.body)["data"] ?? []);
}
