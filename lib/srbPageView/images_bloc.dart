import 'package:flutter/cupertino.dart';
import "package:rxdart/rxdart.dart";

class ImagesBloc {
  // var _listController = BehaviorSubject<List<SrbImage>>.seeded([]);
  var _listController = BehaviorSubject<List<SrbImage>>();

  Stream<List<SrbImage>> get imageslist => _listController.stream;

  void loadImages(List<String> list) {
    _listController.sink.add(list.map((imageUrl){
      return SrbImage(url: imageUrl);
    }).toList());
  }

  void dispose() {
    _listController.close();
  }
}

class SrbImage{
  String url;
  String name;
  SrbImage({@required this.url}) {
    name = url.split('/').last.split('.')[0];
  }

  @override
  String toString() {
    return url + " " + name;
  }
}