import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/category.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../../controllers/search_controller.dart';
import '../../main.dart';
import 'category_view.dart';

class GridCategoryView extends StatelessWidget {
  final BrowseController searchController = Get.find<BrowseController>();
  final TextEditingController controller = TextEditingController();
  final RxInt sortIndex = 0.obs;

  GridCategoryView({super.key}); // 0: Recommended, 1: Popular, 2: A–Z

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // choose list based on sort
      final List<ProductCategory> data = () {
        if (sortIndex.value == 1) {
          final x = [...productController.categories];
          x.sort(
              (a, b) => (b.viewersCount ?? 0).compareTo(a.viewersCount ?? 0));
          return x;
        }
        if (sortIndex.value == 2) {
          final x = [...productController.categories];
          x.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
          return x;
        }
        return productController.categories;
      }();

      if (data.isEmpty) {
        return NoItems();
      }

      return _ExpandableGrid(
        categories: data,
        expanded: productController.expanded.value,
        onExpand: (c) => c.sub!.isEmpty
            ? Get.to(() => CategoryView(category: c))
            : productController.expanded.value = c,
        onCollapse: () => productController.expanded.value = null,
      );
    });
  }
}

class _ExpandableGrid extends StatelessWidget {
  const _ExpandableGrid({
    required this.categories,
    required this.expanded,
    required this.onExpand,
    required this.onCollapse,
  });
  final List<ProductCategory> categories;
  final ProductCategory? expanded;
  final ValueChanged<ProductCategory> onExpand;
  final VoidCallback onCollapse;
  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 3;
    final int? expandedIndex = expanded == null
        ? null
        : categories.indexWhere((c) => c.name == expanded!.name);
    final int rowEndExclusive = (expandedIndex == null)
        ? crossAxisCount.clamp(0, categories.length)
        : (((expandedIndex ~/ crossAxisCount) + 1) * crossAxisCount)
            .clamp(0, categories.length);
    final firstRowItems = categories.take(rowEndExclusive).toList();
    final restItems = categories.skip(rowEndExclusive).toList();
    SliverGrid grid(List<ProductCategory> items) => SliverGrid.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 14,
            mainAxisExtent: 180,
          ),
          itemBuilder: (_, i) {
            final item = items[i];
            final isHL = expanded?.name == item.name;
            return CategoryTile(
              category: item,
              isHighlighted: isHL,
              onTap: () => isHL ? onCollapse() : onExpand(item),
            );
          },
        );
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 10, 16, 0),
          sliver: grid(firstRowItems),
        ),
        if (expanded != null && (expanded!.sub?.isNotEmpty ?? false))
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 6, 16, 6),
            sliver: SliverList.separated(
              // 👇 add 1 to length for the "All {Category}" option
              itemCount: expanded!.sub!.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  // First item = "All {Category}"
                  return ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    leading: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(expanded!.iconUrl(),
                            fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(
                        "all_category".trParams({"category": expanded!.name!}),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.equalizer_rounded,
                            size: 16, color: Colors.pinkAccent),
                        const SizedBox(width: 6),
                        Text(
                            'viewers'.trParams({
                              'count':
                                  _formatViewers(expanded!.viewersCount ?? 0)
                            }), //'${_formatViewers(sub.viewersCount ?? 0)} Viewers',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    onTap: () =>
                        Get.to(() => CategoryView(category: expanded!)),
                  );
                } else {
                  // Normal subcategory tiles
                  return _SubcategoryTile(expanded!.sub![i - 1]);
                }
              },
              separatorBuilder: (_, __) =>
                  const Divider(height: 0, thickness: 0.2, color: Colors.grey),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          sliver: grid(restItems),
        ),
      ],
    );
  }
}

class _SubcategoryTile extends StatelessWidget {
  const _SubcategoryTile(this.sub, {super.key});
  final ProductCategory sub;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            sub.iconUrl(),
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: Text(sub.name ?? "",
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Row(
        children: [
          const Icon(Icons.equalizer_rounded,
              size: 16, color: Colors.pinkAccent),
          const SizedBox(width: 6),
          Text(
              'viewers'.trParams({
                'count': _formatViewers(sub.viewersCount ?? 0)
              }), //'${_formatViewers(sub.viewersCount ?? 0)} Viewers',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
      onTap: () {
        Get.to(() => CategoryView(category: sub));
      },
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    this.onTap,
    this.isHighlighted = false,
  });

  final ProductCategory category;
  final VoidCallback? onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final List<Color> bg = isHighlighted
        ? [Colors.yellow, Colors.amber]
        : [
            Theme.of(context).colorScheme.onSecondaryContainer,
            Theme.of(context).colorScheme.onSecondaryContainer
          ];
    final bool darkText = isHighlighted;

    final card = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bg,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: darkText
                    ? Colors.black
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    category.iconUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image,
                      size: 20.sp,
                      color: darkText
                          ? Colors.black54
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            _ViewersPill(
                viewers: category.viewersCount ?? 0, darkText: darkText),
          ],
        ),
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Stack(
        children: [
          card,
          if (isHighlighted)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: Colors.white, width: 3), // outer white border
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.black, width: 2)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewersPill extends StatelessWidget {
  const _ViewersPill({required this.viewers, this.darkText = false});
  final int viewers;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (darkText
                  ? Colors.black
                  : Theme.of(context).colorScheme.onSurface)
              .withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.equalizer_rounded,
                size: 12, color: darkText ? Colors.black : Colors.red),
            const SizedBox(width: 4),
            Text(
              "viewers".trParams({'count': _formatViewers(viewers)}),
              style: textStyle,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatViewers(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K';
  return '$v';
}
