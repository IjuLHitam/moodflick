import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/movie.dart';

class TmdbService {
  Future<List<Movie>> _fetchList(
    String endpoint, [
    Map<String, String>? params,
  ]) async {
    final query = {
      'api_key': AppConfig.tmdbApiKey,
      'language': 'id-ID',
      ...?params,
    };

    final uri = Uri.parse('${AppConfig.tmdbBaseUrl}$endpoint')
        .replace(queryParameters: query);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data film');
    }

    final data = jsonDecode(response.body);
    final results = data['results'] as List? ?? [];

    return results.map((item) => Movie.fromJson(item)).toList();
  }

  Future<List<Movie>> popular() {
    return _fetchList('/movie/popular');
  }

  Future<List<Movie>> trendingWeek() {
    return _fetchList('/trending/movie/week');
  }

  Future<List<Movie>> nowPlaying() {
    return _fetchList('/movie/now_playing');
  }

  Future<List<Movie>> topRated() {
    return _fetchList('/movie/top_rated');
  }

  Future<List<Movie>> upcoming() {
    return _fetchList('/movie/upcoming');
  }

  Future<List<Movie>> search(String query, {int page = 1}) {
    return _fetchList('/search/movie', {
      'query': query,
      'page': '$page',
    });
  }

  Future<List<Movie>> discoverByMood(String mood) {
    final moodGenres = {
      'senang': '35,16,10751',
      'sedih': '18,10749',
      'marah': '28,53',
      'santai': '35,10751,12',
      'semangat': '28,12,878',
      'lelah': '16,35,10751',
    };

    return _fetchList('/discover/movie', {
      'with_genres': moodGenres[mood.toLowerCase()] ?? '35',
      'sort_by': 'popularity.desc',
    });
  }

  Future<Map<String, dynamic>> detail(int movieId) async {
    Future<Map<String, dynamic>> fetchDetail(String language) async {
      final uri = Uri.parse('${AppConfig.tmdbBaseUrl}/movie/$movieId').replace(
        queryParameters: {
          'api_key': AppConfig.tmdbApiKey,
          'language': language,
          'append_to_response': 'videos,credits,recommendations',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil detail film');
      }

      return jsonDecode(response.body);
    }

    final indonesiaDetail = await fetchDetail('id-ID');
    final overview = indonesiaDetail['overview'];

    if (overview != null && overview.toString().trim().isNotEmpty) {
      return indonesiaDetail;
    }

    final englishDetail = await fetchDetail('en-US');

    return {
      ...englishDetail,
      'genres': indonesiaDetail['genres'] ?? englishDetail['genres'],
      'credits': indonesiaDetail['credits'] ?? englishDetail['credits'],
      'recommendations':
          indonesiaDetail['recommendations'] ?? englishDetail['recommendations'],
      'videos': indonesiaDetail['videos'] ?? englishDetail['videos'],
    };
  }

  Future<String?> getTrailerKey(int movieId) async {
    Future<String?> fetchTrailer(String language) async {
      final uri = Uri.parse('${AppConfig.tmdbBaseUrl}/movie/$movieId/videos')
          .replace(
        queryParameters: {
          'api_key': AppConfig.tmdbApiKey,
          'language': language,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? [];

      if (results.isEmpty) return null;

      final youtubeVideos = results
          .where(
            (video) =>
                video['site'] == 'YouTube' &&
                video['key'] != null,
          )
          .toList();

      if (youtubeVideos.isEmpty) return null;

      final trailers = youtubeVideos
          .where((video) => video['type'] == 'Trailer')
          .toList();

      if (trailers.isNotEmpty) {
        return trailers.first['key'];
      }

      return youtubeVideos.first['key'];
    }

    final indonesiaTrailer = await fetchTrailer('id-ID');
    if (indonesiaTrailer != null) return indonesiaTrailer;

    final englishTrailer = await fetchTrailer('en-US');
    if (englishTrailer != null) return englishTrailer;

    return null;
  }
}