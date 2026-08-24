import 'package:flutter/material.dart';

/// Named `BlogSearchBar` (not `SearchBar`) to avoid clashing with the
/// built-in Material `SearchBar` widget from flutter/material.dart.
class BlogSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const BlogSearchBar({super.key, required this.onChanged});

  @override
  State<BlogSearchBar> createState() => _BlogSearchBarState();
}

class _BlogSearchBarState extends State<BlogSearchBar> {
  final controller = TextEditingController();

  void clear() {
    controller.clear();
    widget.onChanged('');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search blogs...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: clear,
              );
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
