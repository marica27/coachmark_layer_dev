import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach_layer.dart';

//This line with main() choose which version of CoachMark to run
//myApp() in main - Simon's version with Route
//CoachApp in coach_layer - my version with extra layer in stack

void main() => runApp(MyApp());
//void main() => runApp(CoachApp());



class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coach Mark Demo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey();
  final GlobalKey<CoachMarkState> _calendarMark = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text("Hello"),
        actions: <Widget>[
          CoachMark(
            key: _calendarMark,
            id: 'calendar_mark',
            text: 'Tap here to use the Calendar!',
            child: GestureDetector(
              onLongPress: () => _calendarMark.currentState.show(),
              child: IconButton(
                onPressed: () => _onCalendarTap(),
                icon: Icon(Icons.calendar_today),
              ),
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'reset',
                  child: Text('Reset'),
                ),
              ];
            },
            onSelected: (String value) {
              if (value == 'reset') {
                _calendarMark.currentState.reset();
                _scaffold.currentState.showSnackBar(SnackBar(
                  content:
                      Text('Hot-restart the app to see the coach-mark again.'),
                ));
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                  "http://www.mobileswall.com/wp-content/uploads/2015/03/640-Sunset-Beach-2-l.jpg"),
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  void _onCalendarTap() async {
    DateTime selected = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(2018, 1, 1),
      lastDate: new DateTime.now(),
    );
    _scaffold.currentState.showSnackBar(SnackBar(
      content: Text('selected $selected'),
    ));
  }
}

class CoachMark extends StatefulWidget {
  const CoachMark({
    Key key,
    @required this.id,
    @required this.text,
    @required this.child,
  }) : super(key: key);

  final String id;
  final String text;
  final Widget child;

  @override
  CoachMarkState createState() => CoachMarkState();
}

typedef CoachMarkRect = Rect Function();

class CoachMarkState extends State<CoachMark> {
  _CoachMarkRoute _route;

  String get _key => 'mark_${widget.id}';

  @override
  void initState() {
    super.initState();
    test().then((bool seen) {
      if (seen == false) {
        show();
      }
    });
  }

  @override
  void didUpdateWidget(CoachMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuild();
  }

  @override
  void reassemble() {
    super.reassemble();
    _rebuild();
  }

  @override
  void dispose() {
    dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _rebuild();
    return widget.child;
  }

  void show() {
    if (_route == null) {
      _route = _CoachMarkRoute(
        rect: () {
          final box = context.findRenderObject() as RenderBox;
          return box.localToGlobal(Offset.zero) & box.size;
        },
        text: widget.text,
        padding: EdgeInsets.all(4.0),
        onPop: () {
          _route = null;
          mark();
        },
      );
      Navigator.of(context).push(_route);
    }
  }

  void _rebuild() {
    if (_route != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _route.changedExternalState();
      });
    }
  }

  void dismiss() {
    if (_route != null) {
      _route.dispose();
      _route = null;
    }
  }

  Future<bool> test() async {
    return (await SharedPreferences.getInstance()).getBool(_key) ?? false;
  }

  void mark() async {
    (await SharedPreferences.getInstance()).setBool(_key, true);
  }

  void reset() async {
    (await SharedPreferences.getInstance()).remove(_key);
  }
}

class _CoachMarkRoute<T> extends PageRoute<T> {
  _CoachMarkRoute({
    @required this.rect,
    @required this.text,
    this.padding,
    this.onPop,
    this.shadow =
        const BoxShadow(color: const Color(0xB2212121), blurRadius: 8.0),
    this.maintainState = true,
    this.transitionDuration = const Duration(milliseconds: 2000),
    RouteSettings settings,
  }) : super(settings: settings);

  final CoachMarkRect rect;
  final String text;
  final EdgeInsets padding;
  final BoxShadow shadow;
  final VoidCallback onPop;

  @override
  final bool maintainState;

  @override
  final Duration transitionDuration;

  @override
  bool didPop(T result) {
    onPop();
    return super.didPop(result);
  }

  void _onPointer(PointerEvent p, BuildContext context) async {
    print('_onPointer ${p}');
    if (Navigator.of(context).canPop()) {
      print("can pop");
      Navigator.of(context).pop();
    } else {
      print("can NOT pop");
    }
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Rect position = rect();
    if (padding != null) {
      position = padding.inflateRect(position);
    }
    position = Rect.fromCircle(
        center: position.center, radius: position.width * 0.5);
    final clipper = _CoachMarkClipper(position);

    return CoachMarkLayer(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (d) => _onPointer(d, context),
        onPointerMove: (d) => _onPointer(d, context),
        onPointerUp: (d) => _onPointer(d, context),
        onPointerCancel: (d) => _onPointer(d, context),
        markPosition: position,
        child:  FadeTransition(
          opacity: animation,
          child: Stack(
            children: <Widget>[
              ClipPath(
                clipper: clipper,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              CustomPaint(
                child: SizedBox.expand(
                  child: Center(
                    child: Material(
                        type: MaterialType.transparency,
                        child: Text(text,
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ))),
                  ),
                ),
                painter: _CoachMarkPainter(
                  rect: position,
                  shadow: shadow,
                  clipper: clipper,
                ),
              ),
            ],
          ),
        ));
  }

  @override
  bool get opaque => false;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;
}

class _CoachMarkClipper extends CustomClipper<Path> {
  final Rect rect;

  _CoachMarkClipper(this.rect);

  @override
  Path getClip(Size size) {
    return Path.combine(ui.PathOperation.difference,
        Path()..addRect(Offset.zero & size), Path()..addOval(rect));
  }

  @override
  bool shouldReclip(_CoachMarkClipper old) => rect != old.rect;
}

class _CoachMarkPainter extends CustomPainter {
  _CoachMarkPainter({
    @required this.rect,
    @required this.shadow,
    this.clipper,
  });

  final Rect rect;
  final BoxShadow shadow;
  final _CoachMarkClipper clipper;

  void paint(Canvas canvas, Size size) {
    final circle = rect.inflate(shadow.spreadRadius);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(shadow.color, BlendMode.dstATop);
    canvas.drawCircle(circle.center, circle.longestSide * 0.5,
        shadow.toPaint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoachMarkPainter old) => old.rect != rect;

  @override
  bool shouldRebuildSemantics(_CoachMarkPainter oldDelegate) => false;
}
