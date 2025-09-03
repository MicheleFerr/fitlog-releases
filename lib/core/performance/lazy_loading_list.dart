import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Optimized list view with lazy loading and performance improvements
class LazyLoadingList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget Function()? loadingBuilder;
  final Widget Function()? emptyBuilder;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int cacheExtent;
  final int itemsPerBatch;

  const LazyLoadingList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.cacheExtent = 250,
    this.itemsPerBatch = 20,
  });

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  final Set<int> _visibleIndices = {};
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || _isLoadingMore || widget.onLoadMore == null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // Load more when 80% scrolled
    if (currentScroll >= maxScroll * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.emptyBuilder != null) {
      return widget.emptyBuilder!();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      cacheExtent: widget.cacheExtent.toDouble(),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index == widget.items.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: widget.loadingBuilder?.call() ??
                  const CircularProgressIndicator.adaptive(),
            ),
          );
        }

        // Use visibility detector for heavy items
        if (index < widget.itemsPerBatch) {
          // First batch - render immediately
          return widget.itemBuilder(context, widget.items[index], index);
        }

        // Lazy load items after first batch
        return VisibilityDetector(
          key: Key('item_$index'),
          onVisibilityChanged: (info) {
            if (info.visibleFraction > 0) {
              _visibleIndices.add(index);
            } else {
              _visibleIndices.remove(index);
            }
          },
          child: AnimatedBuilder(
            animation: _scrollController,
            builder: (context, child) {
              // Only build if visible or near visible area
              final position = _scrollController.hasClients
                  ? _scrollController.position
                  : null;
              
              if (position != null) {
                final viewport = position.viewportDimension;
                final scrollOffset = position.pixels;
                final itemPosition = index * 80.0; // Estimated item height
                
                // Check if item is in or near viewport
                final isNearViewport = 
                    itemPosition >= scrollOffset - viewport &&
                    itemPosition <= scrollOffset + viewport * 2;
                
                if (!isNearViewport && !_visibleIndices.contains(index)) {
                  // Return placeholder for off-screen items
                  return SizedBox(
                    height: 80.0,
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  );
                }
              }
              
              return widget.itemBuilder(context, widget.items[index], index);
            },
          ),
        );
      },
    );
  }
}

/// Optimized grid view with lazy loading
class LazyLoadingGrid<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;

  const LazyLoadingGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding,
    this.controller,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  State<LazyLoadingGrid<T>> createState() => _LazyLoadingGridState<T>();
}

class _LazyLoadingGridState<T> extends State<LazyLoadingGrid<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || _isLoadingMore || widget.onLoadMore == null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (currentScroll >= maxScroll * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              childAspectRatio: widget.childAspectRatio,
              crossAxisSpacing: widget.crossAxisSpacing,
              mainAxisSpacing: widget.mainAxisSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => widget.itemBuilder(
                context,
                widget.items[index],
                index,
              ),
              childCount: widget.items.length,
            ),
          ),
        ),
        if (widget.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator.adaptive()
                    : const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}