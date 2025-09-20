import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:taskmate/DBtest/task.dart';  // ✅ Task.toJson() 사용하려면 필요

// ️ 실제 프로젝트 ID로 교체
const String baseUrl = "BASE_URL";

Future<Map<String, String>> _authHeaders() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("로그인 필요");
  final token = await user.getIdToken();
  return {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };
}

// 반복 리스트 읽기 (서버 API → List<Map>)
Future<List<Map<String, dynamic>>> fetchRepeatList() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/repeatList/read/$uid");
  final r = await http.get(url, headers: await _authHeaders());

  if (r.statusCode == 401) {
    // 토큰 강제갱신 후 1회 재시도
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

// 반복 리스트 저장 (화면의 리스트를 '인자로' 받기)
Future<void> saveRepeatList(List<Task> tasks) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/repeatList/save/$uid");
  final headers = await _authHeaders();
  final body = jsonEncode({
    "tasks": tasks.map((t) => t.toJson()).toList(),
  });

  final r = await http.post(url, headers: headers, body: body);
  if (r.statusCode != 200) {
    throw Exception("repeatList save failed: ${r.statusCode} ${r.body}");
  }
}

// 노션 스펙 호환: 할 일 추가
Future<Map<String, dynamic>> addDailyLikeTask({
  required String text,
  required int point,
  bool checked = false,
}) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/dailyList/add/$uid");
  final r = await http.post(
    url,
    headers: await _authHeaders(),
    body: jsonEncode({
      "todoText": text,
      "todoCheck": checked,
      "todoPoint": point,
    }),
  );
  // 상태 확인 로그
  
  print('[API] add status=${r.statusCode} body=${r.body}');
  if (r.statusCode != 200) {
    throw Exception("add failed: ${r.statusCode} ${r.body}");
  }
  return jsonDecode(r.body) as Map<String, dynamic>;
}
