import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
const simpleTaskKey = "sampleBackgroundTask";

/// デバイスの現在位置を決定する。
/// 位置情報サービスが有効でない場合、または許可されていない場合。
/// エラーを返します
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 位置情報サービスが有効かどうかをテストします。
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // 位置情報サービスが有効でない場合、続行できません。
    // 位置情報にアクセスし、ユーザーに対して 
    // 位置情報サービスを有効にするようアプリに要請する。
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // ユーザーに位置情報を許可してもらうよう促す
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 拒否された場合エラーを返す
      return Future.error('Location permissions are denied');
    }
  }
  
  // 永久に拒否されている場合のエラーを返す
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // ここまでたどり着くと、位置情報に対しての権限が許可されているということなので
  // デバイスの位置情報を返す。
  return await Geolocator.getCurrentPosition();
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print(taskName);
    print("----test----");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    switch (taskName) {
      case Workmanager.iOSBackgroundTask:
        stderr.writeln(position.toString());
        stderr.writeln("The iOS background fetch was triggered");
        break;
    }
    bool success = true;
    return Future.value(success);
  });
}


// Future<void> main() async {

//   await Workmanager().initialize(
//                 callbackDispatcher,
//                 isInDebugMode: true,
//               );
  
//   runApp(MyApp());
// }

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: MyWidget(),
        ),
      ),
    );
  }
}

// StatefulWidgetを継承するとStateを扱える
// このWidgetを表示すると、Stateを元にUIが作成される
class MyWidget extends StatefulWidget {
  // 使用するStateを指定
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

// Stateを継承して使う
class _MyWidgetState extends State<MyWidget> {
  // データを宣言
  int count = 0;

  @override
  void initState() {
    super.initState();
    // todo: ここに処理を書きます
    

  }

  // データを元にWidgetを作る
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () {
            // データを更新する時は setState を呼ぶ
            getLocation();
          },
          child: Text('現在地取得'),
        ),

        TextButton(
          onPressed: () {
            // データを更新する時は setState を呼ぶ
            initWorkManager();
          },
          child: Text('background'),
        ),
        
      ],
    );
  }

  void getLocation() async{
    Position p = await determinePosition();
    print(p);
  }

  void initWorkManager() async {
    await Workmanager().initialize(
                callbackDispatcher,
                isInDebugMode: true,
              );
  }

}