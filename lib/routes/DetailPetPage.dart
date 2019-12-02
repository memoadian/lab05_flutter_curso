import 'package:flutter/material.dart';
import 'package:lab_02/models_api/Pet.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;//http

class DetailPetPage extends StatelessWidget {
  //declaramos el id
  final int id;
  //creamos el constructor de la clase con el param id
  DetailPetPage(this.id);

  //declaramos la funcion future de tipo pet
  Future<Pet> fetchPet() async {
    //hacemos el request get pasando el id al endpoint
    final response = await http.get('http://pets.memoadian.com/api/pets/$id');

    // si la respuesta es 200
    if (response.statusCode == 200) {
      //ahora retornamos el model Pet
      return Pet.fromJson(json.decode(response.body));
    } else {
      //si no lanzamos una excepción
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {//widget
    return Scaffold(// Scaffold
      appBar: AppBar(//AppBar
        title: Text('Ver Amigo'),//titulo appbar
      ),
      //Future Builder para cachar la respuesta en un snapshot
      body: FutureBuilder<Pet>(
        //usamos la propiedad future para llamar la función fetchPet
        future: fetchPet(),
        //usamos un builder para pasar el parámetro snapshot
        builder: (context, snapshot){
          //si existen datos en el snapshot
          if (snapshot.hasData) {
            return Container(
              child: Card(//creamos una card
                margin: EdgeInsets.all(10.0),//margen de 10
                child: Column(//creamos una columna para colocar varios hijos
                  mainAxisSize: MainAxisSize.min,//definimos ualtura ajustable a contenido
                  children: <Widget>[//array
                    Container (//contenedor de imagen
                      padding: EdgeInsets.all(10.0),//padding
                      //imagen de servidor snapshot data image
                      child: Image.network(snapshot.data.image),
                    ),
                    Container (//contenedor de texto
                      padding: EdgeInsets.all(10.0),//padding
                      child: Text(snapshot.data.name,//título snapshot
                        style: TextStyle(fontSize: 18)//estilo del texto
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Text(//descripción snapshot descripción
                        snapshot.data.desc, textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          //si hay un error en el snapshot
          } else if (snapshot.hasError) {
            // lo mostramos en la vista
            return Text('${snapshot.error}');
          }
          //por defecto mostramos un progress en lo que responde el servidor
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Cargando'),
                ),
                CircularProgressIndicator()
              ],
            ),
          );
        }
      ),
    );
  }
}

/*
class PetPage extends StatefulWidget {
  final int id;
  PetPage(this.id);

  @override
  createState() => PetPageState(id);
}

class PetPageState extends State<PetPage> {
  final int id;
  Pet _pet = Pet();

  PetPageState(this.id);

  Future<Pet> fetchPet() async {
    final response = await http.get('http://pets.memoadian.com/api/pets/$id');

    if (response.statusCode == 200) {
      _pet = Pet.fromJson(json.decode(response.body));
    } else {
      throw Exception('Fallo al cargar información del servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(//creamos una card
        margin: EdgeInsets.all(10.0),//margen de 10
        child: Column(//creamos una columna para colocar varios hijos
          mainAxisSize: MainAxisSize.min,//definimos ualtura ajustable a contenido
          children: <Widget>[//array
            Container (//contenedor de imagen
              padding: EdgeInsets.all(10.0),//padding
              child: Image.asset('images/logo_flutter.png'),//imagen interna
            ),
            Container (//contenedor de texto
              padding: EdgeInsets.all(10.0),//padding
              child: Text('Flutter 2',//título
                style: TextStyle(fontSize: 18)//estilo del texto
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(//descripción
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'+
                'Ut blandit porta lectus, ut vulputate ligula maximus quis.'+
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'+
                'Ut blandit porta lectus, ut vulputate ligula maximus quis.'
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/