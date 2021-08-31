import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mastbau_inspector/backend/api.dart';
import 'package:mastbau_inspector/classes/data/checkcategory.dart';
import 'package:mastbau_inspector/classes/data/inspection_location.dart';
import 'package:mastbau_inspector/classes/listTileData.dart';
import 'package:mastbau_inspector/pages/checkpoints/checkpointsModel.dart';
import 'package:mastbau_inspector/pages/checkpoints/checkpointsView.dart';
import 'package:provider/provider.dart';
import 'package:mastbau_inspector/pages/dropdown/dropdownModel.dart';

class CategoryModel extends DropDownModel<CheckCategory> with ChangeNotifier {
  final Backend _b = Backend();
  final InspectionLocation currentLocation;

  static const _nextViewTitle = "Prüfpunkte";

  CategoryModel(this.currentLocation);

  Future<List<CheckCategory>> get all async =>
      _b.getAllCheckCategoriesForLocation(currentLocation);

  @override
  List<MyListTileData> actions = [
    MyListTileData(
      title: _nextViewTitle,
      nextBuilder: (c) => CheckPointsView(),
    ),
    MyListTileData(
      title: "Fotos",
      nextBuilder: (c) => Text('todo'), //TODO
    ),
    MyListTileData(
      title: "Kommentar",
      nextBuilder: (c) => Text('todo'), //TODO
    ),
  ];

  @override
  String get title => '$currentLocation';

  @override
  void open(
    BuildContext context,
    CheckCategory data,
    MyListTileData tiledata,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (newcontext) => tiledata.title == _nextViewTitle
            ? ChangeNotifierProvider<CheckPointsModel>(
                create: (c) => CheckPointsModel(data),
                child: tiledata.nextBuilder(newcontext),
              )
            : tiledata.nextBuilder(newcontext),
      ),
    );
  }
}
