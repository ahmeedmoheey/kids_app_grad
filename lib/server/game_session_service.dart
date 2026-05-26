import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/api_constants.dart';

class GameSessionService {
  static final GameSessionService _instance = GameSessionService._internal();
  factory GameSessionService() => _instance;
  GameSessionService._internal();

  List<dynamic>? _games;
  static const Map<String, List<String>> _gameAliases = {
    'find-items': ['find-items', 'find items', 'finditems'],
    'sequence-game': ['sequence-game', 'sequence game', 'sequence'],
    'visual-game': ['visual-game', 'visual game'],
    'shape-match': ['shape-match', 'shape match', 'shape matching'],
    'animal-match': ['animal-match', 'animal match', 'animal matching'],
  };

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('child_token') ?? prefs.getString('token');
  }

  String _normalizeGameKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('_', '-')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  bool _matchesGameKey(String backendValue, String requestedSlug) {
    final normalizedBackend = _normalizeGameKey(backendValue);
    final normalizedRequested = _normalizeGameKey(requestedSlug);
    final aliases = _gameAliases[normalizedRequested] ?? [normalizedRequested];

    return aliases.any((alias) => normalizedBackend == _normalizeGameKey(alias));
  }

  String _availableGamesSummary() {
    if (_games == null || _games!.isEmpty) return '[]';

    final entries = _games!
        .whereType<Map>()
        .map((game) {
          final id = game['id']?.toString() ?? '?';
          final slug = game['slug']?.toString() ?? '';
          final name = game['name']?.toString() ?? '';
          return "{id:$id, slug:'$slug', name:'$name'}";
        })
        .toList();

    return entries.isEmpty ? '[]' : entries.join(', ');
  }

  Future<List<dynamic>> fetchGames({bool forceRefresh = false}) async {
    if (!forceRefresh && _games != null && _games!.isNotEmpty) {
      return _games!;
    }

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        debugPrint(">>> [GAME_SERVICE] Missing child token while fetching games.");
        return _games ?? [];
      }

      final url = ApiConstants.listGames;
      debugPrint(">>> [GET] $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _games = data;
        } else if (data['games'] != null) {
          _games = data['games'];
        }
        debugPrint(">>> [GAME_SERVICE] Successfully fetched ${_games?.length} games");
        debugPrint(">>> [GAME_SERVICE] Available games: ${_availableGamesSummary()}");
      } else {
        debugPrint(">>> [GAME_SERVICE] Failed to fetch games: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(">>> [GAME_SERVICE] Error fetching games: $e");
    }

    return _games ?? [];
  }

  int? getGameIdBySlug(String gameSlug) {
    if (_games == null) return null;
    try {
      final game = _games!.firstWhere(
            (g) {
          if (g is! Map) return false;
          final slug = g['slug']?.toString() ?? '';
          final name = g['name']?.toString() ?? '';
          return _matchesGameKey(slug, gameSlug) || _matchesGameKey(name, gameSlug);
        },
        orElse: () => null,
      );
      if (game == null) {
        debugPrint(">>> [GAME_SERVICE] Game with slug '$gameSlug' NOT FOUND in database.");
        debugPrint(">>> [GAME_SERVICE] Requested aliases: ${_gameAliases[_normalizeGameKey(gameSlug)] ?? [_normalizeGameKey(gameSlug)]}");
        debugPrint(">>> [GAME_SERVICE] Available games: ${_availableGamesSummary()}");
      }
      return game != null ? (int.tryParse(game['id'].toString())) : null;
    } catch (e) {
      debugPrint(">>> [GAME_SERVICE] Error resolving game '$gameSlug': $e");
      return null;
    }
  }

  Future<int?> startSessionBySlug({
    required String gameSlug,
    required int level,
    String difficulty = "Easy",
  }) async {
    await fetchGames();
    final gameId = getGameIdBySlug(gameSlug);
    if (gameId == null) {
      debugPrint(">>> [SESSION START] Unable to resolve game id for '$gameSlug'.");
      return null;
    }

    return startSession(
      gameId: gameId,
      level: level,
      difficulty: difficulty,
    );
  }

  Future<int?> startSession({
    required int gameId,
    required int level,
    String difficulty = "Easy",
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        debugPrint(">>> [SESSION START] Missing child token.");
        return null;
      }

      final url = ApiConstants.sessionStart;
      final body = {
        'game_id': gameId,
        'level': level,
        'difficulty_level': difficulty,
      };

      debugPrint(">>> [POST] $url Body: $body");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final id = data['session']?['id'] ?? data['id'];
        return id != null ? int.tryParse(id.toString()) : null;
      } else {
        debugPrint(">>> [SESSION START] FAILED: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint(">>> [SESSION START] EXCEPTION: $e");
    }
    return null;
  }

  Future<void> submitTrial({
    required int sessionId,
    required int trialNumber,
    required String taskType,
    required String targetType,
    required String promptValue,
    required String selectedValue,
    required int stimulusCount,
    required int reactionTimeMs,
    required bool correct,
    required int errors,
    required int missedTargets,
    required int durationSec,
    Map<String, dynamic>? metadata,
  }) async {
    if (sessionId <= 0) return;
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        debugPrint(">>> [TRIAL SUBMIT] Missing child token.");
        return;
      }

      final url = ApiConstants.sessionTrial(sessionId);
      final body = {
        'trial_number': trialNumber,
        'task_type': taskType,
        'target_type': targetType,
        'prompt_value': promptValue,
        'selected_value': selectedValue,
        'stimulus_count': stimulusCount,
        'reaction_time_ms': reactionTimeMs,
        'correct': correct,
        'errors': errors,
        'missed_targets': missedTargets,
        'duration_sec': durationSec <= 0 ? 1 : durationSec,
        'metadata': {
          'source': 'flutter',
          ...?metadata,
        },
      };

      debugPrint(">>> [POST] $url Body: $body");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        debugPrint(">>> [TRIAL SUBMIT] FAILED: ${response.body}");
      }
    } catch (e) {
      debugPrint(">>> [TRIAL SUBMIT] EXCEPTION: $e");
    }
  }

  Future<Map<String, dynamic>?> endSession({
    required int sessionId,
    required int score,
    required int maxScore,
    required int stars,
    Map<String, dynamic>? resultPayload,
  }) async {
    if (sessionId <= 0) return null;
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        debugPrint(">>> [SESSION END] Missing child token.");
        return null;
      }

      final url = ApiConstants.sessionEnd(sessionId);
      final body = {
        'score': score,
        'max_score': maxScore,
        'stars': stars,
        'result_payload': resultPayload ?? {},
      };

      debugPrint(">>> [POST] $url Body: $body");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      debugPrint(">>> [SESSION END] FAILED: ${response.statusCode} - ${response.body}");
    } catch (e) {
      debugPrint(">>> [SESSION END] ERROR: $e");
    }
    return null;
  }
}
