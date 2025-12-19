import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/search_filters.dart';
import '../../bloc/search/search_bloc.dart';
import '../../widgets/search/event_search_card.dart';
import '../../widgets/search/filter_bottom_sheet.dart';
import '../../widgets/search/quick_action_chips.dart';
import '../../widgets/search/user_search_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Rebuild to update filter button visibility and hint text
      setState(() {});
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty && _isSearching) {
      setState(() => _isSearching = false);
      context.read<SearchBloc>().add(const ClearSearchResultsRequested());
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    FocusScope.of(context).unfocus();

    if (_tabController.index == 0) {
      // Search events
      context.read<SearchBloc>().add(
        SearchEventsRequested(
          query: query,
          filters: context.read<SearchBloc>().state.filters,
        ),
      );
    } else {
      // Search users
      context.read<SearchBloc>().add(SearchUsersRequested(query));
    }
  }

  void _showFilterBottomSheet() {
    final previousFilters = context.read<SearchBloc>().state.filters;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<SearchBloc>(),
        child: const FilterBottomSheet(),
      ),
    ).then((_) {
      if (!mounted) return;
      final currentFilters = context.read<SearchBloc>().state.filters;

      // Re-search if there was a query and filters changed
      if (_searchController.text.isNotEmpty) {
        _performSearch();
      } else if (currentFilters?.hasFilters == true) {
        // If no query but filters were applied, trigger filter search
        context.read<SearchBloc>().add(FilterEventsRequested(currentFilters!));
        setState(() => _isSearching = true);
      } else if (previousFilters?.hasFilters == true &&
          currentFilters?.hasFilters != true) {
        // Filters were cleared, reset the search state
        setState(() => _isSearching = false);
      }
    });
  }

  void _onQuickActionSelected(EventCategory category) {
    context.read<SearchBloc>().add(
      FilterEventsRequested(SearchFilters(category: category, isActive: true)),
    );
    setState(() => _isSearching = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _tabController.index == 0
                  ? 'Rechercher des événements...'
                  : 'Rechercher des utilisateurs...',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        actions: [
          if (_tabController.index == 0)
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: IconButton(
                    icon: Badge(
                      isLabelVisible: state.hasFilters,
                      backgroundColor: AppColors.accent,
                      child: const Icon(
                        Icons.filter_list,
                        color: AppColors.primary,
                      ),
                    ),
                    onPressed: _showFilterBottomSheet,
                  ),
                );
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Événements'),
            Tab(text: 'Utilisateurs'),
          ],
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return Column(
            children: [
              // Show quick actions only when on events tab, not searching, and no filters applied
              if (_tabController.index == 0 &&
                  !_isSearching &&
                  !state.hasFilters)
                QuickActionChips(onCategorySelected: _onQuickActionSelected),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildEventsTab(), _buildUsersTab()],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventsTab() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message ?? 'Une erreur s\'est produite',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.buttonPrimary,
                        AppColors.buttonPrimary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Réessayer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (!_isSearching) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Search for events or use quick actions',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (state.events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No events found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try different keywords or filters',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: state.events.length,
          itemBuilder: (context, index) {
            return EventSearchCard(event: state.events[index]);
          },
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  state.message ?? 'An error occurred',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (!_isSearching) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Search for users by name or email',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (state.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            return UserSearchCard(user: state.users[index]);
          },
        );
      },
    );
  }
}
