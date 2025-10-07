import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextInputWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final String? errorText;
  final String? helperText;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final bool showCharacterCount;

  const CustomTextInputWidget({
    Key? key,
    this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.focusNode,
    this.errorText,
    this.helperText,
    this.onTap,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius = 12.0,
    this.showCharacterCount = false,
  }) : super(key: key);

  @override
  State<CustomTextInputWidget> createState() => _CustomTextInputWidgetState();
}

class _CustomTextInputWidgetState extends State<CustomTextInputWidget> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Color _getBorderColor() {
    if (widget.errorText != null) {
      return Colors.red[400]!;
    }
    if (_isFocused) {
      return widget.focusedBorderColor ?? const Color(0xFFA60069);
    }
    return widget.borderColor ?? Colors.grey[300]!;
  }

  Color _getFillColor() {
    if (!widget.enabled) {
      return Colors.grey[50]!;
    }
    return widget.fillColor ?? Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              children: [
                TextSpan(text: widget.labelText),
                if (widget.validator != null)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _getBorderColor(),
              width: _isFocused ? 2 : 1.5,
            ),
            color: _getFillColor(),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color:
                          (widget.focusedBorderColor ?? const Color(0xFFA60069))
                              .withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onEditingComplete: widget.onEditingComplete,
            onFieldSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            onTap: widget.onTap,
            style: TextStyle(
              fontSize: 14,
              color: widget.enabled ? Colors.grey[800] : Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
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
                      child: IconTheme(
                        data: IconThemeData(
                          color: _isFocused
                              ? (widget.focusedBorderColor ??
                                    const Color(0xFFA60069))
                              : Colors.grey[500],
                          size: 20,
                        ),
                        child: widget.prefixIcon!,
                      ),
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              prefixIconConstraints: widget.prefixIcon != null
                  ? const BoxConstraints(minWidth: 0, minHeight: 0)
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              contentPadding:
                  widget.contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: widget.prefixIcon != null ? 8 : 16,
                    vertical: widget.maxLines == 1 ? 14 : 12,
                  ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              counterText: widget.showCharacterCount ? null : '',
              errorMaxLines: 2,
            ),
          ),
        ),

        // Error text
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 16, color: Colors.red[400]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[400],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],

        // Helper text
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],

        // Character count
        if (widget.showCharacterCount && widget.maxLength != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    List<Widget> suffixWidgets = [];

    // Password visibility toggle
    if (widget.obscureText) {
      suffixWidgets.add(
        GestureDetector(
          onTap: _togglePasswordVisibility,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    // Clear button
    if (widget.enabled &&
        !widget.readOnly &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty &&
        _isFocused) {
      suffixWidgets.add(
        GestureDetector(
          onTap: () {
            widget.controller!.clear();
            widget.onChanged?.call('');
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.clear, size: 18, color: Colors.grey[500]),
          ),
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      suffixWidgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 8),
          child: IconTheme(
            data: IconThemeData(
              color: _isFocused
                  ? (widget.focusedBorderColor ?? const Color(0xFFA60069))
                  : Colors.grey[500],
              size: 20,
            ),
            child: widget.suffixIcon!,
          ),
        ),
      );
    }

    if (suffixWidgets.isEmpty) return null;

    if (suffixWidgets.length == 1) {
      return suffixWidgets.first;
    }

    return Row(mainAxisSize: MainAxisSize.min, children: suffixWidgets);
  }
}

// Specialized text input widgets
class SearchTextInputWidget extends CustomTextInputWidget {
  const SearchTextInputWidget({
    Key? key,
    TextEditingController? controller,
    String labelText = '',
    String hintText = 'Pesquisar...',
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    bool enabled = true,
  }) : super(
         key: key,
         controller: controller,
         labelText: labelText,
         hintText: hintText,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         onEditingComplete: onEditingComplete,
         enabled: enabled,
         prefixIcon: const Icon(Icons.search),
         textInputAction: TextInputAction.search,
       );
}

class PhoneTextInputWidget extends CustomTextInputWidget {
  const PhoneTextInputWidget({
    Key? key,
    TextEditingController? controller,
    String labelText = 'Telefone',
    String hintText = '(00) 00000-0000',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) : super(
         key: key,
         controller: controller,
         labelText: labelText,
         hintText: hintText,
         onChanged: onChanged,
         validator: validator,
         enabled: enabled,
         keyboardType: TextInputType.phone,
         prefixIcon: const Icon(Icons.phone),
       );
}

class EmailTextInputWidget extends CustomTextInputWidget {
  const EmailTextInputWidget({
    Key? key,
    TextEditingController? controller,
    String labelText = 'E-mail',
    String hintText = 'seu@email.com',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) : super(
         key: key,
         controller: controller,
         labelText: labelText,
         hintText: hintText,
         onChanged: onChanged,
         validator: validator ?? _defaultEmailValidator,
         enabled: enabled,
         keyboardType: TextInputType.emailAddress,
         prefixIcon: const Icon(Icons.email),
         textInputAction: TextInputAction.next,
       );

  static String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Digite um e-mail válido';
    }
    return null;
  }
}

class PasswordTextInputWidget extends CustomTextInputWidget {
  const PasswordTextInputWidget({
    Key? key,
    TextEditingController? controller,
    String labelText = 'Senha',
    String hintText = 'Digite sua senha',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) : super(
         key: key,
         controller: controller,
         labelText: labelText,
         hintText: hintText,
         onChanged: onChanged,
         validator: validator,
         enabled: enabled,
         obscureText: true,
         prefixIcon: const Icon(Icons.lock),
         textInputAction: TextInputAction.done,
       );
}

// Custom input formatter for phone numbers
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length <= 10) {
      // Format as (XX) XXXX-XXXX
      String formatted = '';
      if (text.isNotEmpty) {
        formatted = '(${text.substring(0, text.length >= 2 ? 2 : text.length)}';
        if (text.length >= 3) {
          formatted +=
              ') ${text.substring(2, text.length >= 6 ? 6 : text.length)}';
          if (text.length >= 7) {
            formatted += '-${text.substring(6)}';
          }
        }
      }
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      // Format as (XX) XXXXX-XXXX
      String formatted = '';
      if (text.isNotEmpty) {
        formatted =
            '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7, 11)}';
      }
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}
