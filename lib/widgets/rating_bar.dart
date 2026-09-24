import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class RatingBar extends StatelessWidget {
  final int rating;
  final double starSize;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;

  const RatingBar({
    super.key,
    this.rating = 0,
    this.starSize = 28,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (interactive) {
      return _InteractiveRatingBar(
        initialRating: rating,
        starSize: starSize,
        onRatingChanged: onRatingChanged,
      );
    }

    return Semantics(
      label: l10n.ratingOutOf10(rating),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final filled = rating >= (i + 1) * 2;
          final half = !filled && rating >= i * 2 + 1;
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              filled
                  ? Icons.star
                  : half
                      ? Icons.star_half
                      : Icons.star_border,
              size: starSize,
              color: filled || half ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
            ),
          );
        }),
      ),
    );
  }
}

class _InteractiveRatingBar extends StatefulWidget {
  final int initialRating;
  final double starSize;
  final ValueChanged<int>? onRatingChanged;

  const _InteractiveRatingBar({
    required this.initialRating,
    required this.starSize,
    this.onRatingChanged,
  });

  @override
  State<_InteractiveRatingBar> createState() => _InteractiveRatingBarState();
}

class _InteractiveRatingBarState extends State<_InteractiveRatingBar> {
  late int _rating;
  late int _hoverRating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _hoverRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(_InteractiveRatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRating != oldWidget.initialRating) {
      _rating = widget.initialRating;
      _hoverRating = widget.initialRating;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.ratingSelector,
      hint: l10n.selectRatingHint,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(10, (i) {
              final starValue = i + 1;
              return Semantics(
                label: l10n.rateOutOf10(starValue),
                button: true,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _rating = starValue);
                    widget.onRatingChanged?.call(starValue);
                  },
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoverRating = starValue),
                    onExit: (_) => setState(() => _hoverRating = _rating),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 44,
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: starValue <= _hoverRating
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '$starValue',
                          style: TextStyle(
                            color: starValue <= _hoverRating
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                            fontSize: 13,
                            fontWeight: starValue <= _hoverRating
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            _rating > 0 ? l10n.ratingDisplay(_rating) : l10n.tapToRate,
            style: TextStyle(
              color: _rating > 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
