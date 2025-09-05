import 'package:flutter/material.dart';

class SearchLayout extends StatefulWidget {
  Function function;
  String? searchHint;
  EdgeInsets? padding;
  EdgeInsets? margin;
  Function? onTap;
  FocusNode? focusNode;
  TextEditingController? controller;
  double? height;
  SearchLayout(
      {super.key,
      required this.function,
      this.onTap,
      this.focusNode,
      this.controller,
      this.padding,
      this.searchHint = "Search",
      this.margin,
      this.height = 80});

  @override
  State<SearchLayout> createState() => _SearchLayoutState();
}

class _SearchLayoutState extends State<SearchLayout> {
  TextEditingController searchText = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
      margin: widget.margin ?? EdgeInsets.only(top: 20),
      child: SizedBox(
        height: widget.height ?? 80,
        child: TextField(
          onTap: () {
            widget.focusNode?.requestFocus();
            if (widget.onTap != null) {
              widget.onTap!(); //Lick
            }
          },
          controller: widget.controller ?? searchText,
          focusNode: widget.focusNode,
          onChanged: (value) {
            widget.function(value);
            setState(() {});
          },
          // readOnly: widget.onTap == null ? false : true,
          decoration: InputDecoration(
            hintText: widget.searchHint,
            hintStyle: TextStyle(color: theme.hintColor),
            prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
            suffixIcon: searchText.text.isNotEmpty
                ? InkWell(
                    onTap: () {
                      searchText.clear();
                      setState(() {});
                      widget.function("");
                    },
                    child: Icon(Icons.clear, color: theme.iconTheme.color))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.red),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
        ),
      ),
    );
  }
}
