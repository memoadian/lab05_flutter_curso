import 'package:flutter/material.dart'; //material
import 'package:lab_05_flutter_curso/models_api/pet.dart'; //clase Pet
import 'package:lab_05_flutter_curso/routes/detail_pet_page.dart'; //clase Detail Pet

import 'dart:convert'; //dependencia para json
import 'package:http/http.dart' as http; //http

import 'package:lab_05_flutter_curso/models_sqlite/fav.dart';
import 'package:lab_05_flutter_curso/models_sqlite/fav_helper.dart';

import 'package:toast/toast.dart';

class PetsList extends StatefulWidget {
  @override
  createState() => PetsListState();
}

class PetsListState extends State<PetsList> {
  final dbHelper = FavHelper();
  //creamos una variable para guardar una lista de amigos
  List<Pet> _pets = [];

  @override
  void initState() {
    super.initState();
    getPets();
  }

  // declaramos la funcion de tipo Future Null asincrona
  Future<Null> getPets() async {
    //consumimos el webservice con la librería http y get
    var uri = Uri.parse("http://pets.memoadian.com/api/pets/");
    final response = await http.get(uri);

    //si la respuesta es correcta responderá con 200
    if (response.statusCode == 200) {
      final result =
          json.decode(response.body); //guardamos la respuesta en json
      /* accedemos al array data que es el que nos interesa
       * y lo guardamos en una variable de tipo Iterable
       */
      Iterable list = result['data'];
      setState(() {
        //seteamos el estado para actualizar los cambios
        //mapeamos la lista en modelos Pet
        print(list.map((model) => Pet.fromJson(model)).toString());
        _pets = list.map((model) => Pet.fromJson(model)).toList();
      });
    } else {
      throw Exception('Fallo al cargar información del servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //regresamos un Scaffold de contenedor
      body: ListView.builder(
        //creamos un Listview Builder
        itemCount: _pets.length, //pasamos la longitud del array list
        itemBuilder:
            _buildItemsForListView, //llamamos la función que hará la iteración
      ),
    );
  }

  /* 
   * la función _buildItemsForListView recibe 2 parámetros, el contexto
   * y la posición del item a mostrar para mostrar detalles
   * retornamos el Card que construimos en Home Page
  */
  Widget _buildItemsForListView(BuildContext context, int index) {
    return Card(
      //creamos una card
      margin: EdgeInsets.all(10.0), //margen de 10
      child: Column(
        //creamos una columna para colocar varios hijos
        children: <Widget>[
          //array
          Container(
            //contenedor de imagen
            padding: EdgeInsets.all(10.0), //padding
            child: Image.network(_pets[index].image), //imagen interna
          ),
          Container(
            //contenedor de texto
            padding: EdgeInsets.all(10.0), //padding
            child: Text(_pets[index].name, //título
                style: TextStyle(fontSize: 18) //estilo del texto
                ),
          ),
          Container(
            //contenedor de botones
            child: Row(
              //row para alinear botones en fila
              //esta propiedad permite que los botones se
              //distribuyan equitativamente
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                //usamos un array de botones
                TextButton.icon(
                  //instancia del icono de navegación
                  icon: Icon(Icons.remove_red_eye, //definimos nombre del icono
                      size: 18.0, //tamaño
                      color: Colors.blue //color
                      ),
                  label: Text('Ver amigo'), //nombre del botón
                  onPressed: () {
                    //evento press
                    Navigator.push(
                      context, //mandamos el navegador
                      MaterialPageRoute(
                        builder: (context) => DetailPetPage(
                            _pets[index].id), //a la página de detalle
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  //instancia del icono de favoritos
                  icon: Icon(Icons.favorite, //definimos nombre del icono
                      size: 18.0, //tamaño
                      color: Colors.red //color
                      ),
                  label: Text('Me gusta'), //nombre del botón
                  onPressed: () {
                    //evento press
                    _insert(_pets[index].name, _pets[index].age,
                        _pets[index].image);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //insertar nuevo fav
  void _insert(String name, int age, String image) async {
    //llamamos el dbHelper para guardar el registro
    dbHelper.saveFav(new Fav(name, age.toString(), image)).then((_) {
      //cuando se termina lanzamos el toast
      Toast.show('Amigo agregado a favoritos', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    });
  }
}
