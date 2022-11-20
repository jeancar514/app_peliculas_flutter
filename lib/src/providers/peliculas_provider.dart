import 'package:app_peliculas/src/models/pelicula_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PeliculasProvider {
  String _apiKey = '288af6cfbfb82c23ba3047c58fe892ee';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  Future<List<Pelicula>> procesarRespuesta(Uri url, String nameResp) async {
    final resp = await http.get(url);
    final decodeData = jsonDecode(resp.body);
    final peliculas = new Peliculas.fromJsonList(decodeData[nameResp]);
    return peliculas.items;
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key': _apiKey,
      'language': _language,
    });
    return procesarRespuesta(url, 'results');
  }

  Future<List<Pelicula>> getPopulares() async {
    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apiKey,
      'language': _language,
    });
    return procesarRespuesta(url, 'results');
  }
}
