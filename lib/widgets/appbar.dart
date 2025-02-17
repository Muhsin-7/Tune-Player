import 'package:flutter/material.dart';

import 'colors.dart';


class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final List<Widget>? actions;
  final Color backgroundColor;
  final ValueChanged<String>? onSearchChanged; // Callback for search text changes
  final VoidCallback? onSearchClosed; // Callback when search is closed

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.actions,
    this.backgroundColor = AppColors.primaryColor,
    this.onSearchChanged,
    this.onSearchClosed, required bool automaticimply,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: widget.onSearchChanged, // Call the search callback
            )
          : Text(
              widget.title,
              style: const TextStyle(color: Colors.white),
            ),
      leading: widget.leading,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      backgroundColor: widget.backgroundColor,
      centerTitle: widget.centerTitle,
      actions: [
        if (widget.actions != null) ...widget.actions!,
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _searchController.clear();
                widget.onSearchClosed?.call(); // Notify when search is closed
              }
              _isSearching = !_isSearching;
            });
          },
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

