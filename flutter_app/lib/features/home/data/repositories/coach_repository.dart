import 'package:bite_smart/core/network/api_service.dart';
import 'package:bite_smart/features/home/data/models/coach_models.dart';
import 'package:flutter/material.dart';

abstract class ICoachRepository {
  Future<List<CoachSessionModel>> getCoachSessions();
  Future<List<CoachMessageModel>> getChatHistory(String chatId);
  Future<void> deleteCoachSession(String chatId);
  Future<Map<String, dynamic>> sendCoachMessage({
    required String message,
    String? chatId,
  });
}

class CoachRepository implements ICoachRepository {
  List<dynamic> _extractList(dynamic json) {
    if (json is List) {
      return json;
    }
    if (json is Map) {
      for (final key in ['sessions', 'messages', 'history', 'chats', 'list', 'data']) {
        if (json.containsKey(key) && json[key] is List) {
          return json[key] as List<dynamic>;
        }
      }
      for (final key in ['data', 'message']) {
        if (json.containsKey(key) && json[key] is Map) {
          final result = _extractList(json[key]);
          if (result.isNotEmpty) return result;
        }
      }
      for (final value in json.values) {
        if (value is Map) {
          final result = _extractList(value);
          if (result.isNotEmpty) return result;
        } else if (value is List) {
          return value;
        }
      }
    }
    return [];
  }

  @override
  Future<List<CoachSessionModel>> getCoachSessions() async {
    final response = await ApiService.instance.get('/coach/sessions');
    if (response['success'] == true) {
      final List<dynamic> list = _extractList(response['data']);
      return list.map((item) => CoachSessionModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load coach sessions');
    }
  }

  @override
  Future<List<CoachMessageModel>> getChatHistory(String chatId) async {
    final response = await ApiService.instance.get('/coach/sessions/$chatId/history');
    if (response['success'] == true) {
      final List<dynamic> list = _extractList(response['data']);
      return list.map((item) => CoachMessageModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load chat history');
    }
  }

  @override
  Future<void> deleteCoachSession(String chatId) async {
    debugPrint("Deleting Coach Session with ID: '$chatId'");
    if (chatId.isEmpty) {
      throw Exception('Chat ID is empty');
    }
    try {
      final response = await ApiService.instance.delete('/coach/sessions/$chatId');
      debugPrint("Delete response: $response");
      
      bool isSuccess = true;
      String? message;
      
      if (response.containsKey('success')) {
        isSuccess = response['success'] == true;
      }
      if (response.containsKey('message')) {
        message = response['message']?.toString();
      }
      
      if (response.containsKey('data') && response['data'] is Map) {
        final innerData = response['data'] as Map;
        if (innerData.containsKey('success')) {
          isSuccess = innerData['success'] == true;
        }
        if (innerData.containsKey('message')) {
          message = innerData['message']?.toString();
        }
      }
      
      if (!isSuccess) {
        throw Exception(message ?? 'Failed to delete chat session');
      }
    } catch (e) {
      debugPrint("Error in deleteCoachSession: $e");
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('invalid json') || errStr.contains('format') || errStr.contains('unexpected character')) {
        debugPrint("Treating JSON parse error as success for DELETE request.");
        return;
      }
      rethrow;
    }
  }

  String? _findKeyDeep(dynamic json, List<String> targetKeys) {
    if (json is Map) {
      for (final key in targetKeys) {
        if (json.containsKey(key) && json[key] != null && json[key] is! Map && json[key] is! List) {
          final val = json[key].toString();
          if (val.toLowerCase().contains('successfully') || val.toLowerCase().contains('generated successfully')) {
            continue;
          }
          return val;
        }
      }
      for (final key in ['data', 'message']) {
        if (json.containsKey(key) && json[key] is Map) {
          final result = _findKeyDeep(json[key], targetKeys);
          if (result != null) return result;
        }
      }
      for (final value in json.values) {
        if (value is Map) {
          final result = _findKeyDeep(value, targetKeys);
          if (result != null) return result;
        } else if (value is List) {
          for (final item in value) {
            final result = _findKeyDeep(item, targetKeys);
            if (result != null) return result;
          }
        }
      }
    }
    return null;
  }

  String? _findChatIdDeep(dynamic json) {
    final targetKeys = ['session_id', 'sessionId', 'chatId', 'id', 'session'];
    if (json is Map) {
      for (final key in targetKeys) {
        if (json.containsKey(key) && json[key] != null && json[key] is! Map && json[key] is! List) {
          return json[key].toString();
        }
      }
      for (final key in ['data', 'message']) {
        if (json.containsKey(key) && json[key] is Map) {
          final result = _findChatIdDeep(json[key]);
          if (result != null) return result;
        }
      }
      for (final value in json.values) {
        if (value is Map) {
          final result = _findChatIdDeep(value);
          if (result != null) return result;
        } else if (value is List) {
          for (final item in value) {
            final result = _findChatIdDeep(item);
            if (result != null) return result;
          }
        }
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> sendCoachMessage({
    required String message,
    String? chatId,
  }) async {
    final Map<String, dynamic> body = {
      'message': message,
    };
    if (chatId != null && chatId.isNotEmpty) {
      body['chatId'] = chatId;
    }
    
    final response = await ApiService.instance.post('/coach/chat', body);
    if (response['success'] == true) {
      dynamic data = response['data'];
      
      String reply = "";
      String? returnedChatId;

      if (data is Map) {
        final targetKeys = [
          'coach_response',
          'coachResponse',
          'reply',
          'response',
          'content',
          'text',
          'ai_response',
          'aiResponse',
          'coach_reply',
          'message'
        ];
        
        reply = _findKeyDeep(data, targetKeys) ?? "";
        returnedChatId = _findChatIdDeep(data);
      } else if (data is String) {
        reply = data;
      }

      return {
        'reply': reply,
        'chatId': returnedChatId,
      };
    } else {
      throw Exception(response['message'] ?? 'Failed to send message');
    }
  }
}
