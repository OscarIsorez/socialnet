import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _tabController.index == 0
                      ? 'Search events...'
                      : 'Search users...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
          ],
        ),
        actions: [
          if (_tabController.index == 0)
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return IconButton(
                  icon: Badge(
                    isLabelVisible: state.hasFilters,
                    child: const Icon(Icons.filter_list),
                  ),
                  onPressed: _showFilterBottomSheet,
                );
              },
            ),
          IconButton(icon: const Icon(Icons.search), onPressed: _performSearch),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Users'),
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
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  state.message ?? 'An error occurred',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: const Text('Try Again'),
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
