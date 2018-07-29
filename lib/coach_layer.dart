//import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'draggable_scrollbar.dart';
import 'dart:async';

void main() => runApp(CoachApp());

class CoachApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.orangeAccent, accentColor: Colors.purple),
      title: 'Flutter Demo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey();
  final GlobalKey _calendarIcon = GlobalObjectKey("calendarIcon");
  final GlobalKey _scrollThumbKey = GlobalObjectKey("scrollThumb");
  final GlobalKey _image7Key = GlobalObjectKey("_image7Key");

  final ScrollController controller = ScrollController();

  bool _coachMarkLayerDone;
  GlobalKey _keyForMark;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _coachMarkLayerDone = false;
    _keyForMark = _calendarIcon;
    //trigger build() again so markContext is defined already
    Timer(Duration(seconds: 1), () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    RenderBox box = _keyForMark.currentContext?.findRenderObject() as RenderBox;

    if (!_coachMarkLayerDone &&
        _keyForMark.currentContext?.findRenderObject() != null) {

      RenderBox box =
          _keyForMark.currentContext?.findRenderObject() as RenderBox;

      Rect position = box.localToGlobal(Offset.zero) & box.size;

      if (_keyForMark == _scrollThumbKey) {
        position = Rect.fromCircle(
            center: position.center, radius: position.longestSide * 0.8);
      } else if (_keyForMark == _image7Key) {
        position = position.inflate(0.5);
      }

      return CoachMark(
          child: buildScaffold(),
          markRect: position,
          coachMarkShape: _keyForMark != _scrollThumbKey ? BoxShape.rectangle : BoxShape.circle ,
          text: Text("Tap here to use",
              style: const TextStyle(
                fontSize: 28.0,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              )),
          onGotIt: () => setState(() {
                _coachMarkLayerDone = true;
              }));
    } else {
      return buildScaffold();
    }
  }

  Widget buildScaffold() {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text("Hello"),
        actions: <Widget>[
          IconButton(
            key: _calendarIcon,
            onPressed: _onCalendarTap,
            icon: Icon(Icons.calendar_today),
          ),
          PopupMenuButton<String>(
            initialValue:
                _keyForMark == _calendarIcon ? 'calendar' : _keyForMark == _scrollThumbKey ? 'scrollthumb' : 'image7',
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'calendar',
                  child: Text('calendar'),
                ),
                PopupMenuItem<String>(
                  value: 'scrollthumb',
                  child: Text('scroll thumb'),
                ),
                PopupMenuItem<String>(
                  value: 'image7',
                  child: Text('image7'),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'reset',
                  child: Text('Reset'),
                ),
              ];
            },
            onSelected: (String value) {
              if (value == 'calendar') {
                _scaffold.currentState.showSnackBar(SnackBar(
                  content: Text('CoachMark is on calendar'),
                ));
                Timer(
                    Duration(seconds: 2),
                    () => setState(() {
                          _keyForMark = _calendarIcon;
                          _coachMarkLayerDone = false;
                        }));
              }
              if (value == 'scrollthumb') {
                _scaffold.currentState.showSnackBar(SnackBar(
                  content: Text('CoachMark is on scroll thumb'),
                ));
                Timer(
                    Duration(seconds: 2),
                    () => setState(() {
                          _keyForMark = _scrollThumbKey;
                          _coachMarkLayerDone = false;
                        }));
              }
              if (value == 'image7') {
                _scaffold.currentState.showSnackBar(SnackBar(
                  content: Text('CoachMark is on image 7'),
                ));
                Timer(
                    Duration(seconds: 2),
                        () => setState(() {
                      _keyForMark = _image7Key;
                      _coachMarkLayerDone = false;
                    }));
              }
              if (value == 'reset') {
                setState(() {
                  _coachMarkLayerDone = false;
                });
              }
            },
          ),
        ],
      ),
      body: _buildDraggableList(),
    );
  }

  Widget _buildDraggableList() {
    var numItems = 1000;
    return DraggableScrollbar.semicircle(
      scrollThumbKey: _scrollThumbKey,
      alwaysVisibleScrollThumb: true,
      labelTextBuilder: (offset) {
        final int currentItem = controller.hasClients
            ? (controller.offset /
                    controller.position.maxScrollExtent *
                    numItems)
                .floor()
            : 0;

        return Text("${offset.floor()}");
      },
      labelConstraints: BoxConstraints.tightFor(width: 80.0, height: 30.0),
      controller: controller,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        controller: controller,
        padding: EdgeInsets.zero,
        itemCount: numItems,
        itemBuilder: (context, index) {

          return InkWell(
            key: index == 7 ? _image7Key : null,
              onTap: () => _scaffold.currentState.showSnackBar(SnackBar(
                    content: Text('selected $index'),
                  )),
              child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(2.0),
                  child: Center(child: Text("$index")),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: DecorationImage(
                        image: NetworkImage(
                            "http://images.clipartpanda.com/clipart-sun-11971486551534036964ivak_Decorative_Sun.svg.med.png")),
                  )));
        },
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
  CoachMark(
      {key,
      this.child,
      this.markRect,
      this.onGotIt,
      this.text,
      this.coachMarkShape})
      : super(key: key);

  final Widget child;
  final Rect markRect;
  final VoidCallback onGotIt;
  final Text text;
  final BoxShape coachMarkShape;

  @override
  _CoachMarkState createState() => _CoachMarkState();
}

