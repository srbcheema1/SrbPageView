import 'package:flutter/material.dart';
import 'images_bloc.dart';
import 'dart:convert';
import 'dart:math';

class SrbPageView extends StatefulWidget {
  final double viewportFraction = 0.75;
  @override
  _SrbPageViewState createState() => _SrbPageViewState();
}

class _SrbPageViewState extends State<SrbPageView> {
  PageController pageController;
  double pageOffset = 0;
  ImagesBloc imagesBloc = ImagesBloc();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0, viewportFraction: widget.viewportFraction)
                      ..addListener(() {
                        setState(() { pageOffset = pageController.page; });
                      });
    
    imagesAPI(context).then((list){
      imagesBloc.loadImages(list);
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SrbImage>>(
      stream: imagesBloc.imageslist,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data);
          return _pageBuilder(snapshot.data);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(child: CircularProgressIndicator());
      }
    );
  }

  Widget _pageBuilder(List<SrbImage> snapshot) {
    return PageView.builder(
      controller: pageController,
      itemBuilder: (context, index) {
        double angle = (pageOffset - index).abs();
        double scale = angle;
        

        if (angle > 0.5) {
          angle = 1 - angle;
        }
        return Container(
          padding: EdgeInsets.fromLTRB(10,50+scale*50,10,50),
          child: Transform(
            transform: Matrix4.identity()..setEntry(3,2, 0.002,)..rotateY(angle),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent)
              ),
              child: Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          snapshot[index].url,
                        ),
                        fit: BoxFit.cover,
                      ) 
                    ),  
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    child: AnimatedOpacity(
                      opacity: max(0,min(1,1-scale)),
                      duration: const Duration( milliseconds: 200),
                      child: Text(
                        snapshot[index].name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ),
          ),
        );
      },
      itemCount: snapshot.length,
    );
  }
}

Future<List<String>> imagesAPI(BuildContext context) async {
  return Future.delayed(Duration(seconds: 1),() async { // make time taking call
    final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final imagePaths = manifestMap.keys.where((String key) => key.contains('srbImages/')).toList();
    return imagePaths;
  });
}