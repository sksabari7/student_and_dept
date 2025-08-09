import 'dart:async';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'dart:js_interop';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web/web.dart' as web;

var backendURL = "https://edumanage3033back.builtwithrocket.new/log-inspected-widget";

class CustomWidgetInspector extends StatefulWidget {
  final Widget child;

  const CustomWidgetInspector({Key? key, required this.child})
    : super(key: key);

  @override
  State<CustomWidgetInspector> createState() => _CustomWidgetInspectorState();
}

class _CustomWidgetInspectorState extends State<CustomWidgetInspector> {
  RenderObject? _selectedRenderObject;
  Element? _selectedElement;
  final GlobalKey _childKey = GlobalKey();
  bool isInspectorEnabled = false;
  bool _showWidgetPopup = false;
  Offset _popupPosition = Offset.zero;
  List<Map<String, dynamic>> _availableWidgets = [];
  Offset _lastTapPosition = Offset.zero;
  Timer? _popupTimer;

  // Centralized list of Flutter's built-in widgets
  static const Set<String> flutterBuiltInWidgets = {
    // Basic widgets
    'Container',
    'Row',
    'Column',
    'Stack',
    'Text',
    'RichText',
    'Icon',
    'Image',
    'CircleAvatar',
    'Card',
    'ListTile',
    'Chip',
    'Divider',
    'VerticalDivider',
    'Spacer',
    'SizedBox',
    'Positioned',
    'Center',
    'Align',
    'Expanded',
    'Flexible',
    'Wrap',
    'Flow',
    'Table',
    'IndexedStack',
    'Flex',
    // Input widgets
    'TextField',
    'TextFormField',
    'Checkbox',
    'Radio',
    'Switch',
    'Slider',
    'RangeSlider',
    'DropdownButton',
    'DropdownButtonFormField',
    'PopupMenuButton',
    // Button widgets
    'ElevatedButton',
    'TextButton',
    'OutlinedButton',
    'IconButton',
    'FloatingActionButton',
    'MaterialButton',
    'RawMaterialButton',
    'CupertinoButton',
    'BackButton',
    'CloseButton',
    'InkWell',
    'InkResponse',
    // Layout widgets
    'Scaffold',
    'AppBar',
    'Drawer',
    'BottomNavigationBar',
    'TabBar',
    'TabBarView',
    'PageView',
    'ListView',
    'GridView',
    'CustomScrollView',
    'SingleChildScrollView',
    'NestedScrollView',
    'RefreshIndicator',
    // Dialog widgets
    'Dialog',
    'AlertDialog',
    'SimpleDialog',
    'BottomSheet',
    'SnackBar',
    'Banner',
    'MaterialBanner',
    // Other widgets
    'Hero',
    'Tooltip',
    'ProgressIndicator',
    'LinearProgressIndicator',
    'CircularProgressIndicator',
    'Stepper',
    'ExpansionTile',
    'ExpansionPanel',
    'DataTable',
    'PaginatedDataTable',
    'Dismissible',
    'ReorderableListView',
    'AnimatedList',
    'SliverAnimatedList',
    'CupertinoNavigationBar',
    'CupertinoTabBar',
    'CupertinoScrollbar',
    'CupertinoSlider',
    'CupertinoSwitch',
    'CupertinoSegmentedControl',
    'CupertinoActionSheet',
    'CupertinoAlertDialog',
    'CupertinoDatePicker',
    'CupertinoTimerPicker',
    'CupertinoPicker',
    'Form',
    'FormField',
  };

  // Centralized list of wrapper widgets that should never appear in popup
  static const Set<String> wrapperWidgetTypeNames = {
    'Obx',
    'GetX',
    'GetBuilder',
    'Observer',
    'Consumer',
    'Provider',
    'Builder',
    'BlocBuilder',
    'BlocListener',
    'BlocProvider',
    'Selector',
    'ValueListenableBuilder',
    'ListenableBuilder',
    'AnimatedBuilder',
    'StreamBuilder',
    'FutureBuilder',
    'SizedBox',
    'Positioned',
    'Center',
    'Expanded',
    'SafeArea',
    'DefaultTextStyle',
    'DefaultTextStyleTransition',
    'DefaultTextStyleTween',
    'DefaultTextStyleTweenTransition',
    'DefaultSelectionStyle',
    'SelectionArea',
    'SelectableText',
    'DecoratedBox',
    'DecoratedBoxTransition',
    'DecoratedBoxTween',
    'DecoratedBoxTweenTransition',
    'Padding',
    'Align',
    'FittedBox',
    'Flexible',
    'Wrap',
    'ScrollConfiguration',
    'CustomMultiChildLayout', // Internal layout widget used by AppBar and other complex widgets
    'Scrollbar',
    'RefreshIndicator',
    'KeyedSubtree',
    'Visibility',
    'Opacity',
    'Transform',
    'RotatedBox',
    'FractionalTranslation',
    'LayoutBuilder',
    'OrientationBuilder',
    'MediaQuery',
    'Theme',
    'Material',
    'Scaffold',
    'AppBar',
    'Drawer',
    'BottomNavigationBar',
    'Hero',
    'WillPopScope',
    'PopScope',
    'GestureDetector',
    'MouseRegion',
    'Listener',
    'AbsorbPointer',
    'IgnorePointer',
    // Note: InkWell is handled specially in button detection logic
    // 'InkWell', // Commented out - handled case by case
    'Ink',
    'Focus',
    'FocusScope',
    'KeyboardListener',
    'Directionality',
    'Localizations',
    'Semantics',
    'ExcludeSemantics',
    'MergeSemantics',
    'IndexedSemantics',
    'BlockSemantics',
    'AnnotatedRegion',
    'RepaintBoundary',
    'CompositedTransformTarget',
    'CompositedTransformFollower',
    'OverflowBox',
    'SizedOverflowBox',
    'UnconstrainedBox',
    'LimitedBox',
    'ConstrainedBox',
    'IntrinsicWidth',
    'IntrinsicHeight',
    'Baseline',
    'FractionallySizedBox',
    'AspectRatio',
    'KeepAlive',
    'AutomaticKeepAlive',
    'AutomaticKeepAliveClientMixin',
    'TickerMode',
    'PhysicalModel',
    'PhysicalShape',
    'ClipRect',
    'ClipRRect',
    'ClipOval',
    'ClipPath',
    'CustomPaint',
    'BackdropFilter',
    'ShaderMask',
    'ColorFiltered',
    'AnimatedContainer',
    'AnimatedPadding',
    'AnimatedAlign',
    'AnimatedPositioned',
    'AnimatedOpacity',
    'AnimatedDefaultTextStyle',
    'AnimatedPhysicalModel',
    'SlideTransition',
    'ScaleTransition',
    'RotationTransition',
    'SizeTransition',
    'FadeTransition',
    'RelativePositionedTransition',
    'PositionedTransition',
    'AlignTransition',
    'AnimatedWidget',
    'ImplicitlyAnimatedWidget',
    'TweenAnimationBuilder',
    'SliderTheme',
    'ButtonTheme',
    'CheckboxTheme',
    'RadioTheme',
    'SwitchTheme',
    'TooltipTheme',
    'CardTheme',
    'ChipTheme',
    'DataTableTheme',
    'DialogTheme',
    'DividerTheme',
    'FloatingActionButtonTheme',
    'IconTheme',
    'ListTileTheme',
    'PopupMenuTheme',
    'ProgressIndicatorTheme',
    'SnackBarTheme',
    'TabBarTheme',
    'TextButtonTheme',
    'TextSelectionTheme',
    'TimePickerTheme',
    'ToggleButtonsTheme',
    'Tooltip',
    'NotificationListener',
    'LayoutId',
    'UnmanagedRestorationScope',
    'TableCell',
    'Spacer',
    'RawGestureDetector',
    'RawKeyboardListener',
    'RawMaterialButton',
    'RawMaterialButtonTheme',
    'RawMaterialButtonThemeData',
    'RawMaterialButtonThemeDataTransition',
    'RawMaterialButtonThemeDataTween',
    'Form',
    'FormField',
    'FormFieldState',
    'FormFieldStatefulBuilder',
    'FormFieldStatefulBuilderState',
    'FormFieldStatefulBuilderStateState',
    'FormFieldStatefulBuilderStateStateState',
    'Action',
    'Actions',
    '_ActionScope',
    '_FocusableActionDetector',
    'CallbackAction',
    'DoNothingAction',
    'ActivateAction',
    'ButtonActivateAction',
    'DismissAction',
    'PrioritizedAction',
    'VoidCallbackAction',
    'ColoredBox',
    // ListView/GridView internal widgets - these should never appear in popup
    'SliverPadding',
    'SliverList',
    'SliverGrid',
    'SliverFixedExtentList',
    'SliverPrototypeExtentList',
    'SliverFillViewport',
    'SliverFillRemaining',
    'SliverToBoxAdapter',
    '_SliverBuilder',
    '_SliverBuilderDelegate',
    '_SliverList',
    '_SliverGrid',
    'SliverChildBuilderDelegate',
    'SliverChildListDelegate',
    'SliverChildDelegate',
    '_SliverFractionalPadding',
    '_RenderSliverPadding',
    '_RenderSliverList',
    '_RenderSliverGrid',
    'ScrollablePositionedList',
    '_ListViewState',
    '_GridViewState',
    '_ScrollableState',
    'ViewportLayout',
    '_RenderViewport',
    'Viewport',
    'CupertinoScrollbar',
    'RawScrollbar',
    '_ScrollbarState',
    '_CupertinoScrollbarState',
    '_MaterialScrollbar',
    '_ScrollbarTheme',
    'ScrollbarTheme',
    'ScrollbarThemeData',
    'ScrollbarPainter',
    '_ScrollbarPainter',
    '_ThumbPressGestureRecognizer',
    '_TrackTapGestureRecognizer',
    '_MaterialScrollbarState',
    '_RawScrollbarState',
    'ScrollbarGestureDetector',
    'ScrollbarThumb',
    'ScrollbarTrack',
    'CupertinoScrollbarThumb',
    'CupertinoScrollbarTrack',
    '_CupertinoScrollbar',
    '_RawScrollbar',
    'MaterialScrollbar',
    '_BuiltInScrollbar',
    '_AdaptiveScrollbar',
    'ScrollController',
    'ScrollPhysics',
    'ClampingScrollPhysics',
    'BouncingScrollPhysics',
    'AlwaysScrollableScrollPhysics',
    'NeverScrollableScrollPhysics',
    'ScrollNotification',
    'ScrollNotificationObserver',
    'ScrollMetrics',
    'ScrollPosition',
    'ScrollableDetails',
    '_ScrollableScope',
    '_ScrollSemantics',
    'PrimaryScrollController',
    'ScrollBehavior',
    'MaterialScrollBehavior',
    'CupertinoScrollBehavior',
    'Scrollable', // Internal scrolling widget - should show SingleChildScrollView instead
    '_GlowController',
    '_StretchController',
    'OverscrollIndicatorNotification',
    'BouncingScrollSimulation',
    'ClampingScrollSimulation',
    'ScrollSpringSimulation',
    'FixedExtentScrollController',
    'FixedExtentMetrics',
    'PageController',
    'PageMetrics',
    'PageScrollPhysics',
    '_PagePosition',
    '_ForceImplicitScrollPhysics',
  };

  void _handlePointerEvent(PointerEvent event) {
    if (!isInspectorEnabled) return;

    if (event is PointerDownEvent) {
      _lastTapPosition = event.localPosition;
      _updateSelection(event.position);
    }
  }

  void _updateSelection(Offset position) {
    final RenderObject? userRender = _childKey.currentContext
        ?.findRenderObject();
    if (userRender == null) return;

    final RenderObject? target = _findRenderObjectAtPosition(
      position,
      userRender,
    );

    if (target != null && target != userRender) {
      // <-- Add this condition
      if (_selectedRenderObject != target) {
        final Element? element = _findElementForRenderObject(target);
        setState(() {
          _selectedRenderObject = target;
          _selectedElement = element;
        });
      }
    } else if (_selectedRenderObject != null) {
      setState(() {
        _selectedRenderObject = null;
        _selectedElement = null;
      });
    }
  }

  /// Check if a widget is a custom (non-Flutter built-in) widget
  bool _isCustomWidget(String widgetTypeName) {
    // Skip internal/private widgets
    if (widgetTypeName.startsWith('_') || widgetTypeName.startsWith('Render')) {
      return false;
    }

    // Check if it's NOT a Flutter built-in widget
    return !flutterBuiltInWidgets.contains(widgetTypeName) &&
        !wrapperWidgetTypeNames.contains(widgetTypeName);
  }

  /// Find meaningful structural widgets inside a custom widget
  List<Map<String, dynamic>> _findMeaningfulWidgetsInCustomWidget(
    Element customElement,
  ) {
    List<Map<String, dynamic>> meaningfulWidgets = [];

    void searchForMeaningfulWidgets(Element element, int depth) {
      if (depth > 10) return; // Prevent infinite recursion

      element.visitChildren((child) {
        String childTypeName = child.widget.runtimeType
            .toString()
            .split('<')
            .first;

        // Skip wrapper widgets, look deeper
        if (wrapperWidgetTypeNames.contains(childTypeName)) {
          searchForMeaningfulWidgets(child, depth + 1);
          return;
        }

        // If we find a meaningful built-in widget, add it
        if (_isWidgetMeaningful(child) &&
            flutterBuiltInWidgets.contains(childTypeName)) {
          // NEW: Skip InkWell when analyzing custom widget internal structure
          if (childTypeName == 'InkWell' ||
              childTypeName == '_ParentInkResponseProvider') {
            // Skip InkWell as it's likely just a wrapper, continue searching deeper
            searchForMeaningfulWidgets(child, depth + 1);
            return;
          }

          // Check if we already found this widget type (avoid duplicates)
          bool alreadyFound = meaningfulWidgets.any(
            (widget) => widget['displayName'] == childTypeName,
          );

          if (!alreadyFound) {
            meaningfulWidgets.add({
              'element': child,
              'displayName': childTypeName,
            });

            // For Container, don't search deeper to avoid finding its children
            if (childTypeName == 'Container') {
              return;
            }
          }
        }

        // Continue searching deeper for more meaningful widgets
        searchForMeaningfulWidgets(child, depth + 1);
      });
    }

    searchForMeaningfulWidgets(customElement, 0);

    // Sort by widget hierarchy preference (Container first, then layout widgets)
    meaningfulWidgets.sort((a, b) {
      String nameA = a['displayName'] as String;
      String nameB = b['displayName'] as String;

      // Prioritize Container
      if (nameA == 'Container' && nameB != 'Container') return -1;
      if (nameB == 'Container' && nameA != 'Container') return 1;

      // Then prioritize layout widgets
      Set<String> layoutWidgets = {'Column', 'Row', 'Stack', 'Flex'};
      bool aIsLayout = layoutWidgets.contains(nameA);
      bool bIsLayout = layoutWidgets.contains(nameB);

      if (aIsLayout && !bIsLayout) return -1;
      if (bIsLayout && !aIsLayout) return 1;

      return 0; // Keep original order
    });

    // Limit to the most important 2-3 widgets for popup
    if (meaningfulWidgets.length > 3) {
      meaningfulWidgets = meaningfulWidgets.take(3).toList();
    }

    return meaningfulWidgets;
  }

  /// Find the specific meaningful widget at the exact position within a custom widget
  Element? _findSpecificMeaningfulWidgetAtPosition(
    Element customElement,
    Offset position,
  ) {
    List<Element> candidates = [];

    void searchForCandidates(Element element, int depth) {
      if (depth > 15) return; // Prevent infinite recursion

      element.visitChildren((child) {
        // Check if this child widget has a render object that contains the position
        final RenderObject? childRender = child.renderObject;
        if (childRender != null &&
            _renderObjectContainsPosition(childRender, position)) {
          String childTypeName = child.widget.runtimeType
              .toString()
              .split('<')
              .first;

          // Skip wrapper widgets, look deeper
          if (wrapperWidgetTypeNames.contains(childTypeName)) {
            searchForCandidates(child, depth + 1);
            return;
          }

          // If we find a meaningful built-in widget at this position, it's a candidate
          if (_isWidgetMeaningful(child) &&
              flutterBuiltInWidgets.contains(childTypeName)) {
            // NEW: Skip InkWell if it's just a wrapper inside custom widgets
            if (childTypeName == 'InkWell' ||
                childTypeName == '_ParentInkResponseProvider') {
              // Don't add InkWell to candidates when inside custom widget analysis
            } else {
              candidates.add(child);
            }
          }

          // Continue searching deeper for more specific widgets
          searchForCandidates(child, depth + 1);
        }
      });
    }

    searchForCandidates(customElement, 0);

    // Sort candidates by area (smallest first) and return the smallest meaningful widget
    if (candidates.isNotEmpty) {
      candidates.sort((a, b) {
        final areaA =
            a.renderObject!.semanticBounds.width *
            a.renderObject!.semanticBounds.height;
        final areaB =
            b.renderObject!.semanticBounds.width *
            b.renderObject!.semanticBounds.height;
        return areaA.compareTo(areaB);
      });

      final selected = candidates.first;
      return selected;
    }

    return null;
  }

