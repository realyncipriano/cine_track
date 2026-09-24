import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../l10n/app_localizations.dart';
import 'movie_details_screen.dart';

class MovieDetailsLoaderScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsLoaderScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsLoaderScreen> createState() => _MovieDetailsLoaderScreenState();
}

class _MovieDetailsLoaderScreenState extends State<MovieDetailsLoaderScreen> {
  final TmdbService _tmdb = TmdbService();
  Movie? _movie;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    try {
      final movie = await _tmdb.getMovieDetails(widget.movieId);
      if (mounted) {
        setState(() {
          _movie = movie;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    if (_error != null || _movie == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF161B22),
          title: Text(l10n.movie, style: GoogleFonts.inter(fontSize: 16)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error ?? l10n.movieNotFound,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return MovieDetailsScreen(movie: _movie!);
  }
}
