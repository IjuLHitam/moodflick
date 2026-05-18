import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../models/movie.dart';
import '../services/supabase_service.dart';
import '../services/tmdb_service.dart';
import '../utils/page_transition.dart';
import '../widgets/glass_card.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  final String? mood;

  const DetailScreen({
    super.key,
    required this.movie,
    this.mood,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final tmdb = TmdbService();
  final db = SupabaseService();

  Map<String, dynamic>? detail;
  bool loading = true;

  String getOverview() {
  final detailOverview = detail?['overview'];

  if (detailOverview != null && detailOverview.toString().trim().isNotEmpty) {
    return detailOverview.toString();
  }

  if (widget.movie.overview.trim().isNotEmpty) {
    return widget.movie.overview;
  }

  return 'Sinopsis belum tersedia.';
}

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    detail = await tmdb.detail(widget.movie.id);
    setState(() => loading = false);
  }

Future<void> openTrailer() async {
  final key = await tmdb.getTrailerKey(widget.movie.id);

  if (key == null) {
    showMsg('Trailer tidak tersedia');
    return;
  }

  final url = Uri.parse('https://www.youtube.com/watch?v=$key');

  final success = await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  );

  if (!success) {
    showMsg('Gagal membuka trailer');
  }
}

  Future<void> saveWatchlist() async {
    try {
      await db.addWatchlist(widget.movie, mood: widget.mood);
      showMsg('Film disimpan ke watchlist');
    } catch (e) {
      showMsg('Kamu harus login untuk menyimpan film');
    }
  }

  Future<void> markWatched() async {
    try {
      await db.addHistory(widget.movie, mood: widget.mood);
      showMsg('Film masuk ke riwayat');
    } catch (e) {
      showMsg('Kamu harus login untuk menyimpan riwayat');
    }
  }

  Future<void> shareWhatsApp() async {
    final text = Uri.encodeComponent(
      'Aku rekomendasi film ${widget.movie.title} di MoodFlick!',
    );

    final url = Uri.parse('https://wa.me/?text=$text');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void normalShare() {
    Share.share(
      'Aku rekomendasi film ${widget.movie.title} di MoodFlick!',
    );
  }

  void showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backdrop = widget.movie.backdropPath.isEmpty
        ? null
        : '${AppConfig.backdropBaseUrl}${widget.movie.backdropPath}';

    final poster = widget.movie.posterPath.isEmpty
        ? null
        : '${AppConfig.imageBaseUrl}${widget.movie.posterPath}';

    final genres = detail?['genres'] as List? ?? [];
    final cast = detail?['credits']?['cast'] as List? ?? [];
    final recommendations =
        detail?['recommendations']?['results'] as List? ?? [];

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: backdrop == null
                          ? Container(color: Colors.grey)
                          : CachedNetworkImage(
                              imageUrl: backdrop,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 45,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 45,
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          onPressed: normalShare,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 18,
                      left: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: poster == null
                                ? Container(
                                    width: 105,
                                    height: 150,
                                    color: Colors.grey,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: poster,
                                    width: 105,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: genres.map((g) {
                          return Chip(
                            label: Text(g['name']),
                            backgroundColor:
                                const Color(0xFFE92D35).withOpacity(0.12),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
GlassCard(
  padding: const EdgeInsets.all(16),
  radius: 20,
  child: Row(
    children: [
      const Icon(Icons.star, color: Colors.green),
      const SizedBox(width: 8),
      Text(
        '${widget.movie.rating.toStringAsFixed(1)} / 10',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      const Spacer(),
      const Icon(Icons.calendar_month, size: 18),
      const SizedBox(width: 5),
      Text(widget.movie.releaseDate),
    ],
  ),
),
const SizedBox(height: 18),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: openTrailer,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Trailer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE92D35),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: shareWhatsApp,
                              icon: const Icon(Icons.message),
                              label: const Text('WhatsApp'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: normalShare,
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Sinopsis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
  getOverview(),
),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: saveWatchlist,
                              icon: const Icon(Icons.bookmark_border),
                              label: const Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE92D35),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: markWatched,
                              icon: const Icon(Icons.check),
                              label: const Text('Sudah Ditonton'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pemeran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cast.length > 10 ? 10 : cast.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final actor = cast[i];
                            final img = actor['profile_path'] == null
                                ? null
                                : '${AppConfig.imageBaseUrl}${actor['profile_path']}';

                            return SizedBox(
                              width: 70,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        img == null ? null : NetworkImage(img),
                                    child: img == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    actor['name'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Film Serupa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommendations.length > 10
                              ? 10
                              : recommendations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final movie = Movie.fromJson(
                              recommendations[i],
                            );

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
  context,
  createFadeSlideRoute(
    DetailScreen(movie: movie),
  ),
);
                              },
                              child: SizedBox(
                                width: 120,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        child: movie.posterPath.isEmpty
                                            ? Container(color: Colors.grey)
                                            : CachedNetworkImage(
                                                imageUrl:
                                                    '${AppConfig.imageBaseUrl}${movie.posterPath}',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      movie.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}