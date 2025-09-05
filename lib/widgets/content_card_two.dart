import 'package:flutter/material.dart';

class ContentCardTwo extends StatelessWidget {
  String title;
  IconData? icon;
  IconData? icon2;
  Color? backgroundColor;
  Color? iconColor;
  String? content;
  Widget? rightWidget;
  Function() onEdit;
  double radius = 10;
  ContentCardTwo({
    super.key,
    required this.title,
    this.iconColor,
    this.icon,
    this.backgroundColor,
    this.icon2,
    this.rightWidget,
    this.content,
    required this.onEdit,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        onEdit();
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ??
              Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon,
                  size: 28,
                  color: iconColor ?? Theme.of(context).colorScheme.primary),
            if (icon != null) SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (content != null) SizedBox(height: 4),
                  if (content != null)
                    Text(
                      content ?? "",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                ],
              ),
            ),
            rightWidget != null
                ? rightWidget!
                : Icon(icon2 ?? Icons.edit,
                    color: iconColor ?? Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
