import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import '../models/movie.dart';
import '../utils/page_transition.dart';
import '../widgets/app_background.dart';
import '../widgets/skeleton_loader.dart';
import 'detail_screen.dart';

class MovieListScreen extends StatelessWidget {
  final String title;
  final Future<List<Movie>> moviesFuture;

  const MovieListScreen({
    super.key,
    required this.title,
    required this.moviesFuture,
  });

  void openDetail(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      createFadeSlideRoute(
        DetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              final horizontalPadding = isDesktop ? 26.0 : 12.0;
              final crossAxisCount = isDesktop ? 8 : 3;
              final crossAxisSpacing = isDesktop ? 12.0 : 10.0;
              final availableWidth =
                  constraints.maxWidth - (horizontalPadding * 2);

              final itemWidth = (availableWidth -
                      ((crossAxisCount - 1) * crossAxisSpacing)) /
                  crossAxisCount;

              final posterHeight = itemWidth * 1.5;
              final itemHeight = posterHeight + 46;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  14,
                  horizontalPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Expanded(
                      child: FutureBuilder<List<Movie>>(
                        future: moviesFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const MovieGridSkeleton();
                          }

                          final movies = snapshot.data!;

                          if (movies.isEmpty) {
                            return const Center(
                              child: Text('Film tidak ditemukan'),
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: movies.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisExtent: itemHeight,
                              crossAxisSpacing: crossAxisSpacing,
                              mainAxisSpacing: isDesktop ? 20 : 18,
                            ),
                            itemBuilder: (context, index) {
                              final movie = movies[index];

                              return MovieListItem(
                                movie: movie,
                                onTap: () => openDetail(context, movie),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MovieListItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieListItem({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath.isEmpty
        ? null
        : '${AppConfig.imageBaseUrl}${movie.posterPath}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: posterUrl == null
                        ? Container(
                            color: Colors.grey.withOpacity(0.25),
                            child: const Icon(Icons.movie),
                          )
                        : CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⭐ ${movie.rating.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.48),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            movie.releaseDate.isEmpty
                ? '-'
                : movie.releaseDate.split('-').first,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}