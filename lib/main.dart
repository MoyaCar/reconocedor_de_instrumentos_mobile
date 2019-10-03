import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';

String textoVacio = '';
String textoSeleccion = 'Carga una foto con un Instrumento';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaInicial(),
    );
  }
}

class PantallaInicial extends StatefulWidget {
  PantallaInicial({Key key}) : super(key: key);

  _PantallaInicialState createState() => _PantallaInicialState();
}

class _PantallaInicialState extends State<PantallaInicial> {
  File img;

  upload(File imageFile) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    String base = 'https://instrumentalizador.onrender.com/';
    var uri = Uri.parse(base + 'analyze');
    var request = http.MultipartRequest('POST', uri);
    var multiPartFile = http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    request.files.add(multiPartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);

      var respuestaParseada = json.decode(value);
      textoVacio = respuestaParseada['result'];
      setState(() {});
    });
  }

  imagePicker(String source) async {
    textoSeleccion = '';
    setState(() {});
    print('imagePicker activado');
    img = await ImagePicker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery);

    textoVacio = 'Analizando...';
    print(img.toString());
    upload(img);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.amber,
        child: Center(
          child: Stack(
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: (img == null)
                      ? Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text(
                            textoSeleccion,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 32,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Image.file(img,
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: MediaQuery.of(context).size.width * 0.8),
                ),
              ),
              Text(
                textoVacio,
                style: TextStyle(color: Colors.white, fontSize: 80),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Seleccionar Foto'),
                      textColor: Colors.white70,
                      color: Colors.amberAccent,
                      onPressed: () {
                        imagePicker('gallery');
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    /*  return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('Instrumentalizador'),
      ),
      body: new Container(
        child: Center(
          child: Column(
            children: <Widget>[
              img == null
                  ? new Text(
                      textoSeleccion,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                      ),
                    )
                  : new Image.file(img,
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: MediaQuery.of(context).size.width * 0.8),
              new Text(
                textoVacio,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new Stack(
        children: <Widget>[
          Align(
              alignment: Alignment(1.0, 1.0),
              child: new FloatingActionButton(
                onPressed: () {
                  imagePicker('camera');
                },
                child: new Icon(Icons.camera_alt),
              )),
          Align(
            alignment: Alignment(1.0, 0.8),
            child: new FloatingActionButton(
              onPressed: () {
                imagePicker('gallery');
              },
              child: new Icon(Icons.image),
            ),
          ),
        ],
      ),
    ); */
  }
}
