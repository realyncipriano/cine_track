import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LikeButton extends StatefulWidget {
  final int reviewId;
  final int likesCount;
  final bool isLiked;
  final VoidCallback onToggle;

  const LikeButton({
    super.key,
    required this.reviewId,
    required this.likesCount,
    required this.isLiked,
    required this.onToggle,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isToggling = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isToggling
          ? null
          : () {
              HapticFeedback.lightImpact();
              setState(() => _isToggling = true);
              widget.onToggle();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) setState(() => _isToggling = false);
              });
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isLiked ? Icons.favorite : Icons.favorite_outline,
            size: 18,
            color: widget.isLiked ? Colors.redAccent : Colors.grey[400],
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.likesCount}',
            style: TextStyle(
              color: widget.isLiked ? Colors.redAccent : Colors.grey[400],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