  void _handleTap(Offset position) {
    if (!isInspectorEnabled) return;

    // Collect all meaningful widgets at this position for selection
    List<Map<String, dynamic>> meaningfulWidgets =
        _collectMeaningfulWidgetsAtPosition(position, debugMode: true);

    if (meaningfulWidgets.isEmpty) return;

    // Light filtering: only remove true wrapper widgets and scrollbars, keep legitimate multiple widgets
    if (meaningfulWidgets.length > 1) {
      List<String> scrollbarTypes = [
        'Scrollbar',
        'CupertinoScrollbar',
        'RawScrollbar',
        '_MaterialScrollbar',
        '_CupertinoScrollbar',
        '_RawScrollbar',
        'ScrollbarTheme',
      ];

      // Only filter out scrollbars and wrapper widgets, but keep legitimate multiple widgets
      meaningfulWidgets = meaningfulWidgets.where((widget) {
        String name = widget['displayName'] as String;
        return !scrollbarTypes.contains(name) &&
            !wrapperWidgetTypeNames.contains(name);
      }).toList();

      // Filtered out scrollbars and wrapper widgets for cleaner selection
    }

    // Filter out internal implementation widgets when higher-level equivalents exist
    meaningfulWidgets = _filterInternalImplementations(meaningfulWidgets);

    // CUSTOM WIDGET HANDLING: Check if we have a custom widget and process it specially

    if (meaningfulWidgets.length == 1) {
      String widgetName = meaningfulWidgets.first['displayName'] as String;
      Element widgetElement = meaningfulWidgets.first['element'] as Element;

      if (_isCustomWidget(widgetName)) {
        // Custom widget detected - first check if user clicked on a specific meaningful widget inside it
        Element? specificWidget = _findSpecificMeaningfulWidgetAtPosition(
          widgetElement,
          position,
        );

        if (specificWidget != null) {
          // User clicked on a specific meaningful widget inside the custom widget - select it directly
          String specificWidgetName = specificWidget.widget.runtimeType
              .toString()
              .split('<')
              .first;

          // NEW: If the specific widget is InkWell, select the custom widget instead
          if (specificWidgetName == 'InkWell' ||
              specificWidgetName == '_ParentInkResponseProvider') {
            _selectWidget(widgetElement);
            return;
          }
          // IMPORTANT FIX: For mobile and web consistency
          // If the specific widget found is Container, select it directly instead of showing popup
          else if (specificWidgetName == 'Container') {
            _selectWidget(specificWidget);
            return;
          } else {
            _selectWidget(specificWidget);
            return;
          }
        }

        // No specific widget found at position, analyze internal structure
        List<Map<String, dynamic>> internalWidgets =
            _findMeaningfulWidgetsInCustomWidget(widgetElement);

        if (internalWidgets.length >= 2) {
          // Show popup with multiple internal widgets for user selection
          setState(() {
            _availableWidgets = internalWidgets
                .take(3)
                .toList(); // Limit to 3 widgets
            _popupPosition = position;
            _showWidgetPopup = true;
          });

          // Auto close popup after 3 seconds
          _popupTimer?.cancel();
          _popupTimer = Timer(Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showWidgetPopup = false;
              });
            }
          });
          return; // Early return to avoid normal processing
        } else if (internalWidgets.length == 1) {
          // Direct selection of the single internal widget
          _selectWidget(internalWidgets.first['element'] as Element);
          return;
        } else {
          // No meaningful internal widgets found, select the custom widget itself
          _selectWidget(widgetElement);
          return;
        }
      }

      // Even if not a custom widget, check if this widget is inside a custom widget
      if (widgetName == 'Container' ||
          widgetName == 'Column' ||
          widgetName == 'Row') {
        Element? customParent = _findCustomWidgetParent(widgetElement);
        if (customParent != null) {
          // Check if user clicked on a specific widget inside the custom widget
          Element? specificWidget = _findSpecificMeaningfulWidgetAtPosition(
            customParent,
            position,
          );
          if (specificWidget != null) {
            String specificWidgetName = specificWidget.widget.runtimeType
                .toString()
                .split('<')
                .first;
            // IMPROVED FIX: Be more conservative about when to override the tapped widget
            // 1. If user tapped directly on Container, prefer Container over other widgets
            // 2. If user tapped on Column but Container was found, prefer the directly tapped widget
            bool shouldUseDirectlyTappedWidget = false;

            if (widgetName == 'Container' &&
                specificWidgetName != 'Container') {
              shouldUseDirectlyTappedWidget = true;
            } else if (widgetName == specificWidgetName) {
              shouldUseDirectlyTappedWidget = true;
            }

            if (shouldUseDirectlyTappedWidget) {
              // Continue with normal logic instead of early return
            } else {
              _selectWidget(specificWidget);
              return;
            }
          } else {}
        }
      }
    }

    // Handle normal widget selection (non-custom widgets)
    if (meaningfulWidgets.length == 1) {
      // Single widget found - select it directly
      _selectWidget(meaningfulWidgets.first['element'] as Element);
    } else if (meaningfulWidgets.length > 1) {
      // ADDITIONAL FIX: Check if any of the multiple widgets is a custom widget
      // and if so, prefer showing its internal structure instead
      Element? customWidget;
      String? customWidgetName;

      for (var widget in meaningfulWidgets) {
        String widgetName = widget['displayName'] as String;
        if (_isCustomWidget(widgetName)) {
          customWidget = widget['element'] as Element;
          customWidgetName = widgetName;
          break;
        }
      }

      if (customWidget != null && customWidgetName != null) {
        // Check if user clicked on a specific widget inside the custom widget
        Element? specificWidget = _findSpecificMeaningfulWidgetAtPosition(
          customWidget,
          position,
        );

        if (specificWidget != null) {
          _selectWidget(specificWidget);
          return;
        }

        // No specific widget found, analyze internal structure
        List<Map<String, dynamic>> internalWidgets =
            _findMeaningfulWidgetsInCustomWidget(customWidget);

        if (internalWidgets.length >= 2) {
          setState(() {
            _availableWidgets = internalWidgets.take(3).toList();
            _popupPosition = position;
            _showWidgetPopup = true;
          });

          _popupTimer?.cancel();
          _popupTimer = Timer(Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showWidgetPopup = false;
              });
            }
          });
          return;
        }
      }

      // No custom widget found or no internal structure - show original multiple widgets popup
      setState(() {
        _availableWidgets = meaningfulWidgets;
        _popupPosition = position;
        _showWidgetPopup = true;
      });

      // Auto close popup after 3 seconds
      _popupTimer?.cancel();
      _popupTimer = Timer(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showWidgetPopup = false;
          });
        }
      });
    }
  }

  /// Collects all meaningful widgets at the given position for inspector selection.
  ///
  /// This is the core logic that determines which widgets should be available
  /// for selection when the user taps on a specific location. The function handles:
  ///
  /// 1. **Button Detection**: Prioritizes actual buttons (FAB, ElevatedButton) over their child widgets
  /// 2. **InkWell Handling**: Distinguishes between InkWell wrappers (where children are selectable)
  ///    and actual buttons (where the button should be selected)
  /// 3. **Layout Widget Priority**: Allows direct selection of Row/Column in InkWell wrappers
  /// 4. **Card Content**: Provides smart selection within Card widgets
  /// 5. **Custom Widgets**: Analyzes custom widgets to show their internal structure
  ///
  /// Returns a list of widget options for selection, which may trigger a popup
  /// if multiple meaningful widgets are found at the same position.
  List<Map<String, dynamic>> _collectMeaningfulWidgetsAtPosition(
    Offset position, {
    bool debugMode = true,
  }) {
    final RenderObject? userRender = _childKey.currentContext
        ?.findRenderObject();
    if (userRender == null) return [];

    // Find the most specific render object at this position (deepest/smallest)
    final RenderObject? mostSpecificRender = _findRenderObjectAtPosition(
      position,
      userRender,
    );

    if (mostSpecificRender == null) return [];

    // Find the element for this specific render object
    final Element? mostSpecificElement = _findElementForRenderObject(
      mostSpecificRender,
    );

    if (mostSpecificElement == null) return [];

    // Analyze the hit test result to determine selection strategy
    String hitTestName = mostSpecificElement.widget.runtimeType
        .toString()
        .split('<')
        .first;
    bool hitTestIsMeaningful = _isWidgetMeaningful(mostSpecificElement);

    // PRIORITY: Direct button widgets get immediate selection
    Set<String> directButtonWidgets = {
      'IconButton',
      'ElevatedButton',
      'TextButton',
      'OutlinedButton',
      'FloatingActionButton',
      'MaterialButton',
      'RawMaterialButton',
      'BackButton',
      'CloseButton',
      'PopupMenuButton',
      'DropdownButton',
      'Chip',
      'ActionChip',
      'FilterChip',
      'ChoiceChip',
      'InputChip',
      'Checkbox',
      'Radio',
      'Switch',
    };

    // Skip button detection for layout widgets that should be directly selectable
    // This handles cases like InkWell wrappers in ServiceCategoryWidget
    Set<String> layoutWidgetsDontCheckButton = {
      'Row',
      'Column',
      'Stack',
      'Container',
    };

    bool skipButtonDetection = false;

    // Case 1: Hit test found layout widget directly
    if (layoutWidgetsDontCheckButton.contains(hitTestName) &&
        hitTestIsMeaningful) {
      skipButtonDetection = true;
      // Layout widget found directly - prioritize it over button detection
    }

    // Case 2: Hit test found Padding - check if it contains layout widgets
    // This handles the case where user taps on padding/empty space in InkWell
    if (!skipButtonDetection && hitTestName == 'Padding') {
      Element? layoutChild;
      mostSpecificElement.visitChildren((child) {
        String childName = child.widget.runtimeType.toString().split('<').first;
        if (layoutWidgetsDontCheckButton.contains(childName) &&
            _isWidgetMeaningful(child)) {
          layoutChild = child;
          // Found layout widget inside padding
        }
      });

      if (layoutChild != null) {
        skipButtonDetection = true;
        // Skip button detection when padding contains layout widgets
      }
    }

    // Content widgets that can be selected directly within InkWell wrappers
    // (but not within actual buttons like FloatingActionButton)
    Set<String> contentWidgetsThatShouldBeSelectableInButtons = {
      'Text',
      'RichText',
      'Icon',
      'Container',
      'CircleAvatar',
      'Image',
      'CustomImageWidget',
      'Chip',
    };

    if (contentWidgetsThatShouldBeSelectableInButtons.contains(hitTestName) &&
        hitTestIsMeaningful) {
      // Content widget found - will be handled by button detection logic
    }

    // Special handling for checkbox/radio/switch internal widgets
    if (hitTestName == 'CustomPaint' || hitTestName == 'RenderObjectWidget') {
      // Check if this is inside a Checkbox, Radio, or Switch
      Element? checkboxParent = _findCheckboxParent(mostSpecificElement);
      if (checkboxParent != null) {
        String checkboxName = checkboxParent.widget.runtimeType
            .toString()
            .split('<')
            .first;

        List<Map<String, dynamic>> widgets = [];
        widgets.add({'element': checkboxParent, 'displayName': checkboxName});
        return widgets; // Early return - select checkbox directly
      }
    }

    // Start button detection process unless explicitly skipped

    Element? buttonElement;
    if (!skipButtonDetection) {
      buttonElement = _findButtonParent(mostSpecificElement);
    }
    if (buttonElement != null) {
      String buttonName = buttonElement.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // Handle InkWell detection - distinguish between button wrappers and card content
      if (buttonName == 'InkWell' ||
          buttonName == '_ParentInkResponseProvider') {
        // FIRST: Check if InkWell is inside an actual button widget like ElevatedButton
        Element? actualButtonParent;
        Set<String> actualButtonWidgets = {
          'FloatingActionButton',
          'ElevatedButton',
          'TextButton',
          'OutlinedButton',
          'IconButton',
          'MaterialButton',
          'RawMaterialButton',
          'CupertinoButton',
          'BackButton',
          'CloseButton',
          'PopupMenuButton',
          'DropdownButton',
          'Chip',
          'ActionChip',
          'FilterChip',
          'ChoiceChip',
          'InputChip',
        };

        buttonElement.visitAncestorElements((ancestor) {
          String ancestorName = ancestor.widget.runtimeType
              .toString()
              .split('<')
              .first;
          if (actualButtonWidgets.contains(ancestorName)) {
            actualButtonParent = ancestor;
            return false; // Stop searching - found actual button
          }
          return true;
        });

        if (actualButtonParent != null) {
          // InkWell is inside an actual button - return the button directly
          String actualButtonName = actualButtonParent!.widget.runtimeType
              .toString()
              .split('<')
              .first;

          List<Map<String, dynamic>> widgets = [];
          widgets.add({
            'element': actualButtonParent!,
            'displayName': actualButtonName,
          });
          return widgets;
        }

        // NEW: Check if InkWell is inside a custom widget (like CustomImageView)
        Element? customWidgetParent = _findCustomWidgetParent(buttonElement);
        if (customWidgetParent != null) {
          String customWidgetName = customWidgetParent.widget.runtimeType
              .toString()
              .split('<')
              .first;
          List<Map<String, dynamic>> widgets = [];
          widgets.add({
            'element': customWidgetParent,
            'displayName': customWidgetName,
          });
          return widgets;
        }

        // SECOND: Check if InkWell is inside a Card
        Element? cardParent;
        buttonElement.visitAncestorElements((ancestor) {
          String ancestorName = ancestor.widget.runtimeType
              .toString()
              .split('<')
              .first;
          if (ancestorName == 'Card') {
            cardParent = ancestor;
            // InkWell inside Card - handle Card selection instead
            return false; // Stop searching
          }
          return true;
        });

        if (cardParent != null) {
          // InkWell inside Card - use selective Card handling logic

          // Determine what content should be selected within the Card
          Element? meaningfulContent = mostSpecificElement;

          if (!_isWidgetMeaningful(mostSpecificElement)) {
            meaningfulContent = _findDeepestMeaningfulWidget(
              mostSpecificElement,
              position,
            );
          }

          if (meaningfulContent != null) {
            String contentName = meaningfulContent.widget.runtimeType
                .toString()
                .split('<')
                .first;

            // Define content widgets that should be selectable directly (not show Card popup)
            Set<String> directContentWidgets = {
              'CircleAvatar',
              'Text',
              'RichText',
              'Icon',
              'Image',
              'CustomImageWidget',
              'Container', // Allow Container to be selected directly
              'Column', // Allow Column to be selected directly
              'Chip',
              'Badge',
              'ElevatedButton',
              'TextButton',
              'OutlinedButton',
              'IconButton',
              'TextField',
              'TextFormField',
            };

            // Only show Card popup for Row and Stack (main layout widgets), allow direct selection for others
            Set<String> cardPopupTriggers = {'Row', 'Stack'};

            if (directContentWidgets.contains(contentName) &&
                _isWidgetMeaningful(meaningfulContent)) {
              // Select content widget directly (not Card popup)
              List<Map<String, dynamic>> widgets = [];
              widgets.add({
                'element': meaningfulContent,
                'displayName': contentName,
              });
              return widgets;
            } else if (cardPopupTriggers.contains(contentName) &&
                _isWidgetMeaningful(meaningfulContent)) {
              // Show Card + layout widget popup
              List<Map<String, dynamic>> widgets = [];
              widgets.add({'element': cardParent, 'displayName': 'Card'});
              widgets.add({
                'element': meaningfulContent,
                'displayName': contentName,
              });
              return widgets;
            } else {
              // Non-meaningful widget - fall through to normal logic
            }
          } else {
            // No meaningful content found - fall through to normal logic
          }
        } else {
          // InkWell not inside Card - handle content widget selection vs button detection
          if (buttonName == 'InkWell' ||
              buttonName == '_ParentInkResponseProvider') {
            // Determine if content widgets should be selected directly or if InkWell should be treated as button
            // This distinguishes between InkWell wrappers (ServiceCategoryWidget) and actual buttons (FAB)
            Set<String> directSelectableContent = {
              'Text',
              'RichText',
              'Icon',
              'Container',
              'CircleAvatar',
              'Image',
              'CustomImageWidget',
              'Chip',
              'IconButton',
              'ElevatedButton',
              'TextButton',
              'OutlinedButton',
            };

            // Check if the content widget is inside an actual button (not just InkWell)
            bool isInsideActualButton = false;
            if (directSelectableContent.contains(hitTestName) &&
                hitTestIsMeaningful) {
              Set<String> actualButtonWidgets = {
                'FloatingActionButton',
                'ElevatedButton',
                'TextButton',
                'OutlinedButton',
                'IconButton',
                'MaterialButton',
                'RawMaterialButton',
                'CupertinoButton',
                'BackButton',
                'CloseButton',
                'PopupMenuButton',
                'DropdownButton',
                'Chip',
                'ActionChip',
                'FilterChip',
                'ChoiceChip',
                'InputChip',
              };

              // Check if content widget is inside an actual button
              mostSpecificElement.visitAncestorElements((ancestor) {
                String ancestorName = ancestor.widget.runtimeType
                    .toString()
                    .split('<')
                    .first;
                if (actualButtonWidgets.contains(ancestorName)) {
                  isInsideActualButton = true;
                  // Content widget inside actual button - prioritize button selection
                  return false; // Stop searching
                }
                return true;
              });
            }

            if (directSelectableContent.contains(hitTestName) &&
                hitTestIsMeaningful &&
                !isInsideActualButton) {
              // Content widget can be selected directly (not inside actual button)

              // Special handling for Text inside styled Container
              if (hitTestName == 'Text') {
                Element? containerParent;
                mostSpecificElement.visitAncestorElements((ancestor) {
                  String ancestorName = ancestor.widget.runtimeType
                      .toString()
                      .split('<')
                      .first;
                  if (ancestorName == 'Container') {
                    final containerWidget = ancestor.widget as Container;
                    bool hasVisualStyling =
                        containerWidget.decoration != null ||
                        containerWidget.color != null ||
                        containerWidget.constraints != null ||
                        containerWidget.alignment != null ||
                        containerWidget.margin != null ||
                        containerWidget.padding != null;
                    if (hasVisualStyling) {
                      containerParent = ancestor;
                      return false;
                    }
                  }
                  return true;
                });

                // If Text is inside a styled Container, offer both options in a popup
                if (containerParent != null) {
                  List<Map<String, dynamic>> widgets = [];
                  widgets.add({
                    'element': containerParent,
                    'displayName': 'Container',
                  });
                  widgets.add({
                    'element': mostSpecificElement,
                    'displayName': 'Text',
                  });
                  return widgets;
                }
              }

              List<Map<String, dynamic>> widgets = [];
              widgets.add({
                'element': mostSpecificElement,
                'displayName': hitTestName,
              });
              return widgets;
            }

            // Look for meaningful content inside InkWell by searching through its descendants
            Element? meaningfulContent;

            void searchInkWellContent(Element element, int depth) {
              if (meaningfulContent != null || depth > 10) {
                return;
              }

              element.visitChildren((child) {
                if (meaningfulContent != null) return;

                String childName = child.widget.runtimeType
                    .toString()
                    .split('<')
                    .first;

                // Searching InkWell content for layout widgets

                // Check if this child is a layout widget (what we're looking for)
                Set<String> layoutWidgets = {
                  'Row',
                  'Column',
                  'Stack',
                  'Container',
                  'Padding',
                };

                if (layoutWidgets.contains(childName)) {
                  meaningfulContent = child;
                  return;
                }

                // Skip wrapper widgets and continue searching deeper
                if (wrapperWidgetTypeNames.contains(childName) ||
                    childName.startsWith('_') ||
                    childName == 'Actions' ||
                    childName == 'Focus' ||
                    childName == 'Semantics' ||
                    childName == 'MouseRegion' ||
                    childName == 'Builder' ||
                    childName == 'GestureDetector' ||
                    childName == 'RawGestureDetector' ||
                    childName == 'Padding') {
                  // Skip wrapper widgets and search deeper
                  searchInkWellContent(child, depth + 1);
                  return;
                }

                // Record meaningful widgets but prefer layout widgets
                if (_isWidgetMeaningful(child) && meaningfulContent == null) {
                  meaningfulContent = child;
                }

                // Continue searching even if we found something (in case there's a layout widget deeper)
                searchInkWellContent(child, depth + 1);
              });
            }

            // Start search from InkWell element itself
            searchInkWellContent(buttonElement, 0);

            if (meaningfulContent != null) {
              String contentName = meaningfulContent!.widget.runtimeType
                  .toString()
                  .split('<')
                  .first;

              // If InkWell contains layout widgets (Row, Column, Stack), show the content instead
              Set<String> layoutWidgets = {
                'Row',
                'Column',
                'Stack',
                'Container',
                'Padding',
              };
              if (layoutWidgets.contains(contentName)) {
                // InkWell contains layout widgets - skip button detection

                // Skip InkWell button detection - use layout widget from hit test instead
                return [];
              } else {
                // InkWell with simple content (Text, Icon) - treat as button
                List<Map<String, dynamic>> widgets = [];
                widgets.add({
                  'element': buttonElement,
                  'displayName': 'InkWell',
                });
                return widgets;
              }
            } else {
              // No meaningful content found - treat InkWell as button
              List<Map<String, dynamic>> widgets = [];
              widgets.add({'element': buttonElement, 'displayName': 'InkWell'});
              return widgets;
            }
          } else {
            // Not InkWell/_ParentInkResponseProvider, treat as normal button
            List<Map<String, dynamic>> widgets = [];
            widgets.add({'element': buttonElement, 'displayName': buttonName});
            return widgets; // Early return - select button directly
          }
        }
      } else {
        // Not InkWell/_ParentInkResponseProvider, treat as normal button
        List<Map<String, dynamic>> widgets = [];
        widgets.add({'element': buttonElement, 'displayName': buttonName});
        return widgets; // Early return - select button directly
      }
    }

    Element? targetElement;
    if (directButtonWidgets.contains(hitTestName)) {
      // Direct button hit - use immediately
      targetElement = mostSpecificElement;
    } else if (hitTestName == 'ColoredBox') {
      // Special case: ColoredBox is Flutter's internal representation of Container(color: ...)
      // Look for the parent Container that created this ColoredBox
      Element? containerParent;
      mostSpecificElement.visitAncestorElements((ancestor) {
        String ancestorName = ancestor.widget.runtimeType
            .toString()
            .split('<')
            .first;
        if (ancestorName == 'Container') {
          final containerWidget = ancestor.widget as Container;
          // Check if this Container has color (which would create the ColoredBox)
          if (containerWidget.color != null) {
            containerParent = ancestor;
            return false; // Stop searching
          }
        }
        return true;
      });

      if (containerParent != null) {
        targetElement = containerParent;
      } else {
        targetElement = mostSpecificElement; // Fallback to ColoredBox itself
      }
    } else if (hitTestIsMeaningful) {
      // Use the hit test result directly if it's meaningful
      targetElement = mostSpecificElement;
    } else if (hitTestName == 'Padding') {
      // Special case: If hit test found Padding, look for meaningful child (like Row)
      Element? meaningfulChild;
      mostSpecificElement.visitChildren((child) {
        if (_isWidgetMeaningful(child)) {
          meaningfulChild = child;
        }
      });

      if (meaningfulChild != null) {
        targetElement = meaningfulChild;
      } else {
        // No meaningful child found, traverse up
        targetElement = _findDeepestMeaningfulWidget(
          mostSpecificElement,
          position,
        );
      }
    } else {
      // Hit test not meaningful - traverse up to find meaningful widget
      targetElement = _findDeepestMeaningfulWidget(
        mostSpecificElement,
        position,
      );

      // After finding target element, check if it's inside a button widget
      if (targetElement != null) {
        String foundWidgetName = targetElement.widget.runtimeType
            .toString()
            .split('<')
            .first;

        // If we didn't find a button directly, check ancestors for button widgets
        if (!directButtonWidgets.contains(foundWidgetName)) {
          Element? buttonAncestor = _findButtonParent(targetElement);
          if (buttonAncestor != null) {
            // Found button ancestor - prioritize button over content
            targetElement = buttonAncestor;
          }
        }
      }
    }

    if (targetElement == null) return [];

    String debugName = targetElement.widget.runtimeType
        .toString()
        .split('<')
        .first;

    // Map internal Flutter widgets back to their user-written equivalents
    String displayName = debugName;
    if (debugName == 'ColoredBox') {
      // Check if this ColoredBox is from a Container(color: ...)
      bool isFromContainer = false;
      targetElement.visitAncestorElements((ancestor) {
        String ancestorName = ancestor.widget.runtimeType
            .toString()
            .split('<')
            .first;
        if (ancestorName == 'Container') {
          final containerWidget = ancestor.widget as Container;
          if (containerWidget.color != null) {
            isFromContainer = true;
            return false; // Stop searching
          }
        }
        return true;
      });

      if (isFromContainer) {
        displayName = 'Container'; // Show as Container in UI
      }
    }

    // PRIORITY -3: Enhanced button detection - if we found any widget that could be inside a button, check for button ancestors
    Set<String> potentialButtonContent = {
      'Container',
      'Row',
      'Column',
      'Stack',
      'Center',
      'Padding',
      'Icon',
      'Text',
      'RichText',
      'ColoredBox',
      'DecoratedBox',
      'SizedBox',
      'Align',
      'InkWell',
      'InkResponse',
      'GestureDetector',
      'MouseRegion',
      'Semantics',
    };

    if (potentialButtonContent.contains(displayName) &&
        !directButtonWidgets.contains(hitTestName)) {
      // Check if we're inside any button widget
      Element? buttonAncestor;
      int searchDepth = 0;
      targetElement.visitAncestorElements((ancestor) {
        searchDepth++;
        if (searchDepth > 10) return false; // Limit search depth

        String ancestorName = ancestor.widget.runtimeType
            .toString()
            .split('<')
            .first;

        // Check for any button widget type
        Set<String> allButtonWidgets = {
          'IconButton',
          'ElevatedButton',
          'TextButton',
          'OutlinedButton',
          'FloatingActionButton',
          'MaterialButton',
          'RawMaterialButton',
          'BackButton',
          'CloseButton',
          'PopupMenuButton',
          'DropdownButton',
          'Chip',
          'ActionChip',
          'FilterChip',
          'ChoiceChip',
          'InputChip',
        };

        if (allButtonWidgets.contains(ancestorName)) {
          buttonAncestor = ancestor;
          // Found button ancestor - will prioritize button over content
          return false; // Stop searching
        }
        return true;
      });

      if (buttonAncestor != null) {
        // Override content widget with button ancestor
        targetElement = buttonAncestor;
        debugName = buttonAncestor!.widget.runtimeType
            .toString()
            .split('<')
            .first;
        displayName = debugName; // Update display name as well
      }
    }

    // Enhanced button detection complete - proceed with widget analysis

    // Handle spacing elements (Padding, SizedBox) - check for meaningful children
    // This helps select the actual content rather than just the spacing wrapper
    Set<String> spacingElements = {'Padding', 'SizedBox', 'Spacer'};
    String originalHitTestName = mostSpecificElement.widget.runtimeType
        .toString()
        .split('<')
        .first;
    if (spacingElements.contains(originalHitTestName)) {
      // First, check if there's an immediate meaningful child (like Column, Row)
      Element? immediateMeaningfulChild;
      mostSpecificElement.visitChildren((child) {
        if (_isWidgetMeaningful(child)) {
          String childTypeName = child.widget.runtimeType
              .toString()
              .split('<')
              .first;
          // Prioritize layout widgets as immediate children
          Set<String> layoutWidgets = {
            'Column',
            'Row',
            'Stack',
            'Flex',
            'Wrap',
          };
          if (layoutWidgets.contains(childTypeName)) {
            immediateMeaningfulChild = child;
            // Found immediate layout child in spacing element
          }
        }
      });

      // Check if we're inside a Container with visual styling
      Element? styledContainerParent;
      mostSpecificElement.visitAncestorElements((ancestor) {
        String ancestorName = ancestor.widget.runtimeType
            .toString()
            .split('<')
            .first;
        if (ancestorName == 'Container' && _isWidgetMeaningful(ancestor)) {
          final containerWidget = ancestor.widget as Container;
          bool hasVisualStyling =
              containerWidget.decoration != null ||
              containerWidget.color != null ||
              containerWidget.constraints != null ||
              containerWidget.alignment != null ||
              containerWidget.margin != null ||
              containerWidget.padding != null;

          if (hasVisualStyling) {
            styledContainerParent = ancestor;
            // Found styled Container parent for spacing element
            return false; // Stop searching
          }
        }
        return true; // Continue searching
      });

      // If we have both a styled Container parent and immediate layout child, show popup
      if (styledContainerParent != null && immediateMeaningfulChild != null) {
        String childTypeName = immediateMeaningfulChild!.widget.runtimeType
            .toString()
            .split('<')
            .first;
        // Show popup with both Container and layout child
        List<Map<String, dynamic>> widgets = [];
        widgets.add({
          'element': styledContainerParent!,
          'displayName': 'Container',
        });
        widgets.add({
          'element': immediateMeaningfulChild!,
          'displayName': childTypeName,
        });
        return widgets;
      } else if (immediateMeaningfulChild != null) {
        // Only immediate layout child found, no styled Container parent
        String childTypeName = immediateMeaningfulChild!.widget.runtimeType
            .toString()
            .split('<')
            .first;
        List<Map<String, dynamic>> widgets = [];
        widgets.add({
          'element': immediateMeaningfulChild!,
          'displayName': childTypeName,
        });
        return widgets;
      } else if (styledContainerParent != null) {
        // Only styled Container parent found, no immediate layout child
        List<Map<String, dynamic>> widgets = [];
        widgets.add({
          'element': styledContainerParent!,
          'displayName': 'Container',
        });
        return widgets;
      }
    }

    // Special case: If inspector found SingleChildScrollView but hit test found layout content widgets,
    // use the original hit test results to show SingleChildScrollView + layout widget
    // BUT ONLY if we don't have image widgets that should show Container
    if (debugName == 'SingleChildScrollView' ||
        debugName == 'ListView' ||
        debugName == 'GridView') {
      Element? originalHitWidget = mostSpecificElement;

      String originalWidgetName = originalHitWidget.widget.runtimeType
          .toString()
          .split('<')
          .first;
      // Analyze original hit widget for scroll widget handling

      // First check if this is an image widget case that should show Container
      Set<String> imageRelatedWidgets = {
        'FadeWidget',
        'Image',
        'CachedNetworkImage',
        'CustomImageWidget',
        'CustomIconWidget',
        'Stack',
        'Icon',
        'Center', // Added Center as it often wraps icons
      };

      if (imageRelatedWidgets.contains(originalWidgetName)) {
        // For image widgets, look for Container ancestor and prioritize it
        Element? containerAncestor;
        originalHitWidget.visitAncestorElements((ancestor) {
          String ancestorName = ancestor.widget.runtimeType
              .toString()
              .split('<')
              .first;
          if (ancestorName == 'Container' && _isWidgetMeaningful(ancestor)) {
            containerAncestor = ancestor;
            // Found Container ancestor for image widget
            return false; // Stop searching
          }
          return true;
        });

        if (containerAncestor != null) {
          // Prioritize Container for image widgets
          // Return just the Container, don't use scroll widget logic
          List<Map<String, dynamic>> widgets = [];
          widgets.add({
            'element': containerAncestor,
            'displayName': 'Container',
          });
          return widgets;
        }
      } else {
        // Not an image widget - proceed with scroll widget + layout logic
        // BUT FIRST: Only look for styled Container if we're NOT already on a meaningful scroll widget
        // If user taps directly on ListView/GridView, they want to select it, not a distant Container
        if (debugName != 'ListView' &&
            debugName != 'GridView' &&
            debugName != 'CustomScrollView') {
          // Check if there's a styled Container in the hierarchy that should be prioritized
          Element? styledContainer;
          originalHitWidget.visitAncestorElements((ancestor) {
            String ancestorName = ancestor.widget.runtimeType
                .toString()
                .split('<')
                .first;

            if (ancestorName == 'Container' && _isWidgetMeaningful(ancestor)) {
              final containerWidget = ancestor.widget as Container;
              bool hasVisualStyling =
                  containerWidget.decoration != null ||
                  containerWidget.color != null ||
                  containerWidget.constraints != null ||
                  containerWidget.alignment != null ||
                  containerWidget.margin != null ||
                  containerWidget.padding != null;

              if (hasVisualStyling) {
                styledContainer = ancestor;
                return false; // Stop searching
              }
            }
            return true; // Continue searching
          });

          if (styledContainer != null) {
            // Prioritize styled Container over scroll widget combo
            List<Map<String, dynamic>> widgets = [];
            widgets.add({
              'element': styledContainer,
              'displayName': 'Container',
            });
            return widgets;
          }
        }

        // No styled Container found, proceed with normal scroll widget + layout logic
        Element? layoutParent;
        originalHitWidget.visitAncestorElements((ancestor) {
          String ancestorName = ancestor.widget.runtimeType
              .toString()
              .split('<')
              .first;
          Set<String> layoutWidgets = {'Column', 'Row', 'Container'};

          if (layoutWidgets.contains(ancestorName) &&
              _isWidgetMeaningful(ancestor)) {
            layoutParent = ancestor;
            return false; // Stop searching
          }
          return true; // Continue searching
        });

        if (layoutParent != null) {
          String contentWidgetName = layoutParent!.widget.runtimeType
              .toString()
              .split('<')
              .first;

          // Check if this is a small styled Container that should be prioritized over scroll widget
          if (contentWidgetName == 'Container') {
            final containerWidget = layoutParent!.widget as Container;
            bool hasVisualStyling =
                containerWidget.decoration != null ||
                containerWidget.color != null ||
                containerWidget.constraints != null ||
                containerWidget.alignment != null ||
                containerWidget.margin != null ||
                containerWidget.padding != null;

            // Check if it's a small Container (likely an icon container)
            final containerBounds = layoutParent!.renderObject?.semanticBounds;
            bool isSmallContainer = false;
            if (containerBounds != null) {
              double area = containerBounds.width * containerBounds.height;
              isSmallContainer = area < 10000; // Less than 100x100 pixels
            }

            if (hasVisualStyling && isSmallContainer) {
              List<Map<String, dynamic>> widgets = [];
              widgets.add({
                'element': layoutParent!,
                'displayName': contentWidgetName,
              });
              return widgets;
            }
          }

          List<Map<String, dynamic>> widgets = [];

          // Add scroll widget first
          widgets.add({'element': targetElement, 'displayName': debugName});

          // Add layout widget second
          widgets.add({
            'element': layoutParent!,
            'displayName': contentWidgetName,
          });

          return widgets;
        }
      }
    }

    // PRIORITY -2: Direct scroll widget selection - if inspector found ListView/GridView, select it directly
    Set<String> scrollWidgets = {
      'ListView',
      'GridView',
      'CustomScrollView',
      'PageView',
    };
    if (scrollWidgets.contains(debugName)) {
      List<Map<String, dynamic>> widgets = [];
      widgets.add({'element': targetElement, 'displayName': debugName});
      return widgets; // Early return - don't process any other logic
    }

    // PRIORITY -1: Aggressive button detection - check if we hit button internal widgets
    Set<String> buttonInternalWidgets = {
      '_TextButtonWithIcon',
      '_ElevatedButtonWithIcon',
      '_OutlinedButtonWithIcon',
      'Row', // Row is commonly used inside buttons for icon + text layout
    };

    // PRIORITY -1.5: Direct button selection - if we directly hit a button widget, select it immediately
    Set<String> buttonWidgets = {
      'IconButton',
      'ElevatedButton',
      'TextButton',
      'OutlinedButton',
      'FloatingActionButton',
      'MaterialButton',
      'RawMaterialButton',
      'CupertinoButton',
      'BackButton',
      'CloseButton',
      'PopupMenuButton',
      'DropdownButton',
      'MenuItemButton',
      'SubmenuButton',
      'Chip',
      'ActionChip',
      'FilterChip',
      'ChoiceChip',
      'InputChip',
    };

    if (buttonWidgets.contains(debugName)) {
      List<Map<String, dynamic>> widgets = [];
      widgets.add({'element': targetElement, 'displayName': debugName});
      return widgets; // Early return - select button directly
    }

    // PRIORITY -1.6: After button detection enhancement, check if we now have a button
    if (buttonWidgets.contains(debugName)) {
      List<Map<String, dynamic>> widgets = [];
      widgets.add({'element': targetElement, 'displayName': debugName});
      return widgets; // Early return - select button directly
    }

    String currentTargetName = targetElement != null
        ? targetElement.widget.runtimeType.toString().split('<').first
        : '';

    // SKIP PRIORITY -1 if button detection was already skipped earlier
    // This prevents the Row inside InkWell from being detected as a button internal widget
    bool wasButtonDetectionSkipped = skipButtonDetection;

    if (!wasButtonDetectionSkipped &&
        targetElement != null &&
        (buttonInternalWidgets.contains(debugName) ||
            buttonInternalWidgets.contains(currentTargetName))) {
      Element? buttonParent = _findButtonParent(targetElement);
      if (buttonParent != null) {
        String buttonName = buttonParent.widget.runtimeType
            .toString()
            .split('<')
            .first;
        List<Map<String, dynamic>> widgets = [];
        widgets.add({'element': buttonParent, 'displayName': buttonName});
        return widgets; // Early return - don't process any other logic
      }
    }

    // Additional debugging for button detection
    if (targetElement != null) {
      // Debug meaningful check
      _isWidgetMeaningful(targetElement);
    }

    // Simple approach: only find direct parent-child relationships where both occupy same visual space
    List<Map<String, dynamic>> widgets = [];
    String targetName = displayName;

    // Find immediate meaningful parent, but prioritize layout widgets like Container
    Element? parent;
    Element? containerParent;

    // Define page/screen widgets that should be deprioritized
    Set<String> pageWidgets = {
      'SalonProfile',
      'SalonDashboard',
      'WalletDashboard',
      'TransactionHistory',
      'ClientDirectory',
      'AppointmentManagement',
      'Settings',
      'ServiceCatalog',
      'NotificationCenter',
      'EmailConfirmation',
      'SalonSignin',
      'SalonSignupAccountCreation',
    };

    // Define image-related widgets for Container detection
    Set<String> imageRelatedWidgets = {
      'FadeWidget',
      'Image',
      'CachedNetworkImage',
      'NetworkImage',
      'AssetImage',
      'FileImage',
      'MemoryImage',
      'OctoImage',
      'CustomImageWidget',
      'CustomIconWidget', // Added CustomIconWidget
      'SvgPicture',
      'Icon',
      'Stack',
      'Center', // Added Center as it often wraps icons
    };

    int searchDepth = 0;
    if (targetElement != null) {
      targetElement.visitAncestorElements((ancestor) {
        searchDepth++;
        String ancestorName = ancestor.widget.runtimeType
            .toString()
            .split('<')
            .first;
        bool isAncestorMeaningful = _isWidgetMeaningful(ancestor);

        if (isAncestorMeaningful) {
          // Skip page widgets if we already have layout widgets
          if (pageWidgets.contains(ancestorName)) {
            return true; // Continue searching, but don't set as parent
          }

          // Prioritize Container - always search for it aggressively
          if (ancestorName == 'Container') {
            containerParent = ancestor;
            // For image widgets, stop at the first Container we find (closest one)
            if (imageRelatedWidgets.contains(targetName)) {
              return false; // Stop searching for image widgets
            }
          }

          // Check for scroll widgets specifically
          if (ancestorName == 'SingleChildScrollView' ||
              ancestorName == 'ListView' ||
              ancestorName == 'GridView') {
            if (parent == null) {
              parent = ancestor;
            }
          }

          // Set first meaningful parent (excluding page widgets)
          if (parent == null && !pageWidgets.contains(ancestorName)) {
            parent = ancestor;
          }
        }

        // For image-related widgets, only continue searching if we haven't found a Container yet
        if (imageRelatedWidgets.contains(targetName)) {
          if (containerParent == null && searchDepth < 20) {
            // Only continue searching if we haven't found a Container yet
            return true; // Continue searching for Container when dealing with image widgets
          } else if (containerParent != null) {
            // Stop searching if we already found a Container for image widgets
            return false;
          }
        }

        // For other widgets, stop after finding meaningful parent or after reasonable depth
        if (searchDepth > 25 || (containerParent != null && parent != null)) {
          return false;
        }

        return true; // Continue searching
      });
    } // Close the if (targetElement != null) block

    // If no parent found and target is a layout widget, look for scroll widget ancestors
    if (parent == null &&
        (targetName == 'Column' ||
            targetName == 'Row' ||
            targetName == 'Stack')) {
      Element? scrollParent = _findListViewParent(targetElement!);
      if (scrollParent != null) {
        parent = scrollParent;
      }
    }

    // Define content widgets that should be selectable directly
    Set<String> directlySelectableWidgets = {
      'Text',
      'RichText',
      'Icon',
      'Container', // Added Container - should be directly selectable when it has styling
      'Button',
      'ElevatedButton',
      'TextButton',
      'OutlinedButton',
      'IconButton',
      'TextField',
      'TextFormField',
      'Checkbox',
      'Radio',
      'Switch',
      'Image',
      'CustomImageWidget',
      'CircleAvatar', // Added CircleAvatar
      'Chip',
      'Card',
    };

    // Define layout widgets that should also be selectable directly
    Set<String> directlySelectableLayoutWidgets = {
      'Column',
      'Row',
      'Stack',
      'Wrap',
      'Flex',
      'IndexedStack',
    };

    // PRIORITY -0.6: Special AppBar handling - if target is inside AppBar, select AppBar directly
    Element? appBarAncestor;
    if (targetName == 'AppBar') {
      appBarAncestor = targetElement;
    } else if (targetElement != null) {
      // Check if target is inside an AppBar
      targetElement.visitAncestorElements((ancestor) {
        String ancestorName = ancestor.widget.runtimeType
            .toString()
            .split('<')
            .first;
        if (ancestorName == 'AppBar') {
          appBarAncestor = ancestor;
          return false; // Stop searching
        }
        return true;
      });
    }

    if (appBarAncestor != null) {
      widgets.add({'element': appBarAncestor, 'displayName': 'AppBar'});
      return widgets; // Early return with AppBar only
    }

    // PRIORITY -0.5: Special Card handling - if target is Card OR target is inside Card, show popup with Card and its meaningful content
    Element? cardAncestor;
    if (targetName == 'Card') {
      cardAncestor = targetElement;
    } else if (targetElement != null) {
      // Check if target is inside a Card
      targetElement.visitAncestorElements((ancestor) {
        String ancestorName = ancestor.widget.runtimeType
            .toString()
            .split('<')
            .first;
        if (ancestorName == 'Card') {
          cardAncestor = ancestor;
          return false; // Stop searching
        }
        return true;
      });
    }

    if (cardAncestor != null) {
      // Define widgets that should be selectable directly even inside Card
      Set<String> directlySelectableInCard = {
        'CircleAvatar',
        'Text',
        'RichText',
        'Icon',
        'Image',
        'CustomImageWidget',
        'Container', // Allow Container to be selected directly
        'Column',
        'Chip',
        'Badge',
        'ElevatedButton',
        'TextButton',
        'OutlinedButton',
        'IconButton',
        'TextField',
        'TextFormField',
      };

      // If target is a directly selectable widget, return it directly (no Card popup)
      if (targetElement != null &&
          directlySelectableInCard.contains(targetName) &&
          _isWidgetMeaningful(targetElement)) {
        widgets.add({'element': targetElement, 'displayName': targetName});
        return widgets; // Early return with target only
      }

      // For Row and Stack, show Card + layout widget popup
      Set<String> layoutWidgetsForPopup = {'Row', 'Stack'};
      if (targetElement != null &&
          layoutWidgetsForPopup.contains(targetName) &&
          _isWidgetMeaningful(targetElement)) {
        widgets.add({'element': cardAncestor!, 'displayName': 'Card'});
        widgets.add({'element': targetElement, 'displayName': targetName});
        return widgets; // Early return with Card + target popup
      }

      // For other cases (non-meaningful widgets, empty space), show just Card
      widgets.add({'element': cardAncestor!, 'displayName': 'Card'});
      return widgets; // Early return with just Card
    }

    // PRIORITY 0: For image widgets, immediately return Container and stop all other processing
    if (containerParent != null && imageRelatedWidgets.contains(targetName)) {
      widgets.add({'element': containerParent!, 'displayName': 'Container'});
      return widgets; // Early return - don't process any other logic
    }

    // PRIORITY 0.5: If user taps directly on styled Container with layout children, show popup
    if (targetName == 'Container') {
      final containerWidget = targetElement!.widget as Container;
      bool hasVisualStyling =
          containerWidget.decoration != null ||
          containerWidget.color != null ||
          containerWidget.constraints != null ||
          containerWidget.alignment != null ||
          containerWidget.margin != null ||
          containerWidget.padding != null;

      if (hasVisualStyling) {
        // Check for immediate meaningful layout child
        Element? immediateLayoutChild;
        targetElement.visitChildren((child) {
          if (_isWidgetMeaningful(child)) {
            String childTypeName = child.widget.runtimeType
                .toString()
                .split('<')
                .first;
            Set<String> layoutWidgets = {
              'Column',
              'Row',
              'Stack',
              'Flex',
              'Wrap',
            };
            if (layoutWidgets.contains(childTypeName)) {
              immediateLayoutChild = child;
            }
          }
        });

        if (immediateLayoutChild != null) {
          String childTypeName = immediateLayoutChild!.widget.runtimeType
              .toString()
              .split('<')
              .first;

          widgets.add({'element': targetElement, 'displayName': 'Container'});
          widgets.add({
            'element': immediateLayoutChild!,
            'displayName': childTypeName,
          });
          return widgets; // Early return with popup
        }
      }
    }

    // PRIORITY 0.6: If user taps directly on Card with layout children, show popup (similar to Container logic)
    if (targetName == 'Card') {
      // Check for immediate meaningful layout child inside Card
      Element? immediateLayoutChild;
      targetElement!.visitChildren((child) {
        if (_isWidgetMeaningful(child)) {
          String childTypeName = child.widget.runtimeType
              .toString()
              .split('<')
              .first;
          Set<String> layoutWidgets = {
            'Column',
            'Row',
            'Stack',
            'Flex',
            'Wrap',
          };
          if (layoutWidgets.contains(childTypeName)) {
            immediateLayoutChild = child;
          }
        }
      });

      if (immediateLayoutChild != null) {
        String childTypeName = immediateLayoutChild!.widget.runtimeType
            .toString()
            .split('<')
            .first;

        widgets.add({'element': targetElement, 'displayName': 'Card'});
        widgets.add({
          'element': immediateLayoutChild!,
          'displayName': childTypeName,
        });
        return widgets; // Early return with popup
      } else {
        // Card without meaningful layout child - just return Card
        widgets.add({'element': targetElement, 'displayName': 'Card'});
        return widgets; // Early return with Card only
      }
    }

    // PRIORITY 0.7: If user taps directly on AppBar, select it directly (don't show internal widgets)
    if (targetName == 'AppBar') {
      widgets.add({'element': targetElement, 'displayName': 'AppBar'});
      return widgets; // Early return with AppBar only
    } else if (containerParent != null &&
        !directlySelectableWidgets.contains(targetName) &&
        !directlySelectableLayoutWidgets.contains(targetName)) {
      // Only prioritize Container for widgets that are neither content nor layout widgets
      parent = containerParent;
    } else if (containerParent != null &&
        (directlySelectableWidgets.contains(targetName) ||
            directlySelectableLayoutWidgets.contains(targetName))) {}

    // Check if parent and child should both be shown
    bool showBothWidgets = false;
    if (parent != null) {
      String parentName = parent!.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // Special case: If parent is Container and child is image-related, just show Container

      // Special case: If target is Container with styling, check if it has layout children
      if (targetName == 'Container') {
        final containerWidget = targetElement!.widget as Container;
        bool hasStyledProperties =
            containerWidget.decoration != null ||
            containerWidget.color != null ||
            containerWidget.constraints != null ||
            containerWidget.padding != null ||
            containerWidget.margin != null ||
            containerWidget.alignment != null;

        if (hasStyledProperties) {
          // Check if Container has immediate layout child
          Element? layoutChild;
          targetElement.visitChildren((child) {
            if (_isWidgetMeaningful(child)) {
              String childName = child.widget.runtimeType
                  .toString()
                  .split('<')
                  .first;
              if ({
                'Column',
                'Row',
                'Stack',
                'Flex',
                'Wrap',
              }.contains(childName)) {
                layoutChild = child;
              }
            }
          });

          if (layoutChild != null) {
            showBothWidgets = true;
          } else {
            showBothWidgets = false;
          }
        }
      } else if (parentName == 'Container' &&
          imageRelatedWidgets.contains(targetName)) {
        // Don't show both, just Container
        showBothWidgets = false;
      } else if (parentName == 'Container') {
        // Check if Container has visual styling (not just spacing) - if so, prioritize Container over layout children
        final containerWidget = parent!.widget as Container;
        bool hasVisualStyling =
            containerWidget.decoration != null ||
            containerWidget.color != null ||
            containerWidget.constraints != null ||
            containerWidget.alignment != null;
        // For visually styled containers with layout children (Row, Column, Stack),
        // check if we should show both widgets or just Container
        Set<String> layoutChildren = {'Row', 'Column', 'Stack', 'Flex'};
        if (hasVisualStyling && layoutChildren.contains(targetName)) {
          // For styled containers, still apply size-based logic to decide if popup should show
          // Continue with normal size-based logic rather than forcing showBothWidgets = false
        } else {
          // Continue with normal size-based logic for non-styled containers
          final targetBounds = targetElement!.renderObject?.semanticBounds;
          final parentBounds = parent!.renderObject?.semanticBounds;

          if (targetBounds != null && parentBounds != null) {
            // Calculate how much of the parent space is occupied by the child
            double childFillsParentRatio =
                (targetBounds.width * targetBounds.height) /
                (parentBounds.width * parentBounds.height);

            if (childFillsParentRatio >= 0.8) {
              showBothWidgets = true;
            }
          }
        }
      } else {
        // For non-Container parents, use the original size-based logic
        final targetBounds = targetElement!.renderObject?.semanticBounds;
        final parentBounds = parent!.renderObject?.semanticBounds;

        if (targetBounds != null && parentBounds != null) {
          // Calculate how much of the parent space is occupied by the child
          double childFillsParentRatio =
              (targetBounds.width * targetBounds.height) /
              (parentBounds.width * parentBounds.height);

          // Only show both for layout widgets that truly share the same space
          // Don't show both if target is already a meaningful content widget
          Set<String> contentWidgets = {
            // Removed 'Container' from here to allow popup for Container + layout children
            'Card',
            'Text',
            'Icon',
            'Image',
            'Button',
            'TextField',
          };

          if (contentWidgets.contains(targetName)) {
            showBothWidgets = false;
          } else if (childFillsParentRatio >= 0.8) {
            showBothWidgets = true;
          } else {}
        }
      }
    }

    // Priority 1: Always show Container for image-related widgets
    if (containerParent != null && imageRelatedWidgets.contains(targetName)) {
      widgets.add({'element': containerParent!, 'displayName': 'Container'});
    }
    // Priority 2: Show Container when it's the parent, but only for widgets that are not directly selectable
    else if (parent != null &&
        parent!.widget.runtimeType.toString().split('<').first == 'Container' &&
        !directlySelectableWidgets.contains(targetName) &&
        !directlySelectableLayoutWidgets.contains(targetName)) {
      widgets.add({'element': parent!, 'displayName': 'Container'});
    }
    // Priority 2.5: Show content widgets and layout widgets directly even if Container is parent
    // BUT: Special case for styled Container + Column - show popup instead of just Column
    else if (parent != null &&
        parent!.widget.runtimeType.toString().split('<').first == 'Container' &&
        (directlySelectableWidgets.contains(targetName) ||
            directlySelectableLayoutWidgets.contains(targetName))) {
      // Special handling for Column with styled Container parent
      if (targetName == 'Column' && containerParent != null) {
        final containerWidget = containerParent!.widget as Container;
        bool hasVisualStyling =
            containerWidget.decoration != null ||
            containerWidget.color != null ||
            containerWidget.constraints != null ||
            containerWidget.alignment != null ||
            containerWidget.margin != null ||
            containerWidget.padding != null;

        if (hasVisualStyling) {
          widgets.add({
            'element': containerParent!,
            'displayName': 'Container',
          });
          widgets.add({'element': targetElement, 'displayName': targetName});
        } else {
          // Non-styled Container, show Column directly
          widgets.add({'element': targetElement, 'displayName': targetName});
        }
      } else if (targetName == 'Container') {
        // SPECIAL FIX: For Container target with Container parent, show the target Container directly
        widgets.add({'element': targetElement, 'displayName': targetName});
      } else {
        // For other widgets, show them directly
        widgets.add({'element': targetElement, 'displayName': targetName});
      }
    }
    // Priority 2.7: Show styled Container when it's parent and showBothWidgets is false
    // BUT allow popup for layout children of styled containers
    else if (parent != null &&
        parent!.widget.runtimeType.toString().split('<').first == 'Container' &&
        !showBothWidgets) {
      // Check if this Container has visual styling (including spacing)
      final containerWidget = parent!.widget as Container;
      bool hasVisualStyling =
          containerWidget.decoration != null ||
          containerWidget.color != null ||
          containerWidget.constraints != null ||
          containerWidget.alignment != null ||
          containerWidget.margin != null ||
          containerWidget.padding != null;

      // Check if target is a layout widget that should show popup with Container
      Set<String> layoutWidgetsForPopup = {'Column', 'Row', 'Stack'};

      if (hasVisualStyling && layoutWidgetsForPopup.contains(targetName)) {
        // For styled Container + layout child, show popup with both
        widgets.add({'element': parent!, 'displayName': 'Container'});
        widgets.add({'element': targetElement, 'displayName': targetName});
      } else if (hasVisualStyling) {
        // For other cases with styled container, show just Container
        widgets.add({'element': parent!, 'displayName': 'Container'});
      } else {
        // Non-styled container, show the target widget
        widgets.add({'element': targetElement, 'displayName': targetName});
      }
    }
    // Priority 3: Show both widgets if they share space
    else if (showBothWidgets && parent != null) {
      String parentName = parent!.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // Add parent first
      widgets.add({'element': parent!, 'displayName': parentName});

      // Add child second
      widgets.add({'element': targetElement, 'displayName': targetName});
      ;
    }
    // Priority 3.5: Special case for Container target with layout child when showBothWidgets is true
    else if (showBothWidgets && targetName == 'Container') {
      // Find immediate layout child
      Element? layoutChild;
      targetElement!.visitChildren((child) {
        if (_isWidgetMeaningful(child)) {
          String childName = child.widget.runtimeType
              .toString()
              .split('<')
              .first;
          if ({'Column', 'Row', 'Stack', 'Flex', 'Wrap'}.contains(childName)) {
            layoutChild = child;
          }
        }
      });

      if (layoutChild != null) {
        String childName = layoutChild!.widget.runtimeType
            .toString()
            .split('<')
            .first;

        // Add Container first
        widgets.add({'element': targetElement, 'displayName': 'Container'});

        // Add layout child second
        widgets.add({'element': layoutChild!, 'displayName': childName});
      }
    }
    // Priority 4: Show just the target widget OR find meaningful child for scroll widgets
    else {
      // Special case: If target is a scroll widget, try to find its meaningful child
      if (displayName == 'SingleChildScrollView' ||
          displayName == 'ListView' ||
          displayName == 'GridView') {
        Element? meaningfulChild = _findMeaningfulChildOfScrollWidget(
          targetElement!,
        );

        if (meaningfulChild != null) {
          String childName = meaningfulChild.widget.runtimeType
              .toString()
              .split('<')
              .first;

          // Show both scroll widget and its meaningful child
          widgets.add({'element': targetElement, 'displayName': targetName});
          widgets.add({'element': meaningfulChild, 'displayName': childName});
        } else {
          // Just show the scroll widget
          widgets.add({'element': targetElement, 'displayName': targetName});
        }
      } else if (targetName == 'Container') {
        // Special handling for Container - check if it has layout children
        final containerWidget = targetElement!.widget as Container;
        bool hasVisualStyling =
            containerWidget.decoration != null ||
            containerWidget.color != null ||
            containerWidget.constraints != null ||
            containerWidget.alignment != null ||
            containerWidget.margin != null ||
            containerWidget.padding != null;

        if (hasVisualStyling) {
          // Look for immediate layout child
          Element? layoutChild;

          // First try visitChildren
          targetElement.visitChildren((child) {
            String childName = child.widget.runtimeType
                .toString()
                .split('<')
                .first;
            if ({
              'Column',
              'Row',
              'Stack',
              'Flex',
              'Wrap',
            }.contains(childName)) {
              layoutChild = child;
            }
          });

          // If only found Padding or other wrapper, search deeper
          if (layoutChild == null) {
            void searchDeeper(Element element, int depth) {
              if (layoutChild != null || depth > 5) return;

              element.visitChildren((child) {
                if (layoutChild != null) return;

                String childName = child.widget.runtimeType
                    .toString()
                    .split('<')
                    .first;

                if ({
                  'Column',
                  'Row',
                  'Stack',
                  'Flex',
                  'Wrap',
                }.contains(childName)) {
                  layoutChild = child;
                } else if (childName == 'Padding' ||
                    wrapperWidgetTypeNames.contains(childName)) {
                  // Search deeper through wrapper widgets
                  searchDeeper(child, depth + 1);
                }
              });
            }

            searchDeeper(targetElement, 1);
          }

          // If no child found via visitChildren, check Container's child property directly
          if (layoutChild == null && containerWidget.child != null) {
            // Get the child widget and find its element
            Widget? childWidget = containerWidget.child;
            if (childWidget != null) {
              String childTypeName = childWidget.runtimeType
                  .toString()
                  .split('<')
                  .first;
              if ({
                'Column',
                'Row',
                'Stack',
                'Flex',
                'Wrap',
              }.contains(childTypeName)) {
                // Try to find the element for this child widget
                Element? foundChild;
                targetElement.visitChildren((child) {
                  if (child.widget == childWidget) {
                    foundChild = child;
                  }
                });

                if (foundChild != null) {
                  layoutChild = foundChild;
                } else {
                  // Even if we can't find the element, we know there's a layout child
                  // Create a temporary marker to indicate we should show popup
                  layoutChild =
                      targetElement; // Use container element as placeholder
                }
              }
            }
          }

          if (layoutChild != null) {
            // Determine the child name - either from found element or from Container.child
            String childName;
            Element? childElement;

            if (layoutChild == targetElement && containerWidget.child != null) {
              // This means we detected a child via Container.child but couldn't find its element
              childName = containerWidget.child!.runtimeType
                  .toString()
                  .split('<')
                  .first;
              // Try one more time to find the child element
              targetElement.visitChildren((child) {
                String name = child.widget.runtimeType
                    .toString()
                    .split('<')
                    .first;
                if (name == childName) {
                  childElement = child;
                }
              });
            } else {
              // Normal case - we found the child element
              childName = layoutChild!.widget.runtimeType
                  .toString()
                  .split('<')
                  .first;
              childElement = layoutChild;
            }

            // Always show popup for styled Container with layout child
            widgets.add({'element': targetElement, 'displayName': 'Container'});

            if (childElement != null) {
              widgets.add({'element': childElement, 'displayName': childName});
            } else {
              // If we still can't find the child element, don't show popup
              widgets.clear();
              widgets.add({
                'element': targetElement,
                'displayName': 'Container',
              });
              return widgets;
            }
          } else {
            // Styled Container without layout child - just show Container
            widgets.add({'element': targetElement, 'displayName': targetName});
          }
        } else {
          // Non-styled Container - just show it
          widgets.add({'element': targetElement, 'displayName': targetName});
        }
      } else {
        // Regular widget - but check if it's a custom widget first
        if (_isCustomWidget(targetName)) {
          // Custom widget detected - analyze its internal structure and show popup if needed
          List<Map<String, dynamic>> internalWidgets =
              _findMeaningfulWidgetsInCustomWidget(targetElement!);

          if (internalWidgets.length >= 2) {
            // Multiple internal widgets - add them to show popup
            widgets.addAll(internalWidgets.take(3)); // Limit to 3 widgets
          } else if (internalWidgets.length == 1) {
            // Single internal widget - show it instead of custom widget
            widgets.add(internalWidgets.first);
          } else {
            // No internal widgets found - show custom widget itself
            widgets.add({'element': targetElement, 'displayName': targetName});
          }
        } else {
          // Regular built-in widget - just show it
          widgets.add({'element': targetElement, 'displayName': targetName});
        }
      }
    }
    return widgets;
  }

  List<Map<String, dynamic>> _filterInternalImplementations(
    List<Map<String, dynamic>> widgets,
  ) {
    if (widgets.length <= 1) return widgets;

    // Define mapping of high-level widgets to their internal implementations
    Map<String, Set<String>> internalImplementations = {
      'Text': {'RichText'},
      'ElevatedButton': {'_ElevatedButtonWithIcon', '_MaterialButton'},
      'TextButton': {'_TextButtonWithIcon', '_MaterialButton'},
      'OutlinedButton': {'_OutlinedButtonWithIcon', '_MaterialButton'},
      'FloatingActionButton': {'_FloatingActionButtonType'},
      'Icon': {'RichText'},
      'IconButton': {'_IconButtonM3'},
      'TextField': {'EditableText', 'InputDecorator'},
      'TextFormField': {'TextField', 'EditableText', 'InputDecorator'},
    };

    // Get all widget names in the current selection
    Set<String> widgetNames = widgets
        .map((w) => w['displayName'] as String)
        .toSet();

    // Find widgets to remove (internal implementations that have high-level equivalents present)
    Set<String> toRemove = {};

    for (String highLevel in internalImplementations.keys) {
      if (widgetNames.contains(highLevel)) {
        // High-level widget is present, remove its internal implementations
        Set<String> internals = internalImplementations[highLevel]!;
        toRemove.addAll(internals.where(widgetNames.contains));
      }
    }

    // Filter out the internal implementations
    List<Map<String, dynamic>> filtered = widgets.where((widget) {
      String name = widget['displayName'] as String;
      return !toRemove.contains(name);
    }).toList();

    return filtered;
  }

  Element? _findDeepestMeaningfulWidget(Element startElement, Offset position) {
    // Simple approach: find the deepest meaningful widget without complex overrides
    Element? deepestMeaningful = _isWidgetMeaningful(startElement)
        ? startElement
        : null;

    // Recursively check children to find the deepest meaningful widget
    startElement.visitChildren((child) {
      final childRender = child.renderObject;
      if (childRender != null &&
          _renderObjectContainsPosition(childRender, position)) {
        Element? deeperMeaningful = _findDeepestMeaningfulWidget(
          child,
          position,
        );
        if (deeperMeaningful != null) {
          deepestMeaningful = deeperMeaningful;
        }
      }
    });

    // Handle internal widgets - map them to their parent widgets
    if (deepestMeaningful != null) {
      String typeName = deepestMeaningful!.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // Map internal widgets to their high-level parents
      if (typeName == 'InkWell' || typeName == 'InkResponse') {
        Element? buttonParent = _findButtonParent(startElement);
        if (buttonParent != null) {
          deepestMeaningful = buttonParent;
        }
      } else if (typeName == 'InputDecorator' || typeName == 'EditableText') {
        Element? formFieldParent = _findFormFieldParent(startElement);
        if (formFieldParent != null) {
          deepestMeaningful = formFieldParent;
        }
      }
    }

    // If no meaningful widget found, look for meaningful parent
    if (deepestMeaningful == null) {
      Element? meaningfulParent = _findMeaningfulParent(startElement);
      if (meaningfulParent != null) {
        deepestMeaningful = meaningfulParent;
      } else {
        // Final fallback
        deepestMeaningful = startElement;
      }
    }

    // DON'T override the deepest widget - let the collection logic handle parent-child relationships
    return deepestMeaningful;
  }

  bool _isWidgetMeaningful(Element element) {
    String typeName = element.widget.runtimeType.toString().split('<').first;

    // Special handling for internal button implementations
    Set<String> meaningfulInternalWidgets = {
      '_ElevatedButtonWithIcon',
      '_TextButtonWithIcon',
      '_OutlinedButtonWithIcon',
      '_FloatingActionButtonType',
    };

    if (meaningfulInternalWidgets.contains(typeName)) {
      return true;
    }

    // Skip other internal/private widgets
    if (typeName.startsWith('_') || typeName.startsWith('Render')) {
      return false;
    }

    // Explicitly meaningful widgets that should always be selectable
    Set<String> alwaysMeaningfulWidgets = {
      'CircleAvatar',
      'Card',
      'Chip',
      'Badge',
      'Avatar',
      'ListTile',
      'GridTile',
      'ExpansionTile',
      'Drawer',
      'AppBar',
      'BottomNavigationBar',
      'TabBar',
      'TabBarView',
      'IconButton', // Added IconButton
      'ElevatedButton',
      'TextButton',
      'OutlinedButton',
      'FloatingActionButton',
      'MaterialButton',
      'SnackBar',
      'Dialog',
      'AlertDialog',
      'SimpleDialog',
      'BottomSheet',
      'Tooltip',
      'PopupMenuButton',
      'DropdownButton',
      'Switch',
      'Checkbox',
      'Radio',
      'Slider',
      'RangeSlider',
      'DatePicker',
      'TimePicker',
      'Stepper',
      'PageView',
      'DataTable',
      'PaginatedDataTable',
    };

    if (alwaysMeaningfulWidgets.contains(typeName)) {
      return true;
    }

    // Special handling for Container - check if it has visual styling (including spacing)
    if (typeName == 'Container') {
      final widget = element.widget as Container;
      bool hasVisualStyling =
          widget.decoration != null ||
          widget.color != null ||
          widget.constraints != null ||
          widget.alignment != null ||
          widget.margin != null ||
          widget.padding != null;

      return hasVisualStyling;
    }

    // Special handling for ColoredBox - this is what Flutter uses internally for Container(color: ...)
    if (typeName == 'ColoredBox') {
      return true; // ColoredBox is always meaningful as it provides visual styling
    }

    // Special handling for Center - when used inside Container, it indicates positioned content
    if (typeName == 'Center') {
      return true; // Center is meaningful as it provides layout positioning
    }

    // Use wrapper list for other widgets
    bool isWrapper = wrapperWidgetTypeNames.contains(typeName);
    return !isWrapper;
  }

  Element? _findMeaningfulParent(Element startElement) {
    Element? current = startElement;
    Element? firstMeaningfulWidget;
    Element? bestContainer;
    Element? bestFormField;
    Element? bestScrollWidget;

    // Stop searching after certain boundaries to avoid going too far up
    Set<String> stopAtWidgets = {
      'ListView',
      'GridView',
      'Scaffold',
      'MaterialApp',
      'CupertinoApp',
    };

    // Form field widgets that should be prioritized over their internal widgets
    Set<String> formFieldWidgets = {
      'TextFormField',
      'TextField',
      'DropdownButtonFormField',
      'CheckboxListTile',
      'RadioListTile',
      'SwitchListTile',
    };

    // Scrolling widgets that should be prioritized
    Set<String> scrollWidgets = {
      'SingleChildScrollView',
      'ListView',
      'GridView',
      'CustomScrollView',
      'PageView',
      'NestedScrollView',
    };

    while (current != null) {
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false; // Stop at first ancestor
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType
          .toString()
          .split('<')
          .first;
      bool isParentMeaningful = _isWidgetMeaningful(parent!);

      if (isParentMeaningful) {
        // Keep track of first meaningful widget found
        firstMeaningfulWidget ??= parent;

        // Prioritize scrolling widgets
        if (scrollWidgets.contains(parentTypeName)) {
          bestScrollWidget = parent;
          // Continue searching in case there's a form field above
        }

        // Prioritize form field widgets over their internal widgets
        if (formFieldWidgets.contains(parentTypeName)) {
          // Special case: if we found TextField, check if there's a TextFormField above it
          if (parentTypeName == 'TextField') {
            // Continue searching for potential TextFormField parent
            bestFormField = parent;
            // Don't break here - keep looking for TextFormField
          } else if (parentTypeName == 'TextFormField') {
            // TextFormField has highest priority - stop here
            bestFormField = parent;
            break;
          } else {
            // Other form field widgets
            bestFormField = parent;
            break;
          }
        }

        // Prioritize Container widgets with styling
        if (parentTypeName == 'Container') {
          bestContainer = parent;
          // Continue searching in case there's a form field above
        }

        // Stop at layout boundaries - these are too high level
        if (stopAtWidgets.contains(parentTypeName)) {
          break;
        }

        current = parent; // Continue searching
      } else {
        current = parent;
      }
    }

    // Return the best widget found with different priorities based on context
    // For image widgets, prioritize Container over ScrollWidget
    Element? result;

    if (bestFormField != null) {
      result = bestFormField;
    } else if (bestContainer != null && bestScrollWidget != null) {
      // If we have both Container and ScrollWidget, choose based on context
      String startTypeName = startElement.widget.runtimeType
          .toString()
          .split('<')
          .first;
      Set<String> imageWidgets = {
        'FadeWidget',
        'Image',
        'CustomImageWidget',
        'OctoImage',
        'CachedNetworkImage',
        'Stack',
      };

      if (imageWidgets.contains(startTypeName)) {
        result = bestContainer; // Prioritize Container for image widgets
      } else {
        result = bestScrollWidget; // Prioritize ScrollWidget for layout widgets
      }
    } else {
      result = bestContainer ?? bestScrollWidget ?? firstMeaningfulWidget;
    }

    return result;
  }

  Element? _findListViewParent(Element startElement) {
    Element? current = startElement;

    // ListView/GridView widgets that we want to detect and show
    // Note: Removed scrollbar widgets from this list as they are wrapper widgets,
    // not the actual ListView/GridView we want to find
    Set<String> listViewWidgets = {
      'ListView',
      'GridView',
      'CustomScrollView',
      'SingleChildScrollView',
      'PageView',
      'ListWheelScrollView',
      'ReorderableListView',
      'AnimatedList',
      'SliverAnimatedList',
      'AnimatedGrid',
      'SliverAnimatedGrid',
    };

    // Scrollbar widgets that we should continue searching beyond
    Set<String> scrollbarWidgets = {
      'CupertinoScrollbar',
      'Scrollbar',
      'RawScrollbar',
      '_MaterialScrollbar',
      'MaterialScrollbar',
      '_CupertinoScrollbar',
      '_RawScrollbar',
      '_BuiltInScrollbar',
      '_AdaptiveScrollbar',
    };

    // Check if the current element is already a ListView/GridView
    String currentTypeName = current.widget.runtimeType
        .toString()
        .split('<')
        .first;

    if (listViewWidgets.contains(currentTypeName)) {
      return current;
    }

    // Search up the widget tree for a ListView/GridView
    int depth = 0;
    while (current != null && depth < 50) {
      // Increased depth limit for ListView.builder's deep hierarchy
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false; // Stop at first ancestor
      });

      if (parent == null) {
        break;
      }

      String parentTypeName = parent!.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // If we find a ListView/GridView, return it
      if (listViewWidgets.contains(parentTypeName)) {
        return parent;
      }

      // Stop searching at major boundaries
      Set<String> stopAtWidgets = {
        'Scaffold',
        'MaterialApp',
        'CupertinoApp',
        'WidgetsApp',
      };
      if (stopAtWidgets.contains(parentTypeName)) {
        break;
      }

      current = parent;
      depth++;
    }
    return null;
  }

  Element? _findButtonParent(Element startElement) {
    Element? current = startElement;

    // Button widgets that we want to detect and show
    Set<String> buttonWidgets = {
      'IconButton', // Moved to top for priority
      'FloatingActionButton',
      'ElevatedButton',
      'TextButton',
      'OutlinedButton',
      'MaterialButton',
      'RawMaterialButton',
      'InkResponse',
      'InkWell', // CRITICAL: InkWell is the actual implementation for IconButton
      'CupertinoButton',
      'BackButton',
      'CloseButton',
      'PopupMenuButton',
      'DropdownButton',
      'DropdownButtonFormField',
      'MenuItemButton',
      'SubmenuButton',
      'MenuAnchor',
      'ButtonBar',
      'ToggleButtons',
      'Chip',
      'ActionChip',
      'FilterChip',
      'ChoiceChip',
      'InputChip',
      'RawChip',
      'Checkbox',
      'Radio',
      'Switch',
      'ExpansionTile',
      'ListTile',
      'CheckboxListTile',
      'RadioListTile',
      'SwitchListTile',
      // Internal button implementations
      '_ElevatedButtonWithIcon',
      '_TextButtonWithIcon',
      '_OutlinedButtonWithIcon',
      '_FloatingActionButtonType',
      '_IconButtonM3', // Added internal IconButton implementation
      '_InkResponseStateWidget', // Internal InkWell implementation
      '_ParentInkResponseProvider', // Another internal implementation
    };

    // Check if the current element is already a button
    String currentTypeName = current.widget.runtimeType
        .toString()
        .split('<')
        .first;
    // Debug logging removed to avoid spam during hover
    if (buttonWidgets.contains(currentTypeName)) {
      return current;
    }

    // Search up the widget tree for a button with increased depth for IconButton
    int searchDepth = 0;
    while (current != null && searchDepth < 25) {
      // Increased depth limit for IconButton
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false; // Stop at first ancestor
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // Debug logging removed to avoid spam during hover

      // If we find a button, return it immediately
      if (buttonWidgets.contains(parentTypeName)) {
        return parent;
      }

      // For IconButton specifically, be more aggressive - don't stop at layout widgets
      // Only stop at major boundaries
      Set<String> stopAtWidgets = {
        'Scaffold',
        'MaterialApp',
        'CupertinoApp',
        'WidgetsApp',
        'AppBar', // Don't go beyond AppBar
        'BottomNavigationBar',
        'Drawer',
      };
      if (stopAtWidgets.contains(parentTypeName)) {
        break;
      }

      current = parent;
      searchDepth++;
    }

    // Debug logging removed to avoid spam during hover
    return null;
  }

  Element? _findCheckboxParent(Element startElement) {
    Element? current = startElement;

    // Checkbox-related widgets that we want to detect
    Set<String> checkboxWidgets = {
      'Checkbox',
      'Radio',
      'Switch',
      'CheckboxListTile',
      'RadioListTile',
      'SwitchListTile',
    };

    // Check if the current element is already a checkbox widget
    String currentTypeName = current.widget.runtimeType
        .toString()
        .split('<')
        .first;
    if (checkboxWidgets.contains(currentTypeName)) {
      return current;
    }

    // Search up the widget tree for a checkbox widget (limited depth)
    int searchDepth = 0;
    while (current != null && searchDepth < 5) {
      // Limited depth for checkbox detection
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false; // Stop at first ancestor
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // If we find a checkbox widget, return it immediately
      if (checkboxWidgets.contains(parentTypeName)) {
        return parent;
      }

      current = parent;
      searchDepth++;
    }

    return null;
  }

  Element? _findCustomWidgetParent(Element startElement) {
    Element? current = startElement;

    // Search up the widget tree for a custom widget (limited depth)
    int searchDepth = 0;
    while (current != null && searchDepth < 10) {
      // Limited depth for custom widget detection
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false; // Stop at first ancestor
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // If we find a custom widget, return it immediately
      if (_isCustomWidget(parentTypeName)) {
        return parent;
      }

      current = parent;
      searchDepth++;
    }

    return null;
  }

  Element? _findFormFieldParent(Element startElement) {
    Element? current = startElement;

    // Form field widgets that we want to detect and show
    Set<String> formFieldWidgets = {
      'TextFormField',
      'TextField',
      'DropdownButtonFormField',
      'CheckboxListTile',
      'RadioListTile',
      'SwitchListTile',
    };

    // Check if the current element is already a form field
    String currentTypeName = current.widget.runtimeType
        .toString()
        .split('<')
        .first;
    if (formFieldWidgets.contains(currentTypeName)) {
      return current;
    }

    // Search up the widget tree for a form field
    while (current != null) {
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false; // Stop at first ancestor
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // If we find a form field, return it
      if (formFieldWidgets.contains(parentTypeName)) {
        return parent;
      }

      // Stop searching at layout boundaries to avoid going too far up
      Set<String> stopAtWidgets = {
        'Column',
        'Row',
        'Stack',
        'ListView',
        'GridView',
        'Scaffold',
        'Card',
      };
      if (stopAtWidgets.contains(parentTypeName)) {
        break;
      }

      current = parent;
    }

    return null;
  }

  bool _renderObjectContainsPosition(
    RenderObject renderObject,
    Offset globalPosition,
  ) {
    try {
      final Matrix4 transform = renderObject.getTransformTo(null);
      final Matrix4? inverse = Matrix4.tryInvert(transform);
      if (inverse == null) return false;

      final Offset localPosition = MatrixUtils.transformPoint(
        inverse,
        globalPosition,
      );
      final Rect bounds = renderObject.semanticBounds;
      return bounds.contains(localPosition);
    } catch (e) {
      return false;
    }
  }

  Element? _findMeaningfulChildOfScrollWidget(Element scrollElement) {
    Element? meaningfulChild;

    // Look for layout widgets that should be shown with scroll widgets
    Set<String> layoutWidgetsForScrollViews = {
      'Column',
      'Row',
      'Stack',
      'Container',
      'Card',
      'ListView',
      'GridView',
    };

    void searchForLayoutChild(Element element, int depth) {
      if (meaningfulChild != null || depth > 15) {
        return; // Stop if found or too deep
      }

      element.visitChildren((child) {
        if (meaningfulChild != null) return;

        String childTypeName = child.widget.runtimeType
            .toString()
            .split('<')
            .first;

        // For layout widgets, don't require _isWidgetMeaningful check
        if (layoutWidgetsForScrollViews.contains(childTypeName)) {
          meaningfulChild = child;
          return;
        }

        // Continue searching in children
        searchForLayoutChild(child, depth + 1);
      });
    }

    searchForLayoutChild(scrollElement, 0);

    // If we didn't find a layout widget, look for any meaningful widget
    if (meaningfulChild == null) {
      void searchForAnyMeaningful(Element element, int depth) {
        if (meaningfulChild != null || depth > 15) return;

        element.visitChildren((child) {
          if (meaningfulChild != null) return;

          if (_isWidgetMeaningful(child)) {
            meaningfulChild = child;
            return;
          }

          searchForAnyMeaningful(child, depth + 1);
        });
      }

      searchForAnyMeaningful(scrollElement, 0);
    }

    return meaningfulChild;
  }

  void _selectWidget(Element element) {
    _popupTimer?.cancel();
    setState(() {
      _selectedElement = element;
      _selectedRenderObject = element.renderObject;
      _showWidgetPopup = false;
    });

    // Execute existing widget info logic
    try {
      var locationInfo = _getWidgetLocation(element);
      var location = locationInfo['location'] ?? '';
      var widgetName = locationInfo['widgetName'] ?? '';
      var matchingElement = locationInfo['matchingElement'];

      if (matchingElement != null && matchingElement is Element) {
        var parentWidgetName = _getParentWidgetType(matchingElement);

        var properties = _extractWidgetProperties(matchingElement, widgetName);
        if (location.isNotEmpty && widgetName.isNotEmpty) {
          var widgetInfo = <String, dynamic>{};
          widgetInfo['widgetName'] = widgetName;
          widgetInfo['parentWidgetName'] = parentWidgetName;
          widgetInfo['location'] = location;
          widgetInfo['props'] = properties;

          _sendWidgetInformation(widgetInfo);
        }
      } 
      // else {
      //   print(
      //     'matchingElement is null or not an Element, skipping widget info extraction',
      //   );
      // }
    } catch (err) {
      // Silent error handling
      // print('error _selectWidget: $err');
    }
  }

  Widget _buildWidgetSelectionPopup() {
    // Limit to max 3 widgets
    final displayWidgets = _availableWidgets.take(3).toList();

    // Use tap position directly - more reliable for Flutter web
    double left = _popupPosition.dx;
    double top = _popupPosition.dy + 15; // Show below cursor

    // Get screen size to avoid edges - use MediaQuery.maybeOf for safety
    final screenSize = MediaQuery.maybeOf(context)?.size ?? Size(800, 600);

    // Calculate dynamic width based on content
    double maxTextWidth = 80.0; // minimum width
    for (var widget in displayWidgets) {
      String displayName = widget['displayName'] as String;
      // Rough estimate: 6 pixels per character + padding
      double textWidth = displayName.length * 6.0 + 16.0;
      maxTextWidth = math.max(maxTextWidth, textWidth);
    }
    final popupWidth = math.min(maxTextWidth, 200.0); // max 200px wide

    const itemHeight = 28.0;
    final popupHeight = displayWidgets.length * itemHeight;

    // Center horizontally around cursor
    left = left - (popupWidth / 2);

    // Adjust position to avoid edges
    if (left + popupWidth > screenSize.width) {
      left = screenSize.width - popupWidth - 10;
    }
    if (left < 10) {
      left = 10;
    }

    // If no space below, show above
    if (top + popupHeight > screenSize.height) {
      top = _popupPosition.dy - popupHeight - 15;
    }

    // Final boundary check
    if (top < 10) top = 10;

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        ignoring: false,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: popupWidth,
            decoration: BoxDecoration(
              color: Color(0xFF0a0a0a),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Color.fromRGBO(255, 255, 255, 0.16),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: displayWidgets.asMap().entries.map((entry) {
                final index = entry.key;
                final widgetData = entry.value;
                final element = widgetData['element'] as Element;
                final displayName = widgetData['displayName'] as String;

                return InkWell(
                  onTap: () => _selectWidget(element),
                  child: Container(
                    height: itemHeight,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: index < displayWidgets.length - 1
                          ? Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(255, 255, 255, 0.08),
                                width: 0.5,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _listenEvent();
    super.initState();
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    super.dispose();
  }

  _listenEvent() {
    web.window.addEventListener(
      'message',
      (web.Event event) {
        try {
          final messageEvent = event as web.MessageEvent;
          if (messageEvent.data != null) {
            final data = messageEvent.data.dartify();
            if (data is Map &&
                data.containsKey('inspectToggle') &&
                data['inspectToggle'] is bool) {
              isInspectorEnabled = data['inspectToggle'];
              // print('isInspectorEnabled: $isInspectorEnabled');
              setState(() {});
            }
          }
        } catch (e) {
          // print('error listening to inspectToggle message: $e');
        }
      }.toJS,
    );
  }

  // Add throttling for hover events
  DateTime? _lastHoverTime;
  static const Duration _hoverThrottleDelay = Duration(milliseconds: 100);

  void _handleHover(PointerHoverEvent event) {
    if (!isInspectorEnabled) return;

    // Throttle hover events to prevent excessive processing
    final now = DateTime.now();
    if (_lastHoverTime != null &&
        now.difference(_lastHoverTime!) < _hoverThrottleDelay) {
      return;
    }
    _lastHoverTime = now;

    // Close popup if mouse moves away from popup area
    if (_showWidgetPopup) {
      final distance = (event.position - _popupPosition).distance;
      if (distance > 100) {
        _popupTimer?.cancel();
        setState(() {
          _showWidgetPopup = false;
        });
      }
      return; // Don't update selection while popup is showing
    }

    // Use same widget detection as tap but without debug logging
    List<Map<String, dynamic>> meaningfulWidgets =
        _collectMeaningfulWidgetsAtPosition(event.position, debugMode: false);

    if (meaningfulWidgets.isNotEmpty) {
      // Use the first widget found (most relevant one)
      final selectedWidget = meaningfulWidgets.first;
      final Element selectedElement = selectedWidget['element'] as Element;
      final RenderObject? selectedRenderObject = selectedElement.renderObject;

      if (_selectedRenderObject != selectedRenderObject) {
        setState(() {
          _selectedRenderObject = selectedRenderObject;
          _selectedElement = selectedElement;
        });
      }
    } else if (_selectedRenderObject != null) {
      setState(() {
        _selectedRenderObject = null;
        _selectedElement = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (isInspectorEnabled && _selectedRenderObject != null) {
            setState(() {
              _selectedRenderObject = null;
              _selectedElement = null;
            });
          }
          return false;
        },
        child: Stack(
          children: [
            // Main child widget - no IgnorePointer wrapper
            MouseRegion(
              onExit: (_) {
                if (isInspectorEnabled) {
                  setState(() {
                    _selectedRenderObject = null;
                    _selectedElement = null;
                  });
                }
              },
              onHover: isInspectorEnabled ? _handleHover : null,
              child: KeyedSubtree(
                key: _childKey,
                child: Stack(
                  children: [
                    widget.child, // Original UI
                    if (isInspectorEnabled)
                      Positioned.fill(
                        child: Listener(
                          behavior: HitTestBehavior
                              .translucent, // Allow scrolling to pass through
                          onPointerDown: _handlePointerEvent,
                          onPointerHover: _handleHover,
                          child: RawGestureDetector(
                            behavior: HitTestBehavior
                                .translucent, // Allow scrolling to pass through
                            gestures: <Type, GestureRecognizerFactory>{
                              // Only intercept tap gestures, let scroll gestures pass through
                              TapGestureRecognizer:
                                  GestureRecognizerFactoryWithHandlers<
                                    TapGestureRecognizer
                                  >(() => TapGestureRecognizer(), (
                                    TapGestureRecognizer instance,
                                  ) {
                                    instance
                                        .onTapDown = (TapDownDetails details) {
                                      // Store tap position for use in onTap
                                      _lastTapPosition = details.globalPosition;
                                    };
                                    instance.onTap = () {
                                      _handleTap(_lastTapPosition);
                                    };
                                  }),
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Overlay showing the selected widget
            if (isInspectorEnabled && _selectedRenderObject != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _InspectorOverlayPainter(
                      selectedRenderObject: _selectedRenderObject!,
                      selectedElement: _selectedElement,
                    ),
                  ),
                ),
              ),

            // Widget selection popup - positioned in same Stack as colored overlay
            if (isInspectorEnabled && _showWidgetPopup)
              _buildWidgetSelectionPopup(),
          ],
        ),
      ),
    );
  }

  RenderObject? _findRenderObjectAtPosition(
    Offset position,
    RenderObject root,
  ) {
    // Simple hit test to find the smallest render object at the given position
    final List<RenderObject> hits = <RenderObject>[];
    _hitTestHelper(hits, position, root, root.getTransformTo(null));

    if (hits.isEmpty) return null;

    // Sort by size (smallest first)
    hits.sort((RenderObject a, RenderObject b) {
      final Size sizeA = a.semanticBounds.size;
      final Size sizeB = b.semanticBounds.size;
      return (sizeA.width * sizeA.height).compareTo(sizeB.width * sizeB.height);
    });

    return hits.first;
  }

  bool _hitTestHelper(
    List<RenderObject> hits,
    Offset position,
    RenderObject object,
    Matrix4 transform,
  ) {
    bool hit = false;
    final Matrix4? inverse = Matrix4.tryInvert(transform);
    if (inverse == null) {
      return false;
    }
    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);

    // Check children first
    final List<DiagnosticsNode> children = object.debugDescribeChildren();
    for (int i = children.length - 1; i >= 0; i -= 1) {
      final DiagnosticsNode diagnostics = children[i];
      if (diagnostics.style == DiagnosticsTreeStyle.offstage ||
          diagnostics.value is! RenderObject) {
        continue;
      }
      final RenderObject child = diagnostics.value! as RenderObject;
      final Rect? paintClip = object.describeApproximatePaintClip(child);
      if (paintClip != null && !paintClip.contains(localPosition)) {
        continue;
      }

      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      if (_hitTestHelper(hits, position, child, childTransform)) {
        hit = true;
      }
    }

    // Check this object
    final Rect bounds = object.semanticBounds;
    if (bounds.contains(localPosition)) {
      hit = true;
      hits.add(object);
    }

    return hit;
  }

  Element? _findElementForRenderObject(RenderObject renderObject) {
    Element? result;
    void visitor(Element element) {
      if (element.renderObject == renderObject) {
        result = element;
        return;
      }
      element.visitChildren(visitor);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitor);
    return result;
  }
}

class _InspectorOverlayPainter extends CustomPainter {
  final RenderObject selectedRenderObject;
  final Element? selectedElement;

  _InspectorOverlayPainter({
    required this.selectedRenderObject,
    required this.selectedElement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!selectedRenderObject.attached) return;

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(128, 128, 128, 255);

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color.fromARGB(128, 64, 64, 128);

    // Transform to the coordinate system of the selected object
    final Matrix4 transform = selectedRenderObject.getTransformTo(null);
    final Rect bounds = selectedRenderObject.semanticBounds;

    canvas.save();
    canvas.transform(transform.storage);

    // FIX: Don't deflate small widgets - use a minimum deflate value
    final double deflateAmount = bounds.width < 40 || bounds.height < 40
        ? 0.0
        : 0.5;
    final Rect fillRect = bounds.deflate(deflateAmount);
    final Rect borderRect = bounds.deflate(deflateAmount);

    // Ensure we have positive dimensions
    if (fillRect.width > 0 && fillRect.height > 0) {
      canvas.drawRect(fillRect, fillPaint);
      canvas.drawRect(borderRect, borderPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InspectorOverlayPainter oldDelegate) {
    return selectedRenderObject != oldDelegate.selectedRenderObject ||
        selectedElement != oldDelegate.selectedElement;
  }
}

String _getParentWidgetType(Element element) {
  Element? parent;
  element.visitAncestorElements((Element ancestor) {
    parent = ancestor;
    return false;
  });
  return parent?.widget.runtimeType.toString() ?? 'None';
}

/// Widget location result containing all relevant information
class WidgetLocationInfo {
  final String? location;
  final String? widgetName;
  final Element? matchingElement;
  final bool isValid;
  final String? error;

  const WidgetLocationInfo({
    this.location,
    this.widgetName,
    this.matchingElement,
    this.isValid = false,
    this.error,
  });

  factory WidgetLocationInfo.success({
    required String location,
    required String widgetName,
    required Element matchingElement,
  }) {
    return WidgetLocationInfo(
      location: location,
      widgetName: widgetName,
      matchingElement: matchingElement,
      isValid: true,
    );
  }

  factory WidgetLocationInfo.failure(String error) {
    return WidgetLocationInfo(isValid: false, error: error);
  }

  /// Convert to legacy format for backward compatibility
  Map<String, dynamic> toLegacyMap() {
    return {
      'location': location,
      'widgetName': widgetName,
      'matchingElement': matchingElement,
    };
  }
}

/// Configuration for location finding behavior
class LocationFinderConfig {
  final Set<String> excludedPaths;
  final int maxAncestorDepth;
  final bool skipWrapperWidgets;
  final bool debugMode;

  const LocationFinderConfig({
    this.excludedPaths = const {
      '/packages/flutter',
      'pub.dev',
      '/flutter_web_plugins',
      '/flutter_test',
      '/.dart_tool',
      '/build/',
    },
    this.maxAncestorDepth = 50,
    this.skipWrapperWidgets = true,
    this.debugMode = false,
  });

  /// Check if a file path should be excluded
  bool shouldExcludePath(String filePath) {
    if (filePath.isEmpty) return true;
    return excludedPaths.any((excluded) => filePath.contains(excluded));
  }
}

/// Robust widget location finder
class WidgetLocationFinder {
  final LocationFinderConfig config;

  const WidgetLocationFinder({this.config = const LocationFinderConfig()});

  /// Find widget location information starting from the given element
  WidgetLocationInfo findLocation(Element element) {
    try {
      // Skip wrapper widgets if configured
      Element? targetElement = config.skipWrapperWidgets
          ? _skipToNonWrapperWidget(element)
          : element;

      if (targetElement == null) {
        return WidgetLocationInfo.failure('No non-wrapper widget found');
      }

      // Try to find location in current element first
      WidgetLocationInfo? result = _extractLocationFromElement(targetElement);
      if (result != null && result.isValid) {
        return result;
      }

      // Search ancestors if not found in current element
      result = _searchAncestorsForLocation(targetElement);
      if (result != null && result.isValid) {
        return result;
      }

      return WidgetLocationInfo.failure(
        'No valid location found in element tree',
      );
    } catch (e) {
      return WidgetLocationInfo.failure(
        'Exception during location finding: $e',
      );
    }
  }

  /// Skip wrapper widgets and find the first meaningful widget
  Element? _skipToNonWrapperWidget(Element element) {
    Element? current = element;
    int depth = 0;
    const maxWrapperDepth = 10; // Prevent infinite loops

    while (current != null && depth < maxWrapperDepth) {
      String widgetTypeName = current.widget.runtimeType
          .toString()
          .split('<')
          .first;

      if (!_CustomWidgetInspectorState.wrapperWidgetTypeNames.contains(
        widgetTypeName,
      )) {
        return current; // Found non-wrapper widget
      }

      // Look for first child
      Element? childElement;
      current.visitChildren((child) {
        childElement ??= child;
      });

      current = childElement;
      depth++;
    }

    return current; // Return last found element even if it's a wrapper
  }

  /// Extract location information from a single element
  WidgetLocationInfo? _extractLocationFromElement(Element element) {
    try {
      DiagnosticsNode node = element.toDiagnosticsNode();
      var delegate = InspectorSerializationDelegate(
        service: WidgetInspectorService.instance,
        summaryTree: true,
        subtreeDepth: 1,
        includeProperties: true,
        expandPropertyValues: true,
      );

      final Map<String, Object?> json = node.toJsonMap(delegate);

      if (!json.containsKey('creationLocation')) {
        return null;
      }

      final Map creationLocation = json['creationLocation'] as Map;
      final String filePath = creationLocation['file']?.toString() ?? '';
      final String widgetName = creationLocation['name']?.toString() ?? '';

      if (config.shouldExcludePath(filePath)) {
        return null;
      }

      final String line = creationLocation['line']?.toString() ?? '0';
      final String column = creationLocation['column']?.toString() ?? '0';

      if (widgetName.isEmpty) {
        return null;
      }

      final String location = '$filePath:$line:$column';

      return WidgetLocationInfo.success(
        location: location,
        widgetName: widgetName,
        matchingElement: element,
      );
    } catch (e) {
      // print('🔍 LOCATION DEBUG: ERROR extracting location from element: $e');
      return null;
    }
  }

  /// Search ancestors for location information
  WidgetLocationInfo? _searchAncestorsForLocation(Element startElement) {
    WidgetLocationInfo? result;
    int depth = 0;

    startElement.visitAncestorElements((Element ancestor) {
      if (depth >= config.maxAncestorDepth) {
        return false; // Stop searching
      }

      result = _extractLocationFromElement(ancestor);
      depth++;

      // Continue searching if no valid result found
      return result == null || !result!.isValid;
    });

    return result;
  }
}

/// Legacy wrapper function for backward compatibility
Map<String, dynamic> _getWidgetLocation(Element element) {
  const finder = WidgetLocationFinder();
  final result = finder.findLocation(element);
  return result.toLegacyMap();
}

Element? _findInternalTextField(Element textFormFieldElement) {
  Element? textFieldElement;

  void searchForTextField(Element element, int depth) {
    if (textFieldElement != null || depth > 10) {
      return; // Stop if found or too deep
    }

    element.visitChildren((child) {
      if (textFieldElement != null) return;

      String childTypeName = child.widget.runtimeType
          .toString()
          .split('<')
          .first;

      // Look specifically for TextField widget
      if (childTypeName == 'TextField') {
        textFieldElement = child;
        return;
      }

      // Continue searching deeper in the element tree
      searchForTextField(child, depth + 1);
    });
  }

  searchForTextField(textFormFieldElement, 0);
  return textFieldElement;
}

Map<String, dynamic> _extractTextFieldProperties(
  TextField textFieldWidget,
  Element element,
) {
  final Map<String, dynamic> properties = {};

  properties['text'] = textFieldWidget.controller?.text ?? 'null';
  properties['style'] = getTextStyle(textFieldWidget.style, element);
  properties['readOnly'] = textFieldWidget.readOnly.toString();
  properties['obscureText'] = textFieldWidget.obscureText.toString();
  properties['autocorrect'] = textFieldWidget.autocorrect.toString();
  properties['keyboardType'] = _getKeyboardTypeDetails(
    textFieldWidget.keyboardType,
  );
  properties['textInputAction'] =
      textFieldWidget.textInputAction?.toString() ?? 'null';
  properties['maxLines'] = textFieldWidget.maxLines?.toString() ?? 'null';
  properties['maxLength'] = textFieldWidget.maxLength?.toString() ?? 'null';
  properties['autofocus'] = textFieldWidget.autofocus.toString();
  properties['textAlign'] = textFieldWidget.textAlign.toString();
  properties['textCapitalization'] = textFieldWidget.textCapitalization
      .toString();
  properties['enableSuggestions'] = textFieldWidget.enableSuggestions
      .toString();
  properties['showCursor'] = textFieldWidget.showCursor?.toString() ?? 'null';
  properties['cursorWidth'] = textFieldWidget.cursorWidth.toString();
  properties['cursorHeight'] =
      textFieldWidget.cursorHeight?.toString() ?? 'null';
  properties['cursorColor'] = textFieldWidget.cursorColor != null
      ? colorToHex(textFieldWidget.cursorColor!)
      : 'null';

  // Add decoration properties
  properties['decoration'] = {
    'border': textFieldWidget.decoration?.border.toString() ?? 'null',
    'enabledBorder':
        textFieldWidget.decoration?.enabledBorder.toString() ?? 'null',
    'focusedBorder':
        textFieldWidget.decoration?.focusedBorder.toString() ?? 'null',
    'disabledBorder':
        textFieldWidget.decoration?.disabledBorder.toString() ?? 'null',
    'errorBorder': textFieldWidget.decoration?.errorBorder.toString() ?? 'null',
    'focusedErrorBorder':
        textFieldWidget.decoration?.focusedErrorBorder.toString() ?? 'null',
    'fillColor': textFieldWidget.decoration?.fillColor != null
        ? colorToHex(textFieldWidget.decoration!.fillColor!)
        : 'null',
    'filled': textFieldWidget.decoration?.filled.toString() ?? 'null',
    'hintText': textFieldWidget.decoration?.hintText.toString() ?? 'null',
    'hintStyle': getTextStyle(textFieldWidget.decoration?.hintStyle, element),
    'labelText': textFieldWidget.decoration?.labelText.toString() ?? 'null',
    'labelStyle': getTextStyle(textFieldWidget.decoration?.labelStyle, element),
    'helperText': textFieldWidget.decoration?.helperText.toString() ?? 'null',
    'helperStyle': getTextStyle(
      textFieldWidget.decoration?.helperStyle,
      element,
    ),
    'errorText': textFieldWidget.decoration?.errorText.toString() ?? 'null',
    'errorStyle': getTextStyle(textFieldWidget.decoration?.errorStyle, element),
    'prefixIcon': textFieldWidget.decoration?.prefixIcon.toString() ?? 'null',
    'prefixIconConstraints':
        textFieldWidget.decoration?.prefixIconConstraints.toString() ?? 'null',
    'suffixIcon': textFieldWidget.decoration?.suffixIcon.toString() ?? 'null',
    'suffixIconConstraints':
        textFieldWidget.decoration?.suffixIconConstraints.toString() ?? 'null',
    'counterText': textFieldWidget.decoration?.counterText.toString() ?? 'null',
    'counterStyle': getTextStyle(
      textFieldWidget.decoration?.counterStyle,
      element,
    ),
  };

  return properties;
}

String _getKeyboardTypeDetails(TextInputType? keyboardType) {
  if (keyboardType == null) return "null";

  // Map common keyboard types to their names
  String typeName = 'unknown';
  if (keyboardType == TextInputType.text) {
    typeName = 'TextInputType.text';
  } else if (keyboardType == TextInputType.number) {
    typeName = 'TextInputType.number';
  } else if (keyboardType == TextInputType.emailAddress) {
    typeName = 'TextInputType.emailAddress';
  } else if (keyboardType == TextInputType.datetime) {
    typeName = 'TextInputType.datetime';
  } else if (keyboardType == TextInputType.multiline) {
    typeName = 'TextInputType.multiline';
  } else if (keyboardType == TextInputType.phone) {
    typeName = 'TextInputType.phone';
  } else if (keyboardType == TextInputType.url) {
    typeName = 'TextInputType.url';
  } else if (keyboardType == TextInputType.visiblePassword) {
    typeName = 'TextInputType.visiblePassword';
  } else if (keyboardType == TextInputType.name) {
    typeName = 'TextInputType.name';
  } else if (keyboardType == TextInputType.streetAddress) {
    typeName = 'TextInputType.streetAddress';
  } else if (keyboardType == TextInputType.none) {
    typeName = 'TextInputType.none';
  }

  return typeName;
}

Map<String, dynamic> _extractWidgetProperties(
  Element element,
  String widgetName,
) {
  final Map<String, dynamic> properties = {};
  switch (widgetName) {
    case 'Text':
      final widget = element.widget as Text;
      properties['type'] = 'Text';
      properties['text'] = widget.data;
      properties['style'] = getTextStyle(widget.style, element);
      properties['textAlign'] = widget.textAlign?.toString() ?? 'null';
      break;

    case 'ElevatedButton':
    case 'OutlinedButton':
    case 'TextButton':
      final buttonWidget = element.widget as ButtonStyleButton;
      properties['type'] = widgetName;
      // Button widget properties
      properties['enabled'] = (buttonWidget.onPressed != null).toString();
      properties['autofocus'] = buttonWidget.autofocus.toString();
      properties['clipBehavior'] = buttonWidget.clipBehavior.toString();

      // Extract child content
      final Widget? child = buttonWidget.child;
      if (child is Text) {
        properties['text'] = child.data ?? 'null';
        properties['childType'] = 'Text';
      } else if (child is Icon) {
        properties['text'] = 'null';
        properties['childType'] = 'Icon';
        properties['iconData'] = child.icon.toString();
      } else if (child is Row) {
        properties['childType'] = 'Row';
        properties['text'] = 'null';
      } else {
        properties['text'] = 'null';
        properties['childType'] = child?.runtimeType.toString() ?? 'null';
      }
      // Use getButtonStyle function for comprehensive style extraction with theme defaults
      final buttonStyleProperties = getButtonStyle(
        buttonWidget.style,
        element,
        widgetName,
      );
      properties.addAll(buttonStyleProperties);
      break;

    case 'Icon':
      final widget = element.widget as Icon;
      properties['type'] = 'Icon';
      properties['icon'] = widget.icon.toString();
      properties['color'] = widget.color != null
          ? colorToHex(widget.color!)
          : 'null';
      properties['size'] = widget.size?.toString() ?? 'null';
      break;

    case 'Container':
      final widget = element.widget as Container;
      properties['type'] = 'Container';
      properties['color'] = widget.color != null
          ? colorToHex(widget.color!)
          : 'null';
      properties['width'] = widget.constraints?.maxWidth.toString() ?? 'null';
      properties['height'] = widget.constraints?.maxHeight.toString() ?? 'null';
      properties['padding'] = widget.padding?.toString() ?? 'null';
      properties['margin'] = widget.margin?.toString() ?? 'null';
      if (widget.decoration is BoxDecoration) {
        final boxDecoration = widget.decoration as BoxDecoration;
        properties['decoration'] = {
          'color': boxDecoration.color != null
              ? colorToHex(boxDecoration.color!)
              : 'null',
          'border': _getBorderDetails(boxDecoration.border as Border?),
          'borderRadius': _getBorderRadiusDetails(boxDecoration.borderRadius),
          'boxShadow': _getBoxShadowDetails(boxDecoration.boxShadow),
          'gradient': _getGradientDetails(boxDecoration.gradient),
          'image': _getDecorationImageDetails(boxDecoration.image),
          'shape': boxDecoration.shape.toString(),
        };
      }
      properties['alignment'] = widget.alignment?.toString() ?? 'null';
      break;

    case 'TextField':
      final widget = element.widget as TextField;
      properties['type'] = widgetName;

      // Use common function to extract TextField properties
      final textFieldProperties = _extractTextFieldProperties(widget, element);
      properties.addAll(textFieldProperties);
      break;

    case 'TextFormField':
      final widget = element.widget as TextFormField;
      properties['type'] = widgetName;
      properties['initialValue'] = widget.initialValue ?? 'null';
      properties['text'] = widget.controller?.text ?? 'null';
      properties['enabled'] = widget.enabled.toString();
      properties['autovalidateMode'] = widget.autovalidateMode.toString();
      properties['forceErrorText'] = widget.forceErrorText ?? 'null';

      // Try to find the internal TextField and extract its properties
      Element? textFieldElement = _findInternalTextField(element);
      if (textFieldElement != null) {
        final textFieldWidget = textFieldElement.widget as TextField;

        // Use common function to extract TextField properties
        final textFieldProperties = _extractTextFieldProperties(
          textFieldWidget,
          element,
        );
        properties.addAll(textFieldProperties);
      }
      break;

    case 'Column':
    case 'Row':
      final widget = element.widget as Flex;
      properties['type'] = widget.runtimeType.toString();
      properties['mainAxisAlignment'] = widget.mainAxisAlignment.toString();
      properties['crossAxisAlignment'] = widget.crossAxisAlignment.toString();
      properties['mainAxisSize'] = widget.mainAxisSize.toString();
      properties['spacing'] = widget.spacing.toString();
      break;

    case 'RichText':
      final widget = element.widget as RichText;
      properties['type'] = 'RichText';

      // Basic RichText properties
      properties['textAlign'] = widget.textAlign.toString();
      properties['maxLines'] = widget.maxLines?.toString() ?? 'null';

      // Extract TextSpan tree with all styles
      properties['textSpan'] = _extractTextSpanDetails(
        widget.text as TextSpan,
        element,
        null,
      );
      break;

    case 'ListTile':
      final widget = element.widget as ListTile;
      properties['type'] = 'ListTile';
      properties['title'] = widget.title is Text
          ? (widget.title as Text).data
          : 'null';
      properties['subtitle'] = widget.subtitle is Text
          ? (widget.subtitle as Text).data
          : 'null';
      properties['leading'] = widget.leading.runtimeType.toString();
      properties['trailing'] = widget.trailing.runtimeType.toString();
      break;

    case 'Checkbox':
      final widget = element.widget as Checkbox;
      final defaultStyle = Theme.of(element).checkboxTheme;
      properties['type'] = 'Checkbox';
      properties['value'] = widget.value.toString();
      properties['tristate'] = widget.tristate.toString();
      final activeColor = defaultStyle.fillColor?.resolve({
        WidgetState.selected,
      });
      properties['activeColor'] = widget.activeColor != null
          ? colorToHex(widget.activeColor!)
          : defaultStyle.fillColor != null
          ? activeColor != null
                ? colorToHex(activeColor)
                : 'null'
          : 'null';

      final checkColor = defaultStyle.checkColor?.resolve({});
      properties['checkColor'] = widget.checkColor != null
          ? colorToHex(widget.checkColor!)
          : defaultStyle.checkColor != null
          ? checkColor != null
                ? colorToHex(checkColor)
                : 'null'
          : 'null';
      final defaultSide = defaultStyle.side;
      properties['border'] = widget.side != null
          ? _getBorderSideDetails(widget.side!)
          : defaultSide != null
          ? _getBorderSideDetails(defaultSide)
          : 'null';
      final defaultShape = defaultStyle.shape;
      properties['shape'] = widget.shape != null
          ? _getShapeDetails(widget.shape!)
          : defaultShape != null
          ? _getShapeDetails(defaultShape)
          : 'null';
      break;

    case 'Switch':
      final widget = element.widget as Switch;
      final defaultStyle = Theme.of(element).switchTheme;
      properties['type'] = 'Switch';
      properties['value'] = widget.value.toString();

      // activeColor with theme default
      final defaultActiveColor = defaultStyle.thumbColor?.resolve({
        WidgetState.selected,
      });
      properties['activeColor'] = widget.activeColor != null
          ? colorToHex(widget.activeColor!)
          : defaultActiveColor != null
          ? colorToHex(defaultActiveColor)
          : 'null';

      // inactiveThumbColor with theme default
      final defaultInactiveThumbColor = defaultStyle.thumbColor?.resolve({});
      properties['inactiveThumbColor'] = widget.inactiveThumbColor != null
          ? colorToHex(widget.inactiveThumbColor!)
          : defaultInactiveThumbColor != null
          ? colorToHex(defaultInactiveThumbColor)
          : 'null';

      // activeTrackColor with theme default
      final defaultActiveTrackColor = defaultStyle.trackColor?.resolve({
        WidgetState.selected,
      });
      properties['activeTrackColor'] = widget.activeTrackColor != null
          ? colorToHex(widget.activeTrackColor!)
          : defaultActiveTrackColor != null
          ? colorToHex(defaultActiveTrackColor)
          : 'null';

      // inactiveTrackColor with theme default
      final defaultInactiveTrackColor = defaultStyle.trackColor?.resolve({});
      properties['inactiveTrackColor'] = widget.inactiveTrackColor != null
          ? colorToHex(widget.inactiveTrackColor!)
          : defaultInactiveTrackColor != null
          ? colorToHex(defaultInactiveTrackColor)
          : 'null';

      // padding with theme default
      final defaultPadding = defaultStyle.padding?.resolve(TextDirection.ltr);
      properties['padding'] = widget.padding != null
          ? widget.padding.toString()
          : defaultPadding != null
          ? defaultPadding.toString()
          : 'null';
      break;

    case 'Radio':
      final widget = element.widget as Radio;
      final defaultStyle = Theme.of(element).radioTheme;
      properties['type'] = 'Radio';

      // Basic properties
      properties['value'] = widget.value.toString();
      properties['groupValue'] = widget.groupValue.toString();

      // Visual properties with theme fallbacks
      final activeColor = defaultStyle.fillColor?.resolve({
        WidgetState.selected,
      });
      properties['activeColor'] = widget.activeColor != null
          ? colorToHex(widget.activeColor!)
          : activeColor != null
          ? colorToHex(activeColor)
          : 'null';

      // Size properties
      properties['splashRadius'] = widget.splashRadius != null
          ? widget.splashRadius.toString()
          : defaultStyle.splashRadius != null
          ? defaultStyle.splashRadius.toString()
          : kRadialReactionRadius.toString();
      break;

    default:
      properties['type'] = widgetName;
      properties['info'] =
          'There are no editable properties available for this widget.';
      break;
  }

  return properties;
}

Map<String, dynamic> getTextStyle(TextStyle? style, BuildContext context) {
  final defaultStyle = DefaultTextStyle.of(context).style;

  return {
    'color': style?.color != null
        ? colorToHex(style!.color!)
        : (defaultStyle.color != null
              ? colorToHex(defaultStyle.color!)
              : 'null'),
    'fontSize':
        style?.fontSize?.round().toString() ??
        defaultStyle.fontSize?.round().toString() ??
        'null',
    'backgroundColor': style?.backgroundColor != null
        ? colorToHex(style!.backgroundColor!)
        : (defaultStyle.backgroundColor != null
              ? colorToHex(defaultStyle.backgroundColor!)
              : 'null'),
    'fontWeight':
        style?.fontWeight?.toString() ??
        defaultStyle.fontWeight?.toString() ??
        'null',
    'fontStyle':
        style?.fontStyle?.toString() ??
        defaultStyle.fontStyle?.toString() ??
        'null',
    'fontFamily': style?.fontFamily ?? defaultStyle.fontFamily ?? 'null',
    'letterSpacing':
        style?.letterSpacing?.toString() ??
        defaultStyle.letterSpacing?.toString() ??
        'null',
    'wordSpacing':
        style?.wordSpacing?.toString() ??
        defaultStyle.wordSpacing?.toString() ??
        'null',
    'textBaseline':
        style?.textBaseline?.toString() ??
        defaultStyle.textBaseline?.toString() ??
        'null',
    'height':
        style?.height?.toString() ?? defaultStyle.height?.toString() ?? 'null',
    'overflow':
        style?.overflow?.toString() ??
        defaultStyle.overflow?.toString() ??
        'null',
  };
}

/// Get button style with theme defaults fallback - similar to getTextStyle
Map<String, dynamic> getButtonStyle(
  ButtonStyle? style,
  BuildContext context,
  String buttonType,
) {
  // Get default button style from theme based on button type
  ButtonStyle? defaultStyle;
  switch (buttonType) {
    case 'ElevatedButton':
      defaultStyle = Theme.of(context).elevatedButtonTheme.style;
      break;
    case 'OutlinedButton':
      defaultStyle = Theme.of(context).outlinedButtonTheme.style;
      break;
    case 'TextButton':
      defaultStyle = Theme.of(context).textButtonTheme.style;
      break;
  }

  // Helper function to resolve WidgetStateProperty with fallback
  T? resolveWithFallback<T>(
    WidgetStateProperty<T>? widgetProperty,
    WidgetStateProperty<T>? defaultProperty,
  ) {
    final resolved = widgetProperty?.resolve({});
    if (resolved != null) return resolved;
    return defaultProperty?.resolve({});
  }

  return {
    'backgroundColor': () {
      final color = resolveWithFallback(
        style?.backgroundColor,
        defaultStyle?.backgroundColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'foregroundColor': () {
      final color = resolveWithFallback(
        style?.foregroundColor,
        defaultStyle?.foregroundColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'overlayColor': () {
      final color = resolveWithFallback(
        style?.overlayColor,
        defaultStyle?.overlayColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'shadowColor': () {
      final color = resolveWithFallback(
        style?.shadowColor,
        defaultStyle?.shadowColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'surfaceTintColor': () {
      final color = resolveWithFallback(
        style?.surfaceTintColor,
        defaultStyle?.surfaceTintColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'iconColor': () {
      final color = resolveWithFallback(
        style?.iconColor,
        defaultStyle?.iconColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'elevation': () {
      final elevation = resolveWithFallback(
        style?.elevation,
        defaultStyle?.elevation,
      );
      return elevation?.toString() ?? 'null';
    }(),
    'padding': () {
      final padding = resolveWithFallback(
        style?.padding,
        defaultStyle?.padding,
      );
      return padding?.toString() ?? 'null';
    }(),
    'minimumSize': () {
      final size = resolveWithFallback(
        style?.minimumSize,
        defaultStyle?.minimumSize,
      );
      return size?.toString() ?? 'null';
    }(),
    'fixedSize': () {
      final size = resolveWithFallback(
        style?.fixedSize,
        defaultStyle?.fixedSize,
      );
      return size?.toString() ?? 'null';
    }(),
    'maximumSize': () {
      final size = resolveWithFallback(
        style?.maximumSize,
        defaultStyle?.maximumSize,
      );
      return size?.toString() ?? 'null';
    }(),
    'iconSize': () {
      final size = resolveWithFallback(style?.iconSize, defaultStyle?.iconSize);
      return size?.toString() ?? 'null';
    }(),
    'side': () {
      final side = resolveWithFallback(style?.side, defaultStyle?.side);
      return side != null ? _getBorderSideDetails(side) : {};
    }(),
    'shape': () {
      final shape = resolveWithFallback(style?.shape, defaultStyle?.shape);
      return shape != null ? _getShapeDetails(shape) : {};
    }(),
    'textStyle': () {
      final textStyle = resolveWithFallback(
        style?.textStyle,
        defaultStyle?.textStyle,
      );
      return textStyle != null
          ? getTextStyle(textStyle, context)
          : getTextStyle(null, context);
    }(),
    'mouseCursor': () {
      final cursor = resolveWithFallback(
        style?.mouseCursor,
        defaultStyle?.mouseCursor,
      );
      return cursor?.toString() ?? 'null';
    }(),
    'visualDensity':
        style?.visualDensity?.toString() ??
        defaultStyle?.visualDensity?.toString() ??
        'null',
    'tapTargetSize':
        style?.tapTargetSize?.toString() ??
        defaultStyle?.tapTargetSize?.toString() ??
        'null',
    'animationDuration':
        style?.animationDuration?.toString() ??
        defaultStyle?.animationDuration?.toString() ??
        'null',
    'enableFeedback':
        style?.enableFeedback?.toString() ??
        defaultStyle?.enableFeedback?.toString() ??
        'null',
    'alignment':
        style?.alignment?.toString() ??
        defaultStyle?.alignment?.toString() ??
        'null',
    'splashFactory':
        style?.splashFactory?.toString() ??
        defaultStyle?.splashFactory?.toString() ??
        'null',
  };
}

String colorToHex(Color color) {
  var alphaColor = (color.a * 255)
      .round()
      .toRadixString(16)
      .padLeft(2, '0')
      .toUpperCase();
  var redColor = (color.r * 255)
      .round()
      .toRadixString(16)
      .padLeft(2, '0')
      .toUpperCase();
  var greenColor = (color.g * 255)
      .round()
      .toRadixString(16)
      .padLeft(2, '0')
      .toUpperCase();
  var blueColor = (color.b * 255)
      .round()
      .toRadixString(16)
      .padLeft(2, '0')
      .toUpperCase();
  return '0X$alphaColor$redColor$greenColor$blueColor';
}

Map<String, dynamic> _getBorderDetails(Border? border) {
  if (border == null) return {};

  return {
    'type': 'Border',
    'top': _getBorderSideDetails(border.top),
    'right': _getBorderSideDetails(border.right),
    'bottom': _getBorderSideDetails(border.bottom),
    'left': _getBorderSideDetails(border.left),
  };
}

Map<String, dynamic> _getBorderSideDetails(BorderSide borderSide) {
  return {
    'color': borderSide.color != Colors.transparent
        ? colorToHex(borderSide.color)
        : 'transparent',
    'width': borderSide.width.toString(),
    'style': borderSide.style.toString(),
    'strokeAlign': borderSide.strokeAlign.toString(),
  };
}

Map<String, dynamic> _getShapeDetails(OutlinedBorder shape) {
  Map<String, dynamic> details = {'type': shape.runtimeType.toString()};

  if (shape is RoundedRectangleBorder) {
    details.addAll({
      'borderRadius': _getBorderRadiusDetails(shape.borderRadius),
      'side': _getBorderSideDetails(shape.side),
    });
  } else if (shape is CircleBorder) {
    details.addAll({'side': _getBorderSideDetails(shape.side)});
  } else if (shape is StadiumBorder) {
    details.addAll({'side': _getBorderSideDetails(shape.side)});
  } else if (shape is BeveledRectangleBorder) {
    details.addAll({
      'borderRadius': _getBorderRadiusDetails(shape.borderRadius),
      'side': _getBorderSideDetails(shape.side),
    });
  } else if (shape is ContinuousRectangleBorder) {
    details.addAll({
      'borderRadius': _getBorderRadiusDetails(shape.borderRadius),
      'side': _getBorderSideDetails(shape.side),
    });
  } else {
    // For any other shape types, include the string representation as fallback
    details['description'] = shape.toString();
  }

  return details;
}

Map<String, dynamic> _getBorderRadiusDetails(
  BorderRadiusGeometry? borderRadius,
) {
  if (borderRadius == null) return {};

  Map<String, dynamic> details = {'type': borderRadius.runtimeType.toString()};

  if (borderRadius is BorderRadius) {
    details.addAll({
      'topLeft': _getRadiusDetails(borderRadius.topLeft),
      'topRight': _getRadiusDetails(borderRadius.topRight),
      'bottomLeft': _getRadiusDetails(borderRadius.bottomLeft),
      'bottomRight': _getRadiusDetails(borderRadius.bottomRight),
    });
  } else if (borderRadius is BorderRadiusDirectional) {
    details.addAll({
      'topStart': _getRadiusDetails(borderRadius.topStart),
      'topEnd': _getRadiusDetails(borderRadius.topEnd),
      'bottomStart': _getRadiusDetails(borderRadius.bottomStart),
      'bottomEnd': _getRadiusDetails(borderRadius.bottomEnd),
    });
  }

  return details;
}

Map<String, dynamic> _getRadiusDetails(Radius radius) {
  return {'x': radius.x.toString(), 'y': radius.y.toString()};
}

Map<String, dynamic> _getBoxShadowDetails(List<BoxShadow>? boxShadows) {
  if (boxShadows == null || boxShadows.isEmpty) {
    return {};
  }

  return {
    'count': boxShadows.length,
    'shadows': boxShadows
        .map(
          (shadow) => {
            'color': colorToHex(shadow.color),
            'offset': 'dx: ${shadow.offset.dx}, dy: ${shadow.offset.dy}',
            'blurRadius': shadow.blurRadius.toString(),
            'spreadRadius': shadow.spreadRadius.toString(),
            'blurStyle': shadow.blurStyle.toString(),
          },
        )
        .toList(),
  };
}

Map<String, dynamic> _getGradientDetails(Gradient? gradient) {
  if (gradient == null) return {};

  Map<String, dynamic> details = {'type': gradient.runtimeType.toString()};

  if (gradient is LinearGradient) {
    details['begin'] = gradient.begin.toString();
    details['end'] = gradient.end.toString();
    details['colors'] = gradient.colors
        .map((color) => colorToHex(color))
        .toList();
    details['stops'] = gradient.stops?.toString() ?? 'null';
    details['tileMode'] = gradient.tileMode.toString();
  } else if (gradient is RadialGradient) {
    details['center'] = gradient.center.toString();
    details['radius'] = gradient.radius.toString();
    details['colors'] = gradient.colors
        .map((color) => colorToHex(color))
        .toList();
    details['stops'] = gradient.stops?.toString() ?? 'null';
    details['tileMode'] = gradient.tileMode.toString();
  } else if (gradient is SweepGradient) {
    details['center'] = gradient.center.toString();
    details['startAngle'] = gradient.startAngle.toString();
    details['endAngle'] = gradient.endAngle.toString();
    details['colors'] = gradient.colors
        .map((color) => colorToHex(color))
        .toList();
    details['stops'] = gradient.stops?.toString() ?? 'null';
    details['tileMode'] = gradient.tileMode.toString();
  }

  return details;
}

Map<String, dynamic> _getDecorationImageDetails(DecorationImage? image) {
  if (image == null) return {};

  return {
    'fit': image.fit?.toString() ?? 'null',
    'alignment': image.alignment.toString(),
    'repeat': image.repeat.toString(),
    'matchTextDirection': image.matchTextDirection.toString(),
    'scale': image.scale.toString(),
    'opacity': image.opacity.toString(),
    'filterQuality': image.filterQuality.toString(),
    'invertColors': image.invertColors.toString(),
    'isAntiAlias': image.isAntiAlias.toString(),
  };
}

Map<String, dynamic> _extractTextSpanDetails(
  InlineSpan inlineSpan,
  BuildContext context, [
  TextStyle? parentStyle,
]) {
  Map<String, dynamic> spanDetails = {};

  // Check if this is a TextSpan or other InlineSpan type
  if (inlineSpan is TextSpan) {
    final textSpan = inlineSpan;

    // Extract text content
    spanDetails['text'] = textSpan.text ?? 'null';
    spanDetails['type'] = 'TextSpan';

    // Handle style inheritance properly
    TextStyle? effectiveStyle;
    if (textSpan.style != null) {
      // TextSpan has explicit style
      if (parentStyle != null) {
        // Merge with parent style
        effectiveStyle = parentStyle.merge(textSpan.style);
      } else {
        // No parent style, use TextSpan style directly
        effectiveStyle = textSpan.style;
      }
    } else {
      // TextSpan has no explicit style, inherit from parent or default
      effectiveStyle = parentStyle;
    }

    // Extract style information using existing getTextStyle function
    spanDetails['style'] = getTextStyle(effectiveStyle, context);

    // Recursively extract children TextSpans with current effective style as parent
    if (textSpan.children != null && textSpan.children!.isNotEmpty) {
      spanDetails['hasChildren'] = 'true';
      spanDetails['childrenCount'] = textSpan.children!.length.toString();

      List<Map<String, dynamic>> childrenDetails = [];
      for (final child in textSpan.children!) {
        childrenDetails.add(
          _extractTextSpanDetails(child, context, effectiveStyle),
        );
      }
      spanDetails['children'] = childrenDetails;
    } else {
      spanDetails['hasChildren'] = 'false';
      spanDetails['childrenCount'] = '0';
      spanDetails['children'] = [];
    }
  } else {
    // Handle other InlineSpan types (like WidgetSpan)
    spanDetails['type'] = inlineSpan.runtimeType.toString();

    // Handle style inheritance for other InlineSpan types
    TextStyle? effectiveStyle;
    if (inlineSpan.style != null) {
      if (parentStyle != null) {
        effectiveStyle = parentStyle.merge(inlineSpan.style);
      } else {
        effectiveStyle = inlineSpan.style;
      }
    } else {
      effectiveStyle = parentStyle;
    }

    spanDetails['style'] = getTextStyle(effectiveStyle, context);
    spanDetails['hasChildren'] = 'false';
    spanDetails['childrenCount'] = '0';
    spanDetails['children'] = [];

    // Check if it's a WidgetSpan and extract text from child widgets
    if (inlineSpan is WidgetSpan) {
      final extractedText = _extractTextFromWidget(inlineSpan.child);
      spanDetails['text'] = extractedText;
    } else {
      spanDetails['text'] = 'null';
    }
  }

  return spanDetails;
}

String _extractTextFromWidget(Widget widget) {
  // Recursively search for Text widgets in the widget tree
  if (widget is Text) {
    return widget.data ?? 'null';
  } else if (widget is RichText) {
    return widget.text.toPlainText();
  } else if (widget is Container && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is Center && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is Padding && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is Align && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is GestureDetector && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is InkWell && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is Expanded) {
    return _extractTextFromWidget(widget.child);
  } else if (widget is Flexible) {
    return _extractTextFromWidget(widget.child);
  } else if (widget is SizedBox && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is DecoratedBox && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is Transform && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is Opacity && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is ClipRRect && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is ClipOval && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is Material && widget.child != null) {
    return _extractTextFromWidget(widget.child!);
  } else if (widget is Row) {
    // For Row, concatenate text from all children
    List<String> texts = [];
    for (Widget child in widget.children) {
      String childText = _extractTextFromWidget(child);
      if (childText != 'null') {
        texts.add(childText);
      }
    }
    return texts.isNotEmpty ? texts.join(' ') : 'null';
  } else if (widget is Column) {
    // For Column, concatenate text from all children
    List<String> texts = [];
    for (Widget child in widget.children) {
      String childText = _extractTextFromWidget(child);
      if (childText != 'null') {
        texts.add(childText);
      }
    }
    return texts.isNotEmpty ? texts.join(' ') : 'null';
  } else if (widget is Stack) {
    // For Stack, concatenate text from all children
    List<String> texts = [];
    for (Widget child in widget.children) {
      String childText = _extractTextFromWidget(child);
      if (childText != 'null') {
        texts.add(childText);
      }
    }
    return texts.isNotEmpty ? texts.join(' ') : 'null';
  } else if (widget is Wrap) {
    // For Wrap, concatenate text from all children
    List<String> texts = [];
    for (Widget child in widget.children) {
      String childText = _extractTextFromWidget(child);
      if (childText != 'null') {
        texts.add(childText);
      }
    }
    return texts.isNotEmpty ? texts.join(' ') : 'null';
  }

  // If no Text widget found, return 'null'
  return 'null';
}

String widgetStatePropertyToResolvedValues<T>(
  WidgetStateProperty<T>? stateProperty,
  String Function(T value) valueToString,
) {
  if (stateProperty == null) {
    return 'null';
  }
  // Add the default state (no specific state).
  final T? defaultValue = stateProperty.resolve({});
  if (defaultValue != null) {
    return valueToString(defaultValue);
  }
  return "null";
}

void _sendWidgetInformation(Map<String, dynamic> widgetInfo) {
  try {
    final payload = widgetInfo;

    final jsonData = jsonEncode(payload);
    final request = html.HttpRequest();
    request.open('POST', backendURL, async: true);
    request.setRequestHeader('Content-Type', 'application/json');

    request.onReadyStateChange.listen((_) {
      if (request.readyState == html.HttpRequest.DONE) {
        // if (request.status == 200) {
        //   print('Successfully reported widgetInfo');
        // } else {
        //   print('Error reporting widget information');
        // }
      }
    });

    // request.onError.listen((event) {
    //   print('Failed to send widget information');
    // });

    request.send(jsonData);
  } catch (e) {
    // print('Exception while reporting overflow error: $e');
  }
}
