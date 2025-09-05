import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShowImage extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  final String text;
  final bool isAsset; // Flag to determine if it's a local asset image
  final bool isFile; // Flag to determine if it's a file image

  const ShowImage({
    super.key,
    this.image = "",
    this.height = 50.0,
    this.width = 50.0,
    this.text = "",
    this.isAsset = false,
    this.isFile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (image.isNotEmpty) {
      if (isAsset) {
        return _buildCircularImage(AssetImage(image));
      } else if (isFile) {
        return _buildCircularImage(FileImage(File(image)));
      } else {
        return _buildNetworkImage(theme, height, width);
      }
    } else {
      return _buildTextAbbreviation(theme);
    }
  }

  Widget _buildNetworkImage(ThemeData theme, height, width) {
    return CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: width,
      fit: BoxFit.cover,
      imageBuilder: (context, imageProvider) =>
          _buildCircularImage(imageProvider),
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => _buildTextAbbreviation(theme),
    );
  }

  Widget _buildCircularImage(ImageProvider imageProvider) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTextAbbreviation(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withOpacity(0.2),
      ),
      child: Text(
        _getAbbreviation(text),
        style: theme.textTheme.titleLarge!.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14, // Adjust font size for better readability
        ),
      ),
    );
  }

  String _getAbbreviation(String text) {
    if (text.isEmpty) return "";
    final words = text.split(" ");
    return words.length == 1
        ? words.first[0].toUpperCase()
        : words
            .map((word) => word.isEmpty ? "" : word[0])
            .take(2)
            .join()
            .toUpperCase();
  }
}
