import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:taskmate/DBtest/task.dart';
import '../object.dart';

// ️ 실제 프로젝트 ID로 교체
const String baseUrl =
    "BASE_URL";

Future<Map<String, String>> _authHeaders() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("로그인 필요");
  final token = await user.getIdToken();
  return {"Authorization": "Bearer $token", "Content-Type": "application/json"};
}

// ======================= 반복 리스트 =======================
Future<List<Map<String, dynamic>>> fetchRepeatList() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/repeatList/read/$uid");
  final r = await http.get(url, headers: await _authHeaders());

  if (r.statusCode == 401) {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken(true);
    final r2 = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
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

Future<void> checkRepeatItem(String todoId, bool value) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/repeatList/check/$uid/$todoId");
  final body = jsonEncode({"todoCheck": value});
  final r = await http.patch(url, headers: await _authHeaders(), body: body);
  if (r.statusCode != 200) {
    throw Exception("repeat check failed: ${r.statusCode} ${r.body}");
  }
}

Future<void> saveRepeatList(List<Task> tasks) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/repeatList/save/$uid");
  final headers = await _authHeaders();
  final body = jsonEncode({"tasks": tasks.map((t) => t.toJson()).toList()});

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
  if (r.statusCode != 200) {
    throw Exception("add failed: ${r.statusCode} ${r.body}");
  }
  return jsonDecode(r.body) as Map<String, dynamic>;
}

// ======================= dailyTasks =======================

// ✔ submitted/lastSubmit까지 함께 읽어오는 모델/함수 추가
class DailyRead {
  final List<Task> tasks;
  final bool submitted;
  final String? lastSubmit;
  DailyRead({required this.tasks, required this.submitted, this.lastSubmit});
}

Future<DailyRead> readDailyWithMeta(String dateKey) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/daily/read/$uid/$dateKey");
  final r = await http.get(url, headers: await _authHeaders());
  if (r.statusCode != 200) {
    throw Exception("daily read failed: ${r.statusCode} ${r.body}");
  }
  final obj = jsonDecode(r.body) as Map<String, dynamic>;
  final tasks = (obj["tasks"] as List)
      .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
      .toList();
  final submitted = (obj["submitted"] ?? false) as bool;
  final lastSubmit = obj["lastSubmit"] as String?;
  return DailyRead(tasks: tasks, submitted: submitted, lastSubmit: lastSubmit);
}

// (참고) 기존 fetchDaily가 필요한 다른 화면이 있으면 남겨둡니다.
Future<List<Task>> fetchDaily(String dateKey) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/daily/read/$uid/$dateKey");
  final r = await http.get(url, headers: await _authHeaders());
  if (r.statusCode != 200) {
    throw Exception("daily read failed: ${r.statusCode} ${r.body}");
  }
  final obj = jsonDecode(r.body) as Map<String, dynamic>;
  final tasks = (obj["tasks"] as List)
      .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
      .toList();
  return tasks;
}

Future<void> saveDaily(String dateKey, List<Task> tasks) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/daily/save/$uid/$dateKey");
  final body = jsonEncode({"tasks": tasks.map((t) => t.toJson()).toList()});
  final r = await http.post(url, headers: await _authHeaders(), body: body);
  if (r.statusCode != 200) {
    throw Exception("daily save failed: ${r.statusCode} ${r.body}");
  }
}

Future<void> updateDailyItem(
  String dateKey,
  String todoId, {
  String? text,
  int? point,
}) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/daily/update/$uid/$dateKey/$todoId");
  final body = jsonEncode({
    if (text != null) "todoText": text,
    if (point != null) "todoPoint": point,
  });
  final r = await http.patch(url, headers: await _authHeaders(), body: body);
  if (r.statusCode != 200) {
    throw Exception("daily update failed: ${r.statusCode} ${r.body}");
  }
}

Future<void> checkDailyItem(String dateKey, String todoId, bool value) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/daily/check/$uid/$dateKey/$todoId");
  final body = jsonEncode({"todoCheck": value});
  final r = await http.patch(url, headers: await _authHeaders(), body: body);
  if (r.statusCode != 200) {
    throw Exception("daily check failed: ${r.statusCode} ${r.body}");
  }
}

Future<void> deleteDailyItem(String dateKey, String todoId) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/daily/delete/$uid/$dateKey/$todoId");
  final r = await http.delete(url, headers: await _authHeaders());
  if (r.statusCode != 200) {
    throw Exception("daily delete failed: ${r.statusCode} ${r.body}");
  }
}

Future<void> markDailySubmitted(String dateKey) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final url = Uri.parse("$baseUrl/daily/submit/$uid/$dateKey");
  final r = await http.post(url, headers: await _authHeaders());
  if (r.statusCode != 200) {
    throw Exception("daily submit failed: ${r.statusCode} ${r.body}");
  }
}

// ======================= 펫 =======================
Future<void> useItem(String itemName) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final url = Uri.parse("$baseUrl/users/$uid/items/$itemName");
    final r = await http.patch(url, headers: await _authHeaders());

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    } else {
      throw Exception("Failed to update inventory: ${r.statusCode}, ${r.body}");
    }
  } catch (e) {
    throw Exception("Error updating inventory: $e");
  }
}

Future<void> usePlaceItem(String itemName) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final url = Uri.parse("$baseUrl/users/$uid/items/$itemName/set");
    final newPlace = "assets/images/$itemName.png";
    final r = await http.patch(
      url,
      headers: await _authHeaders(),
      body: json.encode({"placeID": newPlace}),
    );

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    } else {
      throw Exception("Failed to update place: ${r.statusCode}, ${r.body}");
    }
  } catch (e) {
    throw Exception("Error updating place: $e");
  }
}

Future<void> useStyleItem(String itemName) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final url = Uri.parse("$baseUrl/users/$uid/items/$itemName/style");
    final r = await http.patch(
      url,
      headers: await _authHeaders(),
      body: json.encode({"styleID": itemName}),
    );

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    } else {
      throw Exception("Failed to update style: ${r.statusCode}, ${r.body}");
    }
  } catch (e) {
    throw Exception("Error updating style: $e");
  }
}

Future<List<Item>> readItemList(int category) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final url = Uri.parse("$baseUrl/users/$uid/items?itemCategory=$category");
    final r = await http.get(url, headers: await _authHeaders());

    if (r.statusCode == 200) {
      final data = jsonDecode(r.body)['data'] as List;
      return data.map((e) => Item.fromMap(e)).toList();
    } else {
      return []; // 404나 오류 시 빈 리스트 반환
    }
  } catch (e) {
    return []; // 네트워크 오류 시도 빈 리스트
  }
}

Future<List<Item>> readShopList(int category) async {
  try {
    final url = Uri.parse("$baseUrl/shop/items?category=$category");
    final r = await http.get(url, headers: await _authHeaders());

    if (r.statusCode == 200) {
      final data = jsonDecode(r.body)['data'] as List;
      return data.map((e) => Item.fromMap(e)).toList();
    } else {
      return []; // 404나 오류 시 빈 리스트 반환
    }
  } catch (e) {
    return []; // 네트워크 오류 시도 빈 리스트
  }
}

Future<void> buyItem(String itemName) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final url = Uri.parse("$baseUrl/shop/items/$uid");
    final r = await http.post(
      url,
      headers: await _authHeaders(),
      body: json.encode({"itemName": itemName}),
    );

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    } else {
      throw Exception("Failed to buy item: ${r.statusCode}, ${r.body}");
    }
  } catch (e) {
    throw Exception("Error updating inventory: $e");
  }
}
