import 'package:flutter/material.dart';

class TrendyDialog extends StatelessWidget {
  final String? title;
  final Widget? titleIcon;
  final String? subtitle;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsets? contentPadding;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const TrendyDialog({
    super.key,
    this.title,
    this.titleIcon,
    this.subtitle,
    required this.content,
    this.actions,
    this.contentPadding,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 섹션
            if (title != null || titleIcon != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (titleIcon != null || title != null) ...[
                          Row(
                            children: [
                              if (titleIcon != null) ...[
                                titleIcon!,
                                const SizedBox(width: 12),
                              ],
                              if (title != null)
                                Expanded(
                                  child: Text(
                                    title!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                    if (showCloseButton)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: onClose ?? () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // 콘텐츠 섹션
            Flexible(
              child: Container(
                width: double.infinity,
                padding:
                    contentPadding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: content,
              ),
            ),

            // 액션 버튼 섹션
            if (actions != null && actions!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .asMap()
                      .entries
                      .map(
                        (entry) => entry.key == 0
                            ? entry.value
                            : Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: entry.value,
                              ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 트렌디한 버튼 스타일을 위한 헬퍼 위젯들
class TrendyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;

  const TrendyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
    this.padding,
    this.borderRadius,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(16);

    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: defaultPadding,
          shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
          foregroundColor:
              foregroundColor ?? Theme.of(context).colorScheme.primary,
        ),
        child: child,
      );
    }

    if (gradientColors != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors!),
          borderRadius: defaultBorderRadius,
          boxShadow: [
            BoxShadow(
              color: gradientColors!.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: defaultPadding,
            shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
            foregroundColor: foregroundColor ?? Colors.white,
          ),
          child: child,
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: defaultPadding,
        shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      child: child,
    );
  }
}

class TrendyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final EdgeInsets? contentPadding;

  const TrendyTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            contentPadding ??
            (maxLines != null && maxLines! > 1
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        alignLabelWithHint: maxLines != null && maxLines! > 1,
      ),
    );
  }
}
