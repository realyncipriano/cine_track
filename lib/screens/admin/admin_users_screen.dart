import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../helpers/responsive.dart';
import '../../helpers/time_ago.dart';
import '../../models/admin/admin_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin/user_management_provider.dart';
import '../../widgets/pagination_bar.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String? _roleFilter;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().fetchUsers();
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _search() {
    _animController.reset();
    context.read<UserManagementProvider>().fetchUsers(
          search: _searchController.text,
          role: _roleFilter,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
        );
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<UserManagementProvider>();
    final isWide = Responsive.isDesktop(context);
    final theme = Theme.of(context);
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text('Users', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            if (!admin.isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${admin.totalUsers}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
                final goRouter = GoRouter.maybeOf(context);
                if (goRouter != null) {
                  goRouter.go('/admin');
                } else {
                  Navigator.of(context).pop();
                }
              },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchFilterBar(context, theme, padding),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: _buildContent(admin, isWide, theme),
            ),
          ),
          if (admin.totalUsers > 20)
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, 8),
              child: PaginationBar(
                currentPage: admin.currentPage,
                totalPages: (admin.totalUsers / 20).ceil(),
                onPageChanged: (p) {
                  _animController.reset();
                  admin.fetchUsers(
                    search: _searchController.text,
                    role: _roleFilter,
                    page: p,
                  );
                  _animController.forward();
                },
              ),
            ),
          SizedBox(height: padding),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  SEARCH & FILTER BAR
  // ─────────────────────────────────────────────────────────────

  Widget _buildSearchFilterBar(BuildContext context, ThemeData theme, double padding) {
    return Container(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search field
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or username...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                        onPressed: () {
                          _searchController.clear();
                          _search();
                        },
                      )
                    : null,
                filled: false,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface),
              onSubmitted: (_) => _search(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 10),
          // Role filter chips + sort
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(theme, 'All', null, Icons.people_rounded),
                      const SizedBox(width: 8),
                      _buildFilterChip(theme, 'User', 'user', Icons.person_rounded),
                      const SizedBox(width: 8),
                      _buildFilterChip(theme, 'Admin', 'admin', Icons.shield_rounded),
                      const SizedBox(width: 8),
                      _buildFilterChip(theme, 'Moderator', 'moderator', Icons.verified_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sort toggle
              _SortButton(
                sortBy: _sortBy,
                sortOrder: _sortOrder,
                onChanged: (by, order) {
                  setState(() {
                    _sortBy = by;
                    _sortOrder = order;
                  });
                  _search();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, String? value, IconData icon) {
    final selected = _roleFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _roleFilter = value);
        _search();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : theme.dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  CONTENT (loading / error / empty / data)
  // ─────────────────────────────────────────────────────────────

  Widget _buildContent(UserManagementProvider admin, bool isWide, ThemeData theme) {
    if (admin.isLoading) {
      return _buildSkeleton(isWide, theme);
    }
    if (admin.error != null) {
      return _buildError(admin, theme);
    }
    if (admin.users.isEmpty) {
      return _buildEmpty(theme);
    }
    return FadeTransition(
      opacity: _fadeAnim,
      child: _buildUserList(admin, isWide, theme),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  LOADING SKELETON
  // ─────────────────────────────────────────────────────────────

  Widget _buildSkeleton(bool isWide, ThemeData theme) {
    return isWide ? _buildSkeletonTable(theme) : _buildSkeletonCards(theme);
  }

  Widget _buildSkeletonCards(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4),
      itemCount: 6,
      itemBuilder: (_, i) => _ShimmerCard(
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140, height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200, height: 11,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60, height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonTable(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: List.generate(
          8,
          (i) => _ShimmerCard(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: i > 0 ? Border(top: BorderSide(color: theme.dividerColor)) : null,
                borderRadius: i == 0
                    ? const BorderRadius.vertical(top: Radius.circular(14))
                    : null,
              ),
              child: Row(
                children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: Container(height: 13, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Container(height: 13, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(width: 12),
                  Expanded(child: Container(width: 60, height: 22, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(11)))),
                  const SizedBox(width: 12),
                  Expanded(child: Container(height: 13, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(width: 12),
                  SizedBox(width: 72, child: Row(
                    children: [
                      Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8))),
                      const SizedBox(width: 8),
                      Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8))),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  ERROR STATE
  // ─────────────────────────────────────────────────────────────

  Widget _buildError(UserManagementProvider admin, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 40, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load users',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              admin.error ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────────────────────────

  Widget _buildEmpty(ThemeData theme) {
    final hasFilters = _searchController.text.isNotEmpty || _roleFilter != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.search_off_rounded : Icons.people_outline_rounded,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilters ? 'No users match your filters' : 'No users yet',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters ? 'Try adjusting your search or role filter' : 'Users will appear here once they register',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _roleFilter = null);
                  _search();
                },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  USER LIST (desktop table / mobile cards)
  // ─────────────────────────────────────────────────────────────

  Widget _buildUserList(UserManagementProvider admin, bool isWide, ThemeData theme) {
    if (isWide) {
      return _buildUserTable(admin, theme);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4),
      itemCount: admin.users.length,
      itemBuilder: (_, i) => _buildUserCard(admin.users[i], theme),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  DESKTOP TABLE
  // ─────────────────────────────────────────────────────────────

  Widget _buildUserTable(UserManagementProvider admin, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Theme(
            data: theme.copyWith(
              dataTableTheme: DataTableThemeData(
                headingRowColor: WidgetStateProperty.all(
                  theme.colorScheme.onSurface.withValues(alpha: 0.04),
                ),
                headingTextStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
                dataTextStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
                dividerThickness: 0,
              ),
            ),
            child: DataTable(
              sortColumnIndex: _sortBy == 'name'
                  ? 1
                  : _sortBy == 'email'
                      ? 2
                      : 0,
              sortAscending: _sortOrder == 'asc',
              headingRowHeight: 48,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 64,
              columnSpacing: 16,
              horizontalMargin: 16,
              columns: [
                const DataColumn(columnWidth: FixedColumnWidth(48), label: SizedBox(width: 40, child: Text(''))),
                DataColumn(
                  columnWidth: const FlexColumnWidth(2),
                  label: const Text('User'),
                  onSort: (_, asc) => _onSort('name', asc),
                ),
                DataColumn(
                  columnWidth: const FlexColumnWidth(3),
                  label: const Text('Email'),
                  onSort: (_, asc) => _onSort('email', asc),
                ),
                const DataColumn(columnWidth: FixedColumnWidth(90), label: Text('Role')),
                const DataColumn(columnWidth: FixedColumnWidth(100), label: Text('Status')),
                const DataColumn(columnWidth: FixedColumnWidth(85), label: Text('Joined')),
                const DataColumn(columnWidth: FixedColumnWidth(80), label: Text(''), numeric: true),
              ],
              rows: List.generate(
                admin.users.length,
                (i) => _buildUserRow(admin.users[i], theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildUserRow(AdminUser user, ThemeData theme) {
    return DataRow(
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return theme.colorScheme.primary.withValues(alpha: 0.04);
        }
        return null;
      }),
      cells: [
        DataCell(_buildAvatar(user, 34, theme)),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('@${user.username}', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.45))),
            ],
          ),
        ),
        DataCell(Text(user.email, style: GoogleFonts.inter(fontSize: 13))),
        DataCell(_buildRoleChip(user.role, theme)),
        DataCell(_buildStatusBadge(user, theme)),
        DataCell(Text(timeAgo(user.createdAt), style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
        DataCell(_buildRowActions(user, theme)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  MOBILE CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildUserCard(AdminUser user, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showUserDetail(user, context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildAvatar(user, 46, theme),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildRoleChip(user.role, theme),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStatusBadge(user, theme),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time_rounded, size: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo(user.createdAt),
                          style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _buildCardActions(user, theme),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  AVATAR
  // ─────────────────────────────────────────────────────────────

  Widget _buildAvatar(AdminUser user, double radius, ThemeData theme) {
    final avatarUrl = user.avatarUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: _roleColor(user.role, theme).withValues(alpha: 0.15),
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
          ? (avatarUrl.startsWith('data:')
              ? MemoryImage(
                  base64Decode(avatarUrl.split(',').length >= 2 ? avatarUrl.split(',')[1] : ''))
              : NetworkImage(avatarUrl) as ImageProvider)
          : null,
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Text(
              (user.name.isNotEmpty ? user.name : '?')[0].toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
                color: _roleColor(user.role, theme),
              ),
            )
          : null,
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  ROLE CHIP
  // ─────────────────────────────────────────────────────────────

  Color _roleColor(String role, ThemeData theme) {
    switch (role) {
      case 'admin':
        return theme.colorScheme.primary;
      case 'moderator':
        return Colors.blue;
      default:
        return theme.colorScheme.outline;
    }
  }

  Widget _buildRoleChip(String role, ThemeData theme) {
    final color = _roleColor(role, theme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            role == 'admin'
                ? Icons.shield_rounded
                : role == 'moderator'
                    ? Icons.verified_rounded
                    : Icons.person_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            role[0].toUpperCase() + role.substring(1),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  STATUS BADGE
  // ─────────────────────────────────────────────────────────────

  Widget _buildStatusBadge(AdminUser user, ThemeData theme) {
    if (user.isBanned) {
      return _badge(theme, Icons.gavel_rounded, 'Banned', theme.colorScheme.error);
    }
    if (user.emailVerified) {
      return _badge(theme, Icons.check_circle_rounded, 'Verified', Colors.green);
    }
    return _badge(theme, Icons.hourglass_empty_rounded, 'Pending', theme.colorScheme.outline);
  }

  Widget _badge(ThemeData theme, IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  ACTION BUTTONS
  // ─────────────────────────────────────────────────────────────

  Widget _buildRowActions(AdminUser user, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconAction(Icons.visibility_outlined, 'View details', () => _showUserDetail(user, context), theme),
        const SizedBox(width: 4),
        _popupAction(user, theme),
      ],
    );
  }

  Widget _buildCardActions(AdminUser user, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconAction(Icons.visibility_outlined, 'View details', () => _showUserDetail(user, context), theme),
        const SizedBox(height: 4),
        _popupAction(user, theme),
      ],
    );
  }

  Widget _iconAction(IconData icon, String tooltip, VoidCallback onPressed, ThemeData theme) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.54),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
      ),
    );
  }

  Widget _popupAction(AdminUser user, ThemeData theme) {
    final currentUserId = context.read<AuthProvider>().user?.id;
    final isSelf = currentUserId == user.id;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      elevation: 4,
      onSelected: isSelf ? null : (action) => _handleUserAction(action, user.id, context),
      itemBuilder: (_) => isSelf
          ? [
              PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                    const SizedBox(width: 12),
                    Text('Cannot modify yourself', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
                  ],
                ),
              ),
            ]
          : [
              _menuItem(Icons.admin_panel_settings_rounded, 'Promote to Admin', 'promote', theme),
              _menuItem(Icons.person_rounded, 'Demote to User', 'demote', theme),
              if (user.isBanned)
                _menuItem(Icons.lock_open_rounded, 'Unban User', 'unban', theme)
              else
                _menuItem(Icons.block_rounded, 'Ban User', 'ban', theme, destructive: true),
              _menuItem(Icons.delete_forever_rounded, 'Delete Account', 'delete', theme, destructive: true),
            ],
    );
  }

  PopupMenuItem<String> _menuItem(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    bool destructive = false,
  }) {
    final color = destructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // USER DETAIL DIALOG
  // ─────────────────────────────────────────────────────────────

  void _showUserDetail(AdminUser user, BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 700 ? 640 : 480,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Avatar + Name header
              Center(child: _buildAvatar(user, 52, theme)),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.name,
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '@${user.username}',
                  style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRoleChip(user.role, theme),
                    const SizedBox(width: 8),
                    _buildStatusBadge(user, theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Info section
              _sectionHeader(theme, 'Account Information'),
              const SizedBox(height: 8),
              _detailCard(theme, [
                _detailRow(theme, Icons.email_outlined, 'Email', user.email),
                _detailRow(theme, Icons.phone_outlined, 'Phone', user.phone ?? '—'),
                _detailRow(theme, Icons.public_outlined, 'Country', user.country ?? '—'),
              ]),
              const SizedBox(height: 20),
              // Activity section
              _sectionHeader(theme, 'Activity'),
              const SizedBox(height: 8),
              _detailCard(theme, [
                _detailRow(theme, Icons.calendar_today_outlined, 'Joined', timeAgo(user.createdAt)),
                _detailRow(theme, Icons.verified_outlined, 'Email Verified', user.emailVerified ? 'Yes' : 'No'),
                _detailRow(theme, Icons.gavel_outlined, 'Status', user.isBanned ? 'Banned' : 'Active'),
              ]),
              const SizedBox(height: 20),
              // Stats row
              _sectionHeader(theme, 'Stats'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _statCard(theme, Icons.favorite_rounded, '${user.favoritesCount}', 'Favorites', Colors.redAccent)),
                  const SizedBox(width: 8),
                  Expanded(child: _statCard(theme, Icons.bookmark_rounded, '${user.watchlistCount}', 'Watchlist', theme.colorScheme.primary)),
                  const SizedBox(width: 8),
                  Expanded(child: _statCard(theme, Icons.rate_review_rounded, '${user.reviewsCount}', 'Reviews', Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _statCard(theme, Icons.history_rounded, '${user.historyCount}', 'History', Colors.teal)),
                ],
              ),
              const SizedBox(height: 24),
              // Actions
              _sectionHeader(theme, 'Actions'),
              const SizedBox(height: 8),
              _buildDetailActions(theme, user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _detailCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _detailRow(ThemeData theme, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(ThemeData theme, IconData icon, String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: 6),
          Text(
            count,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailActions(ThemeData theme, AdminUser user) {
    final currentUserId = context.read<AuthProvider>().user?.id;
    final isSelf = currentUserId == user.id;
    if (isSelf) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          width: double.infinity,
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 28, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 8),
              Text('This is your own account',
                  style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          _actionTile(
            theme,
            icon: Icons.admin_panel_settings_rounded,
            title: user.isAdmin ? 'Current role: Admin' : 'Promote to Admin',
            subtitle: user.isAdmin ? 'This user has full admin access' : 'Grant full admin privileges',
            onTap: user.isAdmin ? null : () {
              Navigator.of(context, rootNavigator: true).pop();
              _handleUserAction('promote', user.id, context);
            },
          ),
          if (!user.isAdmin)
            _actionTile(
              theme,
              icon: Icons.person_rounded,
              title: 'Demote to User',
              subtitle: 'Remove elevated privileges',
              onTap: user.isModerator ? () {
                Navigator.of(context, rootNavigator: true).pop();
                _handleUserAction('demote', user.id, context);
              } : null,
            ),
          if (user.isBanned)
            _actionTile(
              theme,
              icon: Icons.lock_open_rounded,
              title: 'Unban User',
              subtitle: 'Restore account access',
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                _handleUserAction('unban', user.id, context);
              },
            )
          else
            _actionTile(
              theme,
              icon: Icons.block_rounded,
              title: 'Ban User',
              subtitle: 'Revoke access to the platform',
              destructive: true,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                _handleUserAction('ban', user.id, context);
              },
            ),
          _actionTile(
            theme,
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            subtitle: 'Permanently remove this user',
            destructive: true,
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              _handleUserAction('delete', user.id, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool destructive = false,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    final color = destructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: ListTile(
        leading: Icon(icon, size: 20, color: enabled ? color.withValues(alpha: 0.7) : color.withValues(alpha: 0.25)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: enabled ? color : color.withValues(alpha: 0.35),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: enabled
                ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        trailing: enabled
            ? Icon(Icons.chevron_right_rounded, size: 20, color: color.withValues(alpha: 0.4))
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        visualDensity: VisualDensity.compact,
        enabled: enabled,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  SORT
  // ─────────────────────────────────────────────────────────────

  void _onSort(String column, bool asc) {
    setState(() {
      _sortBy = column;
      _sortOrder = asc ? 'asc' : 'desc';
    });
    _search();
  }

  // ─────────────────────────────────────────────────────────────
  //  ACTIONS
  // ─────────────────────────────────────────────────────────────

  void _handleUserAction(String action, int userId, BuildContext context) async {
    final admin = context.read<UserManagementProvider>();
    try {
      switch (action) {
        case 'promote':
          await admin.updateUserRole(userId, 'admin');
          if (context.mounted) _showSnack(context, 'User promoted to admin');
          break;
        case 'demote':
          await admin.updateUserRole(userId, 'user');
          if (context.mounted) _showSnack(context, 'User demoted to member');
          break;
        case 'ban':
          final confirm = await _confirmDialog(context, 'Ban this user?', 'They will lose access to the platform until unbanned.', destructive: true);
          if (confirm == true) {
            await admin.toggleBanUser(userId, true);
            if (context.mounted) _showSnack(context, 'User banned');
          }
          break;
        case 'unban':
          final confirm = await _confirmDialog(context, 'Unban this user?', 'They will regain access to the platform.');
          if (confirm == true) {
            await admin.toggleBanUser(userId, false);
            if (context.mounted) _showSnack(context, 'User unbanned');
          }
          break;
        case 'delete':
          final confirm = await _confirmDialog(
            context,
            'Delete this user?',
            'This action cannot be undone. All their data including reviews, favorites, and history will be permanently removed.',
            destructive: true,
          );
          if (confirm == true) {
            await admin.deleteUser(userId);
            if (context.mounted) _showSnack(context, 'User deleted');
          }
          break;
      }
    } catch (e) {
      if (context.mounted) _showSnack(context, 'Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  DIALOGS
  // ─────────────────────────────────────────────────────────────

  Future<bool?> _confirmDialog(
    BuildContext context,
    String title,
    String message, {
    bool destructive = false,
  }) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            if (destructive)
              Icon(Icons.warning_amber_rounded, size: 22, color: theme.colorScheme.error),
            if (destructive) const SizedBox(width: 10),
            Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(message, style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
            style: TextButton.styleFrom(foregroundColor: destructive ? theme.colorScheme.error : null),
            child: Text(
              destructive ? 'Delete' : 'Confirm',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHIMMER ANIMATION WIDGET
// ─────────────────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  final Widget child;
  const _ShimmerCard({required this.child});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Opacity(opacity: _animation.value, child: child),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SORT BUTTON
// ─────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  final String sortBy;
  final String sortOrder;
  final void Function(String sortBy, String sortOrder) onChanged;

  const _SortButton({
    required this.sortBy,
    required this.sortOrder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      icon: Icon(
        sortOrder == 'asc' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        size: 18,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
      ),
      tooltip: 'Sort by ${sortBy.replaceAll('_', ' ')} (${sortOrder == 'asc' ? 'ascending' : 'descending'})',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      elevation: 4,
      onSelected: (value) {
        if (value == 'toggle_order') {
          onChanged(sortBy, sortOrder == 'asc' ? 'desc' : 'asc');
        } else {
          onChanged(value, sortOrder);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'name',
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha_rounded, size: 18, color: sortBy == 'name' ? theme.colorScheme.primary : null),
              const SizedBox(width: 10),
              Text('Name', style: GoogleFonts.inter(fontSize: 13, fontWeight: sortBy == 'name' ? FontWeight.w600 : FontWeight.w400)),
              if (sortBy == 'name') ...[
                const Spacer(),
                Icon(sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: 'email',
          child: Row(
            children: [
              Icon(Icons.email_rounded, size: 18, color: sortBy == 'email' ? theme.colorScheme.primary : null),
              const SizedBox(width: 10),
              Text('Email', style: GoogleFonts.inter(fontSize: 13, fontWeight: sortBy == 'email' ? FontWeight.w600 : FontWeight.w400)),
              if (sortBy == 'email') ...[
                const Spacer(),
                Icon(sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
              ],
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'toggle_order',
          child: Row(
            children: [
              Icon(Icons.swap_vert_rounded, size: 18),
              const SizedBox(width: 10),
              Text(sortOrder == 'asc' ? 'Sort Descending' : 'Sort Ascending', style: GoogleFonts.inter(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
