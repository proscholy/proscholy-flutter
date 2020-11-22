import 'package:flutter/material.dart';
import 'package:zpevnik/constants.dart';

class PopupMenu extends StatefulWidget {
  final List<Widget> children;
  final ValueNotifier<bool> showing;
  final Border border;
  final bool animateHide;

  const PopupMenu({Key key, this.children, this.showing, this.border, this.animateHide = true}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenu> with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: kDefaultAnimationTime), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)..addListener(() => setState(() {}));

    widget.showing.addListener(_update);
  }

  @override
  Widget build(BuildContext context) => _collapseable(
      context,
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: widget.border,
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.children,
          ),
        ),
      ),
      _animation);

  Widget _collapseable(BuildContext context, Widget child, Animation<double> animation) => SizeTransition(
        sizeFactor: animation,
        axis: Axis.vertical,
        child: child,
      );

  void _update() =>
      widget.showing.value ? _controller.forward() : (widget.animateHide ? _controller.reverse() : _controller.reset());

  @override
  void dispose() {
    widget.showing.removeListener(_update);
    _controller.dispose();

    super.dispose();
  }
}
