import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:taskmate/DBtest/task.dart';
import 'package:taskmate/object.dart';

// ️ 실제 프로젝트 ID로 교체
const String baseUrl =
    "BASE_URL";

String _kstDateKey([DateTime? d]) {
  final now = (d ?? DateTime.now()).toUtc().add(const Duration(hours: 9));
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

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

// meta.lastUpdated 어떤 형식이 와도 KST dateKey로 변환
String? _normalizeToKstDateKey(dynamic v) {
  if (v == null) return null;

  // 이미 YYYY-MM-DD면 그대로
  if (v is String && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) return v;

  DateTime? dt;

  // ISO 문자열
  if (v is String) {
    try {
      dt = DateTime.parse(v).toUtc();
    } catch (_) {}
  }

  // epoch (ms/s)
  if (dt == null && v is num) {
    final ms = v > 20000000000 ? v.toInt() : (v.toInt() * 1000);
    dt = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toUtc();
  }

  // DateTime
  if (dt == null && v is DateTime) dt = v.toUtc();

  if (dt == null) return null;
  return _kstDateKey(dt); // ← 이미 파일 상단에 존재하는 KST dateKey 유틸 사용
}

// 토큰 만료 대비 간단 재시도 헬퍼
Future<http.Response> _getWithRetry(Uri url) async {
  var r = await http.get(url, headers: await _authHeaders());
  if (r.statusCode == 401) {
    await FirebaseAuth.instance.currentUser!.getIdToken(true);
    r = await http.get(url, headers: await _authHeaders());
  }
  return r;
}

Future<http.Response> _postWithRetry(Uri url, String body) async {
  var r = await http.post(url, headers: await _authHeaders(), body: body);
  if (r.statusCode == 401) {
    await FirebaseAuth.instance.currentUser!.getIdToken(true);
    r = await http.post(url, headers: await _authHeaders(), body: body);
  }
  return r;
}

/// 서버 메타(lastUpdated)를 보고 날짜가 바뀌면 isChecked 전부 false로 초기화.
/// 단, "오늘 이미 제출했으면" 절대 초기화하지 않는다(제출한 날엔 체크 유지 보장).
Future<List<Map<String, dynamic>>> fetchRepeatListEnsured() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final todayKey = _kstDateKey();

  // 1) 반복리스트 읽기
  final readUrl = Uri.parse("$baseUrl/repeatList/read/$uid");
  final r = await _getWithRetry(readUrl);
  if (r.statusCode != 200) {
    throw Exception("repeatList read failed: ${r.statusCode} ${r.body}");
  }

  final obj = jsonDecode(r.body) as Map<String, dynamic>;
  final List<Map<String, dynamic>> rows = List<Map<String, dynamic>>.from(
    obj["data"] ?? [],
  );
  final meta = (obj["meta"] is Map)
      ? Map<String, dynamic>.from(obj["meta"])
      : {};
  final lastKey = _normalizeToKstDateKey(meta["lastUpdated"]); // ← 핵심: 정규화

  // 2) "오늘 제출 여부" 확인 → 제출했으면 어떤 경우에도 초기화 금지
  try {
    final daily = await readDailyWithMeta(todayKey);
    if (daily.submitted == true) {
      // meta가 오늘이 아니면 오늘로 바로 맞춰 동기화(체크는 건드리지 않음)
      if (lastKey != todayKey) {
        final saveUrl = Uri.parse("$baseUrl/repeatList/save/$uid");
        final body = jsonEncode({
          "tasks": rows,
          "meta": {"lastUpdated": todayKey},
        });
        await _postWithRetry(saveUrl, body);
      }
      return rows; // ✅ 제출한 날: 체크 유지
    }
  } catch (_) {
    // daily API 실패해도 계속 진행(보수적)
  }

  // 3) 제출 안 했고, 날짜가 다르면 오늘로 초기화
  if (lastKey == null || lastKey != todayKey) {
    final cleared = rows.map((e) => {...e, "isChecked": false}).toList();

    final saveUrl = Uri.parse("$baseUrl/repeatList/save/$uid");
    final body = jsonEncode({
      "tasks": cleared,
      "meta": {"lastUpdated": todayKey},
    });

    final saveResp = await _postWithRetry(saveUrl, body);
    if (saveResp.statusCode == 200) {
      return cleared;
    }
    // 저장 실패 시에도 최소 화면은 초기화된 상태로 노출
    return cleared;
  }

  // 4) 날짜 같으면 그대로 유지
  return rows;
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
      final items = data.map((e) => Item.fromMap(e)).toList();
      items.sort((a, b) => a.price.compareTo(b.price));
      return items;
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
      final items = data.map((e) => Item.fromMap(e)).toList();
      items.sort((a, b) => a.price.compareTo(b.price));
      return items;
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

Future<void> gameRunReward() async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final url = Uri.parse("$baseUrl/game/run/$uid");
    final r = await http.patch(url, headers: await _authHeaders());

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    } else {
      throw Exception("Failed to get reward: ${r.statusCode}, ${r.body}");
    }
  } catch (e) {
    throw Exception("Error updating pet: $e");
  }
}

Future<void> gameCleanReward() async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final url = Uri.parse("$baseUrl/game/clean/$uid");
    final r = await http.patch(url, headers: await _authHeaders());

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    } else {
      throw Exception("Failed to get reward: ${r.statusCode}, ${r.body}");
    }
  } catch (e) {
    throw Exception("Error updating pet: $e");
  }
}

Future<void> choosePet(String petName) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final url = Uri.parse("$baseUrl/users/$uid/nowPet");
    final r = await http.patch(
      url,
      headers: await _authHeaders(),
      body: json.encode({"petName": petName}),
    );

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    } else {
      throw Exception("Failed to change pet: ${r.statusCode}, ${r.body}");
    }
  } catch (e) {
    throw Exception("Error updating pet: $e");
  }
}
