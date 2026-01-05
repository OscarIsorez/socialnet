import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/search_filters.dart';
import '../../bloc/search/search_bloc.dart';
import '../../widgets/event/event_card.dart';
import '../../widgets/search/filter_bottom_sheet.dart';
import '../../widgets/search/quick_action_chips.dart';
import '../../widgets/search/user_search_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    // Rebuild to show/hide clear button
    setState(() {});

    if (_searchController.text.isEmpty) {
      setState(() => _isSearching = false);
      context.read<SearchBloc>().add(const ClearSearchResultsRequested());
      return;
    }

    // Debounce search to avoid excessive API calls
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    FocusScope.of(context).unfocus();

    // Search both events and users simultaneously
    context.read<SearchBloc>().add(
      SearchEventsRequested(
        query: query,
        filters: context.read<SearchBloc>().state.filters,
      ),
    );
    context.read<SearchBloc>().add(SearchUsersRequested(query));
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
        if (mounted) {
          context.read<SearchBloc>().add(
            FilterEventsRequested(currentFilters!),
          );
        }
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search events and users...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
          ],
        ),
        actions: [
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
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                FocusScope.of(context).unfocus();
              },
            ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return Column(
            children: [
              // Show quick actions when not searching and no filters applied
              if (!_isSearching && !state.hasFilters)
                QuickActionChips(onCategorySelected: _onQuickActionSelected),
              Expanded(child: _buildSearchResults()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
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
                  'Search for events and users',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final hasEvents = state.events.isNotEmpty;
        final hasUsers = state.users.isNotEmpty;

        if (!hasEvents && !hasUsers) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No results found',
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

        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            if (hasEvents) ...[
              if (hasUsers) _buildSectionHeader('Events'),
              ...state.events.map((event) => EventCard(event: event)),
            ],
            if (hasUsers) ...[
              if (hasEvents) const SizedBox(height: 16),
              if (hasEvents) _buildSectionHeader('Users'),
              ...state.users.map((user) => UserSearchCard(user: user)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
