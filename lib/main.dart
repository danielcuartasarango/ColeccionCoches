import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Auto>> fetchAutos(http.Client client) async {
  final response =  await client.get('https://automoviles-api.herokuapp.com/all');


  return compute(parseAutos, response.body);
}


List<Auto> parseAutos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Auto>((json) => Auto.fromJson(json)).toList();
}

class Auto {
  final int id;
  final String nombre;
  final int modelo;
  final String marca;
  final String paisorigen;
  final String descripcion;
  final String linkImage;

  Auto({this.id,this.nombre,this.modelo,  this.marca, this.paisorigen,this.descripcion, this.linkImage});

  factory Auto.fromJson(Map<String, dynamic> json) {
    return Auto(
      id: json['id'] as int,
      nombre: json['nombre'],
      modelo: json['modelo'] as int,
      marca: json['marca'],
      paisorigen: json['paisorigen'],
      descripcion: json['descripcion'],
      linkImage: json['linkImage'],

    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Revista Autos';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Auto>>(
        future: fetchAutos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? AutosList(autos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class AutosList extends StatelessWidget {
  final List<Auto> autos;

  AutosList({Key key, this.autos}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Clasicos")
      ),
      body: new ListView.builder(
          itemCount: autos==null ? 0 : autos.length,
          itemBuilder: (BuildContext context, int index) {
           return new InkWell(
              onTap: (){
                Scaffold.of(context).showSnackBar(SnackBar(content: Text(autos[index].descripcion)));
              },

              child: new Center(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    new Card(
                      color: Colors.grey,

                      child: Column(
                        children: <Widget>[
                        Container(
                        height: 150.0,
                        width: 400.0,
                          color: Colors.black,
                          child: Image.network(autos[index].linkImage, height: 200.0, width: 170.0)

                        ),
                          Row(children: <Widget>[
                            padding(Text(autos[index].nombre, style: TextStyle(fontSize: 23.0))),
                            padding(Text(autos[index].modelo.toString(), style: TextStyle(fontSize: 20.0)))
                          ]),

                        Row(children: <Widget>[
                          padding(Text("Fabricante: "+autos[index].marca, style: TextStyle(fontSize: 15.0))),
                          padding(Text("Pais: "+autos[index].paisorigen, style: TextStyle(fontSize: 15.0)))
                        ])
                  ],
                ),

                    )

                  ],
                ),

              ),
            );
          }
      ),
    );
  }

  Widget padding(Widget widget) {
    return Padding(padding: EdgeInsets.all(7.0),child: widget);
  }
}
