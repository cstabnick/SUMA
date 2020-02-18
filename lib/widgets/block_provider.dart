import 'package:flutter/material.dart';

/*
  Good practice is use generic BLoC Provider

  This allows for implementation of

  See the below for further information
  https://steemit.com/utopian-io/@tensor/advanced-flutter-project---best-practices---generic-bloc-providers---part-three
 */

abstract class BlocBase {
  // Dispose method, to be overridden in implementations to close streams
  void dispose();
}

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  BlocProvider({
    Key key, // Identifier for widget
    @required this.child,
    @required this.bloc,
  }): super(key: key);

  final T bloc;
  final Widget child;

  @override
  _BlocProviderState
}

class _BlocProviderState<T> extends State<BlocProvider<BlocBase>>{
  @override
  void dispose(){
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return widget.child;
  }
}