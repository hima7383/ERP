import 'package:flutter/material.dart';

class OrientationAwareDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? statusWidget;
  final int tabCount;
  final List<String> tabLabels;
  final List<Widget> tabViews;
  final bool showCloseButton;
  final double? fixedHeight;
  final double? horizontalInsetPercentage;
  final EdgeInsets? contentPadding;
  final List<Widget>? customActions;
  final IconData? headerIcon;
  final ScrollPhysics? scrollPhysics;
  final Color? backgroundColor;
  final Color? headerColor;
  final bool forceLightTheme;
  final bool shrinkWrapContent;
  final double? maxWidth;

  const OrientationAwareDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.statusWidget,
    required this.tabCount,
    required this.tabLabels,
    required this.tabViews,
    this.showCloseButton = true,
    this.fixedHeight,
    this.horizontalInsetPercentage,
    this.contentPadding,
    this.customActions,
    this.headerIcon,
    this.scrollPhysics,
    this.backgroundColor,
    this.headerColor,
    this.forceLightTheme = false,
    this.shrinkWrapContent = false,
    this.maxWidth,
  }) : assert(tabLabels.length == tabCount && tabViews.length == tabCount);

  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? statusWidget,
    required int tabCount,
    required List<String> tabLabels,
    required List<Widget> tabViews,
    bool showCloseButton = true,
    double? fixedHeight,
    double? horizontalInsetPercentage = 0.03,
    EdgeInsets? contentPadding,
    List<Widget>? customActions,
    IconData? headerIcon,
    ScrollPhysics? scrollPhysics,
    Color? backgroundColor,
    Color? headerColor,
    bool forceLightTheme = false,
    bool shrinkWrapContent = false,
    double? maxWidth,
  }) {
    showDialog(
      context: context,
      builder: (context) => OrientationAwareDialog(
        title: title,
        subtitle: subtitle,
        statusWidget: statusWidget,
        tabCount: tabCount,
        tabLabels: tabLabels,
        tabViews: tabViews,
        showCloseButton: showCloseButton,
        fixedHeight: fixedHeight,
        horizontalInsetPercentage: horizontalInsetPercentage,
        contentPadding: contentPadding,
        customActions: customActions,
        headerIcon: headerIcon,
        scrollPhysics: scrollPhysics,
        backgroundColor: backgroundColor,
        headerColor: headerColor,
        forceLightTheme: forceLightTheme,
        shrinkWrapContent: shrinkWrapContent,
        maxWidth: maxWidth,
      ),
    );
  }

  @override
  State<OrientationAwareDialog> createState() => _OrientationAwareDialogState();
}

class _OrientationAwareDialogState extends State<OrientationAwareDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getTextColor(bool isLightTheme) {
    return isLightTheme ? Colors.black : Colors.white;
  }

  Color _getSubtitleColor(bool isLightTheme) {
    return isLightTheme ? Colors.grey[700]! : Colors.grey[400]!;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isLightTheme = widget.forceLightTheme ||
        widget.backgroundColor == Colors.white ||
        Theme.of(context).brightness == Brightness.light;

    return Dialog(
      backgroundColor: widget.backgroundColor ?? Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: widget.horizontalInsetPercentage != null
            ? screenWidth * widget.horizontalInsetPercentage!
            : screenWidth * 0.03,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.shrinkWrapContent
              ? double.infinity
              : widget.fixedHeight ??
                  (isLandscape ? screenHeight * 0.75 : screenHeight * 0.85),
          maxWidth: widget.maxWidth ?? (isLandscape ? screenWidth * 0.8 : 500),
          minWidth: 280,
        ),
        child: Column(
          mainAxisSize:
              widget.shrinkWrapContent ? MainAxisSize.min : MainAxisSize.max,
          children: [
            // Header
            // Compact Header
            Container(
              padding: EdgeInsets.fromLTRB(12, 8, 12,
                  8), // Reduced padding (LTRB: Left, Top, Right, Bottom)
              decoration: BoxDecoration(
                color: widget.headerColor ??
                    (isLightTheme ? Colors.grey[200] : Colors.black),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Takes minimum vertical space
                children: [
                  Row(
                    children: [
                      if (widget.headerIcon != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 6), // Reduced icon spacing
                          child: Icon(
                            widget.headerIcon,
                            color: _getTextColor(isLightTheme),
                            size: 18, // Slightly smaller icon
                          ),
                        ),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16, // Reduced from 18
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(isLightTheme),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (widget.subtitle != null || widget.statusWidget != null)
                    SizedBox(height: 4), // Reduced spacing
                  if (widget.subtitle != null || widget.statusWidget != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Better vertical alignment
                      children: [
                        if (widget.subtitle != null)
                          Flexible(
                            child: Text(
                              widget.subtitle!,
                              style: TextStyle(
                                color: _getSubtitleColor(isLightTheme),
                                fontSize: 12, // Reduced from 14
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (widget.statusWidget != null)
                          Transform.scale(
                            scale: 0.9, // Slightly scale down status widget
                            child: widget.statusWidget!,
                          ),
                      ],
                    ),
                ],
              ),
            ),

            // Tabs
            if (widget.tabCount > 1)
              Container(
                height: 48,
                color: widget.headerColor ??
                    (isLightTheme ? Colors.grey[200] : Colors.black),
                child: TabBar(
                  controller: _tabController,
                  labelColor: _getTextColor(isLightTheme),
                  unselectedLabelColor:
                      isLightTheme ? Colors.grey[600] : Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: widget.tabLabels
                      .map((label) => Tab(text: label))
                      .toList(),
                ),
              ),

            // Content Area
            if (widget.shrinkWrapContent)
              Flexible(
                child: SingleChildScrollView(
                  physics:
                      widget.scrollPhysics ?? const ClampingScrollPhysics(),
                  child: Padding(
                    padding: widget.contentPadding ?? EdgeInsets.all(12),
                    child: widget.tabCount > 1
                        ? SizedBox(
                            height: widget.fixedHeight,
                            child: TabBarView(
                              controller: _tabController,
                              children: widget.tabViews,
                            ),
                          )
                        : widget.tabViews.first,
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: widget.contentPadding ?? EdgeInsets.all(12),
                  child: widget.tabCount > 1
                      ? TabBarView(
                          controller: _tabController,
                          physics: widget.scrollPhysics,
                          children: widget.tabViews,
                        )
                      : SingleChildScrollView(
                          physics: widget.scrollPhysics,
                          child: widget.tabViews.first,
                        ),
                ),
              ),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.only(
                  right: 8, bottom: 8, top: 4), // Reduced padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min, // Takes minimum space needed
                children: [
                  if (widget.customActions != null) ...widget.customActions!,
                  if (widget.showCloseButton)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12), // More compact button
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // Reduces touch area
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CLOSE',
                        style: TextStyle(
                          color: isLightTheme ? Colors.blue : Colors.white,
                          fontSize: 14, // Slightly smaller text
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
