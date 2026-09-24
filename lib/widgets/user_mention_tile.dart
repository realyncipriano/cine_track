import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config.dart';

class UserMentionTile extends StatelessWidget {
  final int userId;
  final String userName;
  final String? avatarUrl;
  final double avatarSize;
  final double fontSize;
  final FontWeight? fontWeight;

  const UserMentionTile({
    super.key,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    this.avatarSize = 14,
    this.fontSize = 13,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/profile/$userId'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider('${AppConfig.imageBaseUrl}$avatarUrl')
                : null,
            child: avatarUrl == null
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      fontSize: fontSize - 2,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            userName,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
