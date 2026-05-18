import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import '../utils/page_transition.dart';
import '../widgets/skeleton_loader.dart';
import 'detail_screen.dart';

class MoodScreen extends StatefulWidget {
  final String mood;

  const MoodScreen({
    super.key,
    required this.mood,
  });

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  final tmdb = TmdbService();
  late Future<List<Movie>> movies;

  String sort = 'popular';

  @override
  void initState() {
    super.initState();
    movies = tmdb.discoverByMood(widget.mood);
  }

  List<Movie> sortMovies(List<Movie> data) {
    final list = [...data];

    if (sort == 'rating_high') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sort == 'rating_low') {
      list.sort((a, b) => a.rating.compareTo(b.rating));
    } else if (sort == 'newest') {
      list.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
    } else if (sort == 'oldest') {
      list.sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
    }

    return list;
  }

void openDetail(Movie movie) {
  Navigator.push(
    context,
    createFadeSlideRoute(
      DetailScreen(
        movie: movie,
        mood: widget.mood,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood ${widget.mood}'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              children: [
                chip('Terbaru', 'newest'),
                chip('Terlama', 'oldest'),
                chip('Rating Tertinggi', 'rating_high'),
                chip('Rating Terendah', 'rating_low'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: movies,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
  return const MovieGridSkeleton();
}

                final data = sortMovies(snapshot.data!);

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 14,
                  ),
                  itemBuilder: (context, i) {
                    return MovieCard(
                      movie: data[i],
                      onTap: () => openDetail(data[i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget chip(String label, String value) {
    final active = sort == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        selectedColor: const Color(0xFFE92D35),
        labelStyle: TextStyle(
          color: active ? Colors.white : null,
        ),
        onSelected: (_) {
          setState(() => sort = value);
        },
      ),
    );
  }
}