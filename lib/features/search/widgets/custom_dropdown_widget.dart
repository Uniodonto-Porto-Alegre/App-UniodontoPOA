import 'package:flutter/material.dart';

class CustomDropdownWidget<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String labelText;
  final String hintText;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final Widget? prefixIcon;
  final String? Function(T?)? validator;

  const CustomDropdownWidget({
    Key? key,
    required this.value,
    required this.items,
    required this.labelText,
    required this.hintText,
    required this.onChanged,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty) ...[
          Text(
            labelText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            color: enabled ? Colors.white : Colors.grey[50],
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: enabled ? Colors.grey[800] : Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: prefixIcon,
                    )
                  : null,
              prefixIconConstraints: prefixIcon != null
                  ? const BoxConstraints(minWidth: 0, minHeight: 0)
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: prefixIcon != null ? 8 : 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
            ),
            icon: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: enabled ? const Color(0xFFA60069) : Colors.grey[400],
                size: 24,
              ),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w400,
            ),
            isExpanded: true,
            menuMaxHeight: 300,
          ),
        ),
      ],
    );
  }
}

// Alternative version with search functionality
class CustomSearchableDropdownWidget<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String labelText;
  final String hintText;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final Widget? prefixIcon;
  final String? Function(T?)? validator;
  final String Function(T) itemAsString;

  const CustomSearchableDropdownWidget({
    Key? key,
    required this.value,
    required this.items,
    required this.labelText,
    required this.hintText,
    required this.onChanged,
    required this.itemAsString,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomSearchableDropdownWidget<T>> createState() =>
      _CustomSearchableDropdownWidgetState<T>();
}

class _CustomSearchableDropdownWidgetState<T>
    extends State<CustomSearchableDropdownWidget<T>> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(_handleFocusChange);
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return widget.itemAsString(item).toLowerCase().contains(query);
      }).toList();
    });
    _updateOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _removeOverlay();
    if (_focusNode.hasFocus) {
      _showOverlay();
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: _filteredItems.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Nenhum item encontrado',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = widget.value == item;

                        return InkWell(
                          onTap: () {
                            widget.onChanged(item);
                            _searchController.text = widget.itemAsString(item);
                            _focusNode.unfocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            color: isSelected
                                ? const Color(0xFFA60069).withOpacity(0.1)
                                : null,
                            child: Text(
                              widget.itemAsString(item),
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? const Color(0xFFA60069)
                                    : Colors.grey[800],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty) ...[
          Text(
            widget.labelText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? const Color(0xFFA60069)
                    : Colors.grey[300]!,
                width: _focusNode.hasFocus ? 2 : 1.5,
              ),
              color: widget.enabled ? Colors.white : Colors.grey[50],
            ),
            child: TextFormField(
              controller: _searchController,
              focusNode: _focusNode,
              enabled: widget.enabled,
              validator: widget.validator != null
                  ? (value) => widget.validator!(widget.value)
                  : null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: widget.prefixIcon,
                      )
                    : null,
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.search,
                    color: widget.enabled
                        ? const Color(0xFFA60069)
                        : Colors.grey[400],
                    size: 20,
                  ),
                ),
                prefixIconConstraints: widget.prefixIcon != null
                    ? const BoxConstraints(minWidth: 0, minHeight: 0)
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.prefixIcon != null ? 8 : 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
              ),
              style: TextStyle(
                fontSize: 14,
                color: widget.enabled ? Colors.grey[800] : Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
