import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'dart:async';
import 'custom_inspector.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';

var backendURL = "https://edumanage3033back.builtwithrocket.new/log-error";

void main() async {
  FlutterError.onError = (details) {
    _sendOverflowError(details);
  };
  WidgetsFlutterBinding.ensureInitialized();

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(errorDetails: details);
  };
  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
        navigatorObservers: [trackingRouteObserver1],

          title: 'edumanage_pro',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
        
        final originalChild = MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
        return CustomWidgetInspector(
          child: TrackingWidget(
            child: originalChild,
          ),
        );
      },
          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
        
);
      },
    );
  }
}
final ValueNotifier<String> currentPageNotifier = ValueNotifier<String>('');

class MyRouteObserver1 extends RouteObserver<PageRoute<dynamic>> {
  void _updateCurrentPage(Route<dynamic>? route) {
    if (route is PageRoute) {
      currentPageNotifier.value = route.settings.name ?? '';
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _updateCurrentPage(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _updateCurrentPage(previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateCurrentPage(newRoute);
  }
}
final MyRouteObserver1 trackingRouteObserver1 = MyRouteObserver1();


void _sendOverflowError(FlutterErrorDetails details) {
  try {
    bool hasValidHost= html.window.location.host.isNotEmpty &&
        (html.window.location.host.contains('.netlify.app') ||
            html.window.location.host.contains('.public.builtwithrocket.new'));
        if (hasValidHost) {
          return;
        }final errorMessage = details.exception.toString();
    final exceptionType = details.exception.runtimeType.toString();
    String location = 'Unknown';
    final locationMatch = RegExp(r'file:///.*\.dart').firstMatch(details.toString());
    if (locationMatch != null) {
      location = locationMatch.group(0)?.replaceAll("file://", '') ?? 'Unknown';
    }
    String errorType = "RUNTIME_ERROR";
    if(errorMessage.contains('overflowed by') || errorMessage.contains('RenderFlex overflowed')) {
      errorType = 'OVERFLOW_ERROR';
    }
    final payload = {
      'errorType': errorType,
      'exceptionType': exceptionType,
      'message': errorMessage,
      'location': location,
      'timestamp': DateTime.now().toIso8601String(),
    };
    final jsonData = jsonEncode(payload);
    final request = html.HttpRequest();
    request.open('POST', backendURL, async: true);
    request.setRequestHeader('Content-Type', 'application/json');
    request.send(jsonData);
  } catch (e) {
    // print('Exception while reporting overflow error: $e');
  }
}

class TrackingWidget extends StatefulWidget {
  final Widget child;

  const TrackingWidget({super.key, required this.child});

  @override
  State<TrackingWidget> createState() => _TrackingWidgetState();
}

class _TrackingWidgetState extends State<TrackingWidget> {
  Timer? _debounce;
  RenderObject? _selectedRenderObject;
  Element? _selectedElement;
  final GlobalKey _childKey = GlobalKey();
  Timer? _scrollDebounce;
  String currentPage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentPage = currentPageNotifier.value;
      currentPageNotifier.addListener(_updateCurrentPage);
    });
  }

  void _updateCurrentPage() {
    setState(() {
      currentPage = currentPageNotifier.value;
    });
  }

    String findNearestKnownWidget(Element? element) {
    if (element == null) return 'unknown';

    String? foundWidget;

    // Helper function to identify widget type
     String? identifyWidget(Widget widget) {
      return _widgetTypeMap[widget.runtimeType] ??
          _getCustomWidgetType(widget) ??
          null;
    }

    // Check current element
    foundWidget = identifyWidget(element.widget);
    if (foundWidget != null) return foundWidget;

    // Traverse ancestors
    element.visitAncestorElements((ancestor) {
      foundWidget = identifyWidget(ancestor.widget);
      return foundWidget == null; // continue if not found
    });

    if (foundWidget != null) return foundWidget!;

    // Traverse descendants
    void visitDescendants(Element child) {
      if (foundWidget != null) return;
      foundWidget = identifyWidget(child.widget);
      if (foundWidget == null) {
        child.visitChildren(visitDescendants);
      }
    }

    element.visitChildren(visitDescendants);

    return foundWidget ?? 'unknown';
  }

