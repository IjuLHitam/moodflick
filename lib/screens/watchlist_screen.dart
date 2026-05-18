import 'package:flutter/material.dart';

import '../config.dart';
import '../models/movie.dart';
import '../services/supabase_service.dart';
import '../widgets/glass_card.dart';
import '../utils/page_transition.dart';
import 'detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final db = SupabaseService();

  bool showHistory = false;
  bool loading = true;
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    data = showHistory
        ? await db.getHistories()
        : await db.getWatchlists();

    setState(() => loading = false);
  }

  Future<void> confirmDelete(Map<String, dynamic> item) async {
    final movieTitle = item['title'] ?? 'film ini';
    final movieId = item['movie_id'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus dari Watchlist?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus "$movieTitle" dari watchlist?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE92D35),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await db.removeWatchlist(movieId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$movieTitle berhasil dihapus dari watchlist'),
          ),
        );

        await loadData();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus film: $e'),
          ),
        );
      }
    }
  }

  Movie toMovie(Map<String, dynamic> item) {
    return Movie(
      id: item['movie_id'],
      title: item['title'],
      overview: '',
      posterPath: item['poster_path'] ?? '',
      backdropPath: '',
      releaseDate: item['release_date'] ?? '',
      rating: (item['rating'] ?? 0).toDouble(),
    );
  }

  void openDetail(Map<String, dynamic> item) {
  Navigator.push(
    context,
    createFadeSlideRoute(
      DetailScreen(movie: toMovie(item)),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (db.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Login dulu untuk melihat watchlist dan riwayat'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(showHistory ? 'Riwayat' : 'Watchlist'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                tabButton('Watchlist', false),
                tabButton('Riwayat', true),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                    ? emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = data[i];

                          final poster = item['poster_path'] == null
                              ? null
                              : '${AppConfig.imageBaseUrl}${item['poster_path']}';

                          return GlassCard(
  padding: EdgeInsets.zero,
  radius: 18,
  child: ListTile(
    onTap: () => openDetail(item),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: poster == null
          ? Container(
              width: 50,
              height: 70,
              color: Colors.grey,
              child: const Icon(Icons.movie),
            )
          : Image.network(
              poster,
              width: 50,
              height: 70,
              fit: BoxFit.cover,
            ),
    ),
    title: Text(
      item['title'],
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Text(
      'Rating ${item['rating']} • ${item['release_date']}',
    ),
    trailing: showHistory
        ? null
        : IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFE92D35),
            ),
            onPressed: () => confirmDelete(item),
          ),
  ),
);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget tabButton(String label, bool history) {
    final active = showHistory == history;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => showHistory = history);
          loadData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE92D35) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Text(
        showHistory
            ? 'Belum ada riwayat film'
            : 'Watchlist masih kosong',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}