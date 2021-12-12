import 'package:MBG_Inspektionen/widgets/mySimpleAlertBox.dart';
import 'package:flutter/material.dart';
import 'package:MBG_Inspektionen/pages/dropdown/dropdownModel.dart';

//should be held up to date with FloatingActionButton
const BoxConstraints _kSizeConstraints = BoxConstraints.tightFor(
  width: 56.0,
  height: 56.0,
);

class TransformeableActionbutton extends StatefulWidget {
  final Widget collapsedChild;
  final Widget Function(Function()) expandedChild;
  final double expandedHeight;

  final EdgeInsets padding;

  const TransformeableActionbutton({
    Key? key,
    this.collapsedChild = const Icon(Icons.add),
    required this.expandedChild,
    this.padding = const EdgeInsets.all(15),
    this.expandedHeight = 400,
  }) : super(key: key);

  @override
  TransformeableActionbuttonState createState() =>
      TransformeableActionbuttonState();
}

class TransformeableActionbuttonState
    extends State<TransformeableActionbutton> {
  bool isClicked = false;
  bool wasClicked = false;

  final transition_ms = 400;

  void popupGroup() {
    setState(() {
      isClicked = true;
    });
    Future.delayed(Duration(milliseconds: transition_ms), () {
      setState(() {
        wasClicked = true;
      });
    });
  }

  void cancel() {
    setState(() {
      wasClicked = false;
      isClicked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    FloatingActionButtonThemeData ftheme =
        Theme.of(context).floatingActionButtonTheme;
    double radius =
        (ftheme.sizeConstraints?.maxWidth ?? _kSizeConstraints.maxWidth) / 2;
    return GestureDetector(
      onTap: popupGroup,
      child: AnimatedContainer(
        key: UniqueKey(),
        //padding: isClicked ? widget.padding : EdgeInsets.all(0), //not needed, since the floatingAction Button from scaffold is already padded
        decoration: BoxDecoration(
          boxShadow: isClicked
              ? [
                  BoxShadow(
                      color: theme.colorScheme.secondary.withAlpha(30),
                      blurRadius: radius * .4,
                      spreadRadius: 0)
                ]
              : [],
          color: isClicked
              ? theme.cardColor
              : ftheme.backgroundColor ?? theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(radius),
        ),
        curve: Curves.easeInOutCubic,
        duration: Duration(milliseconds: transition_ms),
        height: isClicked
            ? widget.expandedHeight
            : ftheme.sizeConstraints?.maxHeight ?? _kSizeConstraints.maxHeight,
        width: isClicked
            ? MediaQuery.of(context).size.width -
                widget.padding.left -
                widget.padding.right
            : ftheme.sizeConstraints?.maxWidth ?? _kSizeConstraints.maxWidth,
        child:
            isClicked /*wasClicked*/ //Yes this makes  layout err, but it looks better in prod, could use wasClicked and for better transition the isClicked below
                ? Container(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: widget.expandedChild(cancel),
                    ),
                  )
                : /*isClicked
                ? Container()
                : */
                Container(
                    child: FloatingActionButton(
                      child: widget.collapsedChild,
                      onPressed: popupGroup,
                    ),
                  ),
      ),
    );
  }
}

/*class Cancelable {
  final Function(Function) builder;
  const Cancelable({
    Key? key,
    required this.builder,
  });

  Widget withcancel(Function onCancel) => builder(onCancel);
}*/

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

mixin JsonExtractable on Widget {
  String get name => "";
  dynamic get json;
}

/*class JsonExtractableBuilder extends JsonExtractable {
  final String name;
  final Map<String, dynamic> json;
  JsonExtractableBuilder
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}*/

class Adder extends StatelessWidget implements JsonExtractable {
  final String name;
  final Function(Map<String, dynamic>)? onSet;
  final Function()? onCancel;

  final List<JsonExtractable> children;

  /// the data for each [TextField],
  /// ensure that all [InputData.varName]s are unique
  final List<InputData> textfield_list;
  final List<TextEditingController> _textfield_controller_list;
  final List<FocusNode> _textfield_focusnode_list;

  final Map<String, Map<String, dynamic>> json;

  Adder(
    this.name, {
    this.onSet,
    this.onCancel,
    this.textfield_list = const [],
    this.children = const [],
  })  : assert(textfield_list ==
            textfield_list
                .unique((x) => x.varName)), //all varnames need to be unique
        this._textfield_controller_list =
            textfield_list.map((tf) => TextEditingController()).toList(),
        this._textfield_focusnode_list =
            textfield_list.map((tf) => FocusNode()).toList(),
        this.json = {name: {}};

  Future<void> _alert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return MySimpleAlertBox(
          actions: <Widget>[
            DismissTextButton(),
          ],
          bodyLines: ['probier\'s nochmal'],
          title: 'Irgendwas stimmt hier noch nicht',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void set() {
      if (textfield_list.every((element) => element.verify(
          //okay the indexOf workaround is pretty bad (O(n^2)), make the every iteretion indexed and it'll be O(n). (but the list shall be rather short so np)
          _textfield_controller_list[textfield_list.indexOf(element)].text))) {
        for (var i = 0; i < textfield_list.length; i++) {
          json[name]![textfield_list[i].varName] =
              _textfield_controller_list[i].text;
        }
        children.forEach((child) {
          json[name]![child.name] = child.json;
        });
        onSet?.call(json);
      } else {
        _alert(context);
      }
    }

    return Column(
      children: <Widget>[
        Spacer(),
        ...children,
        ...List.generate(
          textfield_list.length,
          (i) => _Input(
              isBetterthantherest: i == 0,
              hint: textfield_list[i].hint,
              onDone: (name) {
                try {
                  //TextInputAction.next;
                  FocusScope.of(context)
                      .requestFocus(_textfield_focusnode_list[i + 1]);
                } catch (e) {
                  FocusScope.of(context)
                      .requestFocus(_textfield_focusnode_list[0]);
                }
              },
              fn: _textfield_focusnode_list[i],
              c: _textfield_controller_list[i]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _PaddedButton(
              icon: Icons.cancel,
              onPressed: onCancel,
            ),
            //if (textfield_list.isNotEmpty) _mainField(set),
            _PaddedButton(
              icon: Icons.check_circle,
              onPressed: set,
            ),
          ],
        ),
      ],
    );
  }
}

class _PaddedButton extends StatelessWidget {
  const _PaddedButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(5.0),
        child: IconButton(
          //TODO: press-feedback (animation)
          //backgroundColor: Theme.of(context).canvasColor,
          onPressed: () {
            onPressed?.call();
          },
          icon: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
}

class _Input extends StatelessWidget {
  const _Input({
    Key? key,
    required this.isBetterthantherest,
    required this.hint,
    required this.onDone,
    required this.fn,
    required this.c,
  }) : super(key: key);

  final bool isBetterthantherest;
  final String hint;
  final Function(String p1) onDone;
  final FocusNode fn;
  final TextEditingController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: TextField(
        autofocus:
            isBetterthantherest, //TODO: remove when closed oder so, jedenfalls snackt der sich den fokus
        focusNode: fn,
        //textInputAction: TextInputAction.next, //XXX: sadly this wont work for some reason
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color:
                      Theme.of(context).colorScheme.onBackground.withAlpha(50),
                  width: 1)),
          hintText: hint,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w100,
            fontSize: 17,
          ),
        ),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
        onSubmitted: onDone,
        controller: c,
      ),
    );
  }
}

class InputData {
  /// under which name to store the result
  final String varName;

  /// the hint the user gets to see
  final String hint;

  /// a function on whether the current [text] is valid (correct set of characters etc)
  final bool Function(String text) verify;
  InputData(this.varName, {required this.hint, this.verify = _defaultver});
  static bool _defaultver(String str) => str.isNotEmpty;
}
