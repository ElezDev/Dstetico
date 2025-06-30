import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://d-estetico.co/tarjetade/';
  static const String _authToken = 'D1R3CT0R103ST3T1C020210205';
  static String? _sessionId;

  // Método para obtener la cookie de sesión de las headers
  static String? _extractSessionCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      return (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
    return null;
  }

  // Método para login
  static Future<Map<String, dynamic>> login(
    String usuario,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}api_login.php'),
      headers: {
        'Authorization': _authToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({'usuario': usuario, 'password': password}),
    );

    if (response.statusCode == 200) {
      final sessionData = json.decode(response.body);

      if (sessionData['codigo'] == null) {
        throw Exception('Usuario o contraseña incorrectos');
      }

      _sessionId = _extractSessionCookie(response);

      if (sessionData['codigo'] != null) {
        await _saveSessionData(
          sessionData['codigo'],
          sessionData['nombre'],
          sessionData['login'],
          _sessionId,
        );
      }

      return sessionData;
    } else {
      throw Exception('Error en el login');
    }
  }

  // Método para guardar datos de sesión
  static Future<void> _saveSessionData(
    String codigo,
    String nombre,
    String login,
    String? sessionId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('codigo', codigo);
    await prefs.setString('nombre', nombre);
    await prefs.setString('login', login);
    if (sessionId != null) {
      await prefs.setString('sessionId', sessionId);
    }
  }

  // Método para cargar datos de sesión
  static Future<Map<String, dynamic>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final codigo = prefs.getString('codigo');
    if (codigo == null) return null;

    return {
      'codigo': codigo,
      'nombre': prefs.getString('nombre'),
      'login': prefs.getString('login'),
    };
  }

  // Método para obtener el sessionId
  static Future<String?> getSessionId() async {
    if (_sessionId != null) return _sessionId;
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('sessionId');
    return _sessionId;
  }

  // Método para cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('codigo');
    await prefs.remove('nombre');
    await prefs.remove('login');
    await prefs.remove('sessionId');
    _sessionId = null;
  }

  // Método para validar código (actualizado)
  static Future<Map<String, dynamic>> validateCode(
    String code,
    int type,
  ) async {
    final sessionId = await getSessionId();

    if (sessionId == null) {
      throw Exception('No hay sesión activa');
    }

    final response = await http.post(
      Uri.parse('${_baseUrl}api_publicidad.php'),
      headers: {
        'Authorization': _authToken,
        'Content-Type': 'application/json',
        'Cookie': 'PHPSESSID=$sessionId',
      },
      body: json.encode({'tipo': type.toString(), 'codigo': code}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al validar el código');
    }
  }
}