    // Static Map for widget type lookup
  static const Map<Type, String> _widgetTypeMap = {
    // Basic widgets
    Text: 'Text',
    Icon: 'Icon',

    // Buttons
    ElevatedButton: 'ElevatedButton',
    TextButton: 'TextButton',
    OutlinedButton: 'OutlinedButton',
    FloatingActionButton: 'FloatingActionButton',
    IconButton: 'IconButton',

    // Form controls
    Checkbox: 'Checkbox',
    Radio: 'Radio',
    Switch: 'Switch',
    SwitchListTile: 'SwitchListTile',
    RadioListTile: 'RadioListTile',
    ToggleButtons: 'ToggleButtons',
    Slider: 'Slider',
    RangeSlider: 'RangeSlider',
    TextField: 'TextField',
    TextFormField: 'TextFormField',
    DropdownButton: 'DropdownButton',
    PopupMenuButton: 'PopupMenuButton',
    Form: 'Form',

    // Media widgets
    Image: 'Image',
    Placeholder: 'Placeholder',
    FileImage: 'FileImage',
    NetworkImage: 'NetworkImage',
    AssetImage: 'AssetImage',

    // Layout widgets
    Container: 'Container',
    Row: 'Row',
    Column: 'Column',
    Stack: 'Stack',
    Wrap: 'Wrap',
    SizedBox: 'SizedBox',
    Padding: 'Padding',

    // Lists and grids
    ListView: 'ListView',
    GridView: 'GridView',
    ListTile: 'ListTile',
    SingleChildScrollView: 'SingleChildScrollView',

    // Navigation
    AppBar: 'AppBar',
    BottomNavigationBar: 'BottomNavigationBar',
    Drawer: 'Drawer',
    SliverAppBar: 'SliverAppBar',

    // Material components
    Card: 'Card',
    Chip: 'Chip',
    ActionChip: 'ActionChip',
    InputChip: 'InputChip',
    ChoiceChip: 'ChoiceChip',
    SnackBar: 'SnackBar',
    Banner: 'Banner',
    Tooltip: 'Tooltip',

    // Progress indicators
    ProgressIndicator: 'ProgressIndicator',
    CircularProgressIndicator: 'CircularProgressIndicator',
    LinearProgressIndicator: 'LinearProgressIndicator',

    // Sliver widgets
    SliverList: 'SliverList',
    SliverGrid: 'SliverGrid',
    SliverToBoxAdapter: 'SliverToBoxAdapter',
    SliverFillRemaining: 'SliverFillRemaining',
    SliverPadding: 'SliverPadding',
    SliverFixedExtentList: 'SliverFixedExtentList',
    SliverFillViewport: 'SliverFillViewport',
    SliverPersistentHeader: 'SliverPersistentHeader',
  };

  // Handle custom widget types that might not be in the map
  String? _getCustomWidgetType(Widget widget) {
    // Add any custom widget type checks here
    // This is a fallback for widgets not in the static map
    return null;
  }

  void trackInteraction(String eventType, PointerEvent? event) {
    try {
    //remove focus from the flutter app when mouseleave
    //added this to fix the issue of the focus not being removed when the mouse leaves the flutter app
    if (eventType == 'mouseleave') {
        Future.delayed(Duration(milliseconds: 300), () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.unfocus();
          }
        });
      }
      RenderBox? renderBox;
      if (_selectedRenderObject is RenderBox) {
        renderBox = _selectedRenderObject as RenderBox;
      } else {
        renderBox = null;
      }

      final offset = renderBox?.localToGlobal(Offset.zero);
      final size = renderBox?.size;

      final mousePosition = event?.position;

      final scrollPosition = _getScrollPosition(_selectedRenderObject);

      final interactionData = {
        'eventType': eventType,
        'timestamp': DateTime.now().toIso8601String(),
        'element': {
          'tag': findNearestKnownWidget(_selectedElement),
          'id': _selectedElement?.widget.key?.toString() ??
              widget.child.key?.toString(),
          'position': offset != null
              ? {
            'x': offset.dx.round(),
            'y': offset.dy.round(),
            'width': size?.width.round(),
            'height': size?.height.round(),
          }
              : null,
          'viewport': {
            'width': MediaQuery.of(context).size.width.round(),
            'height': MediaQuery.of(context).size.height.round(),
          },
          'scroll': {
            'x': scrollPosition.dx.round(),
            'y': scrollPosition.dy.round(),
          },
          'mouse': mousePosition != null
              ? {
            'viewport': {
              'x': mousePosition.dx.round(),
              'y': mousePosition.dy.round(),
            },
            'page': {
              'x': (mousePosition.dx + scrollPosition.dx).round(),
              'y': (mousePosition.dy + scrollPosition.dy).round(),
            },
            'element': offset != null
                ? {
              'x': (mousePosition.dx - offset.dx).round(),
              'y': (mousePosition.dy - offset.dy).round(),
            }
                : null,
          }
              : null,
        },
        'page': '/#$currentPage',
      };

