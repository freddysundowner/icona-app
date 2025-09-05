import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../models/product.dart';
import '../../../utils/helpers.dart';
import '../../inventory/widgets/inshow_budge.dart';

class ProductHomeCard extends StatelessWidget {
  final Product product;

  const ProductHomeCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 0.7,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: product.images!.isEmpty
                  ? Image.asset(
                      "assets/images/image_placeholder.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : CachedNetworkImage(
                      imageUrl: product.images!.first,
                      fit: BoxFit.cover,
                      width: 10),
            ),
          ),
          Positioned.fill(
              child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.25),
                ])),
          )),
          Positioned(
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name!.capitalizeFirst ?? "",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 2),
                  Text(
                    priceHtmlFormat(product.price),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
          ),
          inshowBadge(Theme.of(context), product),
        ],
      ),
    );
  }
}
