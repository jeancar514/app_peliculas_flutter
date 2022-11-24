import 'package:app_peliculas/src/models/actores_model.dart';
import 'package:app_peliculas/src/models/pelicula_model.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PeliculasProvider {
  String _apiKey = '288af6cfbfb82c23ba3047c58fe892ee';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';
  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = [];
  final _popularesStreamController =
      StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStream() {
    _popularesStreamController?.close();
  }

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
    if (_cargando) return [];
    _cargando = true;
    _popularesPage++;
    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apiKey,
      'language': _language,
      'page': _popularesPage.toString(),
    });

    final resp = await procesarRespuesta(url, 'results');
    _populares.addAll(resp);
    popularesSink(_populares);
    _cargando = false;
    return resp;
  }

  Future<List<Actor>> getCast(String peliId) async {
    final url = Uri.https(_url, '3/movie/$peliId/credits', {
      'api_key': _apiKey,
      'language': _language,
    });
    final resp = await http.get(url);
    final decodeData = jsonDecode(resp.body);
    final cast = new Cast.fromJsonList(decodeData['cast']);
    return cast.actores;
  }

  Future<List<Pelicula>> buscarPelicula(String query) async {
    final url = Uri.https(_url, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query,
    });
    return procesarRespuesta(url, 'results');
  }
}