      web.window.parentCrossOrigin?.postMessage(
          {
            'type': 'USER_INTERACTION',
            'payload': interactionData,
          }.jsify(),
          '*'.toJS);

      // print('Interaction Data: $interactionData');
    } catch (error) {
      // print('Error tracking interaction flutter: $error');
    }
  }

  Offset _getScrollPosition(RenderObject? renderObject) {
    if (renderObject == null) return Offset.zero;

    final element = _findElementForRenderObject(renderObject);
    if (element == null) return Offset.zero;

    final scrollableState = Scrollable.maybeOf(element);
    if (scrollableState != null) {
      final position = scrollableState.position;
      return Offset(position.pixels, position.pixels);
    }

    // Default to zero if not scrollable
    return Offset.zero;
  }

  void _debouncedMouseMove(PointerHoverEvent event) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 10), () {
      _onHover(event);
      trackInteraction('mousemove', event);
    });
  }

  void _onScroll(PointerSignalEvent event) {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 200), () {
      trackInteraction('scrollend', event);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    currentPageNotifier.removeListener(_updateCurrentPage);
    super.dispose();
  }

  void _onHover(PointerHoverEvent event) {
    final RenderObject? userRender =
    _childKey.currentContext?.findRenderObject();
    if (userRender == null) return;

    final RenderObject? target =
    _findRenderObjectAtPosition(event.position, userRender);

    if (target != null && target != userRender) {
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

  RenderObject? _findRenderObjectAtPosition(
      Offset position, RenderObject root) {
    final List<RenderObject> hits = <RenderObject>[];
    _hitTestHelper(hits, position, root, root.getTransformTo(null));
    if (hits.isEmpty) return null;
    hits.sort((a, b) {
      final sizeA = a.semanticBounds.size;
      final sizeB = b.semanticBounds.size;
      return (sizeA.width * sizeA.height).compareTo(sizeB.width * sizeB.height);
    });
    return hits.first;
  }

  bool _hitTestHelper(List<RenderObject> hits, Offset position,
      RenderObject object, Matrix4 transform) {
    bool hit = false;
    final Matrix4? inverse = Matrix4.tryInvert(transform);
    if (inverse == null) return false;
    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);
    final List<DiagnosticsNode> children = object.debugDescribeChildren();
    for (int i = children.length - 1; i >= 0; i--) {
      final DiagnosticsNode diagnostics = children[i];
      if (diagnostics.style == DiagnosticsTreeStyle.offstage ||
          diagnostics.value is! RenderObject) continue;
      final RenderObject child = diagnostics.value! as RenderObject;
      final Rect? paintClip = object.describeApproximatePaintClip(child);
      if (paintClip != null && !paintClip.contains(localPosition)) continue;
      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      if (_hitTestHelper(hits, position, child, childTransform)) hit = true;
    }
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

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: _debouncedMouseMove,
      onPointerDown: (event) => trackInteraction('click', event),
      onPointerSignal: (event) => _onScroll(event),
      onPointerMove: (event) => trackInteraction('touchmove', event),
      onPointerUp: (event) => trackInteraction('touchend', event),
      child: MouseRegion(
        onEnter: (event) => trackInteraction('mouseenter', event),
        onExit: (event) => trackInteraction('mouseleave', event),
        child: GestureDetector(
          onDoubleTap: () => trackInteraction('dblclick', null),
          onTap: () => trackInteraction('click', null),
          onPanStart: (_) => trackInteraction('touchstart', null),
          onPanUpdate: (_) => trackInteraction('touchmove', null),
          onPanEnd: (_) => trackInteraction('touchend', null),
          child: FocusScope(
            onKeyEvent: (_, event) {
              if(event is KeyDownEvent){
                trackInteraction('keydown', null);
              }
              return KeyEventResult.ignored;
            },
            key: _childKey,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