class _CoachMarkState extends State<CoachMark>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> backdropBlur;
  Animation<double> backdropOpacity;

  final BoxShadow shadow =
      const BoxShadow(color: const Color(0xB2212121), blurRadius: 8.0);

  bool _coachMarkDone;

  @override
  void initState() {
    print("initState");
    // TODO: implement initState
    super.initState();
    _coachMarkDone = false;

    _controller = new AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    backdropBlur = new Tween(begin: 0.0, end: 3.0).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: new Interval(
          0.0,
          1.0,
          curve: Curves.ease,
        ),
      ),
    );
    backdropOpacity = new Tween(begin: 0.0, end: 0.8).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: new Interval(
          0.0,
          1.0,
          curve: Curves.ease,
        ),
      ),
    );
    _controller.forward();
    print("forward ${_controller.value}");
  }

  @override
  void dispose() {
    print("dispose");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Rect position = widget.markRect;
    final clipper = _CoachMarkClipper(position);

    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget child) {
          return Stack(
            children: <Widget>[
              widget.child,
              ClipPath(
                clipper: clipper,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                      sigmaX: backdropBlur.value, sigmaY: backdropBlur.value),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              CoachMarkLayer(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onPointer,
                onPointerMove: _onPointer,
                onPointerUp: _onPointer,
                onPointerCancel: _onPointer,
                markPosition: position,
                child: CustomPaint(
                  child: SizedBox.expand(
                      child: Material(
                    type: MaterialType.transparency,
                    child: Center(
                      child: widget.text,
                    ),
                  )),
                  painter: _CoachMarkPainter(
                    rect: position,
                    shadow: BoxShadow(
                        color: Color(0xB2212121)
                            .withOpacity(backdropOpacity.value),
                        blurRadius: 8.0), //0xB2212121
                    clipper: clipper,
                    coachMarkShape: widget.coachMarkShape,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _onPointer(PointerEvent p) {
    if (!_coachMarkDone) {
      print("_onPointer");
      _controller.addStatusListener((AnimationStatus status) {
        print("$status");
        if (status == AnimationStatus.dismissed) {
          widget.onGotIt();
        }
      });
      _controller.reverse();
      setState(() => _coachMarkDone = true);
    }
  }
}

class CoachMarksPainter extends CustomPainter {
  CoachMarksPainter(this.position, this.animation);

  final Rect position;
  final Animation<double> animation;

  void paint(Canvas canvas, Size size) {
    print("paint size=$size position=$position");
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(
        Colors.grey[900].withOpacity(animation.value), BlendMode.dstATop);
    canvas.drawCircle(
        position.center,
        position.longestSide / 2.0 * 1.5,
        Paint()
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.0)
          ..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CoachMarksPainter old) => old.position != position;

  @override
  bool shouldRebuildSemantics(CoachMarksPainter oldDelegate) => false;
}

class CoachMarkLayer extends Listener {
  const CoachMarkLayer(
      {Key key,
      onPointerDown,
      onPointerMove,
      onPointerUp,
      onPointerCancel,
      behavior,
      this.markPosition,
      Widget child})
      : super(
            key: key,
            onPointerDown: onPointerDown,
            onPointerMove: onPointerMove,
            onPointerUp: onPointerUp,
            onPointerCancel: onPointerCancel,
            child: child);

  final Rect markPosition;

  @override
  RenderPointerListener createRenderObject(BuildContext context) {
    return new RenderPointerListenerWithExceptRegion(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      onPointerCancel: onPointerCancel,
      behavior: behavior,
      exceptRegion: markPosition,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderPointerListener renderObject) {
    renderObject
      ..onPointerDown = onPointerDown
      ..onPointerMove = onPointerMove
      ..onPointerUp = onPointerUp
      ..onPointerCancel = onPointerCancel
      ..behavior = behavior;
  }
}

class RenderPointerListenerWithExceptRegion extends RenderPointerListener {
  RenderPointerListenerWithExceptRegion(
      {onPointerDown,
      onPointerMove,
      onPointerUp,
      onPointerCancel,
      HitTestBehavior behavior,
      this.exceptRegion,
      RenderBox child})
      : super(
            onPointerDown: onPointerDown,
            onPointerMove: onPointerMove,
            onPointerUp: onPointerUp,
            onPointerCancel: onPointerCancel,
            behavior: behavior,
            child: child);

  final Rect exceptRegion;

  @override
  bool hitTest(HitTestResult result, {Offset position}) {
    print(
        "hitTest ${exceptRegion} ${position} ? ${exceptRegion.contains(position)}");
    bool hitTarget = false;
    if (exceptRegion.contains(position)) {
      result.add(new BoxHitTestEntry(this, position));
      return false;
    }
    if (size.contains(position)) {
      hitTarget =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if (hitTarget || behavior == HitTestBehavior.translucent)
        result.add(new BoxHitTestEntry(this, position));
    }
    print("hitTest $hitTarget path:${result.path.length} :=> ${result.path}");
    return hitTarget;
  }

//  //nevertheless on hitTest==false Flutter call handleEvent
//  @override
//  void handleEvent(PointerEvent event, HitTestEntry entry) {
//    print("handleEvent $event");
//    super.handleEvent(event, entry);
//  }
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
    this.coachMarkShape = BoxShape.circle,
  });

  final Rect rect;
  final BoxShadow shadow;
  final _CoachMarkClipper clipper;
  final BoxShape coachMarkShape;

  void paint(Canvas canvas, Size size) {
    final circle = rect.inflate(shadow.spreadRadius);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(shadow.color, BlendMode.dstATop);
    var paint = shadow.toPaint()..blendMode = BlendMode.clear;

    switch (coachMarkShape) {
      case BoxShape.rectangle:
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(circle.width * 0.3)),
            paint);
        break;
      case BoxShape.circle:
      default:
        canvas.drawCircle(circle.center, circle.longestSide * 0.5, paint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoachMarkPainter old) => old.rect != rect;

  @override
  bool shouldRebuildSemantics(_CoachMarkPainter oldDelegate) => false;
}
