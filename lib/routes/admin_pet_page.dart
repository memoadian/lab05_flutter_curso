import 'package:flutter/material.dart';
import 'package:lab_05_flutter_curso/routes/add_pet_page.dart';
import 'package:lab_05_flutter_curso/routes/edit_pet_page.dart'; //importamos Añadir amigo
import 'package:lab_05_flutter_curso/models_api/pet.dart'; //importamos el mdoelo Pet.dart+
import 'dart:convert'; //json
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lab_05_flutter_curso/models_sqlite/fav.dart';
import 'package:lab_05_flutter_curso/models_sqlite/fav_helper.dart';

class AdminPage extends StatefulWidget {
  @override
  createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  //declaramos la variable helper
  final dbHelper = FavHelper();
  //lista de Fav
  List<Fav> _favs = [];
  //declaramos la variable que guardará la lista de elementos
  List<Pet> _pets = [];
  //declaramos variable de tipo shared preference
  SharedPreferences? prefs;
  //variable para validar el color escogido
  bool _isOrange = false;

  @override
  void initState() {
    super.initState();
    getPets(); //traer mascotas
    getFavs(); //traer los favoritos
    _loadColor(); //cargar color
  }

  //cargar color del tema
  _loadColor() async {
    //obtenemos la instancia de las shared preferences
    prefs = await SharedPreferences.getInstance();
    setState(() {
      //seteamos el estado
      //obtenemos la preferencia con la clave 'orange'
      _isOrange = (prefs?.getBool('orange') ?? false);
    });
  }

  //traer los pets favoritos
  void getFavs() {
    //obtenemos todos los elementos
    dbHelper.getAllFavs().then((favs) {
      //seteamos el resultado en el estado
      setState(() {
        favs.forEach((fav) {
          //recorremos el array obtenido
          //y lo agregamos al array existente dinámico
          _favs.add(Fav.fromMap(fav)); //mapeando con la funcion fromMap
        });
      });
    });
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
    /*
     * llamamos una función que retornará el widget
     * que contiene las tabs de navegación entre un
     * contenido y otro
    */
    return tabs(context);
  }

  Widget tabs(BuildContext context) {
    return DefaultTabController(
      //este Widget es el que crea las tabs
      length: 2, //pasamos el numero de tabs a mostrar
      child: Scaffold(
        //retornamos un scaffold
        appBar: AppBar(
          //colocamos el appbar aquí adentro
          bottom: TabBar(
            //colocamos el tabbar
            tabs: [
              //array de tabs
              Tab(text: 'Favoritos'), //texto de la pestaña
              Tab(text: 'Todos'), //texto de la pestaña
            ],
          ),
          title: Text('Más Petamigos'), //titulo de la appbar
        ),
        body: TabBarView(
          //body del tabbar controller
          children: [
            //array (debe ser el mismo que se declara en length)
            favs(context), //función favoritos
            server(context), //función server
          ],
        ),
        //declaramos un floating button
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //evento press
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPetPage(), //navegamos a añadir amigo
              ),
            );
          },
          child: Icon(Icons.add), //ícono del botón
          backgroundColor:
              (_isOrange) ? Colors.green : Colors.blue, //color del botón
        ),
      ),
    );
  }

  Widget favs(BuildContext context) {
    //añadimos un param context para la ruta
    return ListView.builder(
      //cambiamos el texto por un listView
      itemCount: _favs.length,
      itemBuilder: _favsBuilder,
    );
  }

  Widget _favsBuilder(context, position) {
    return Card(
      //card
      margin: EdgeInsets.all(5.0), //margen
      child: ListTile(
        //Listile para ordenar
        title: Text(_favs[position].name), //titulo
        subtitle: Text('Edad: ${_favs[position].age} años'), //subtitulo
        leading: Column(
          //creamos una columna para contener la imagen
          children: <Widget>[
            //array
            Padding(padding: EdgeInsets.all(0)), //padding
            ClipRRect(
              //haremos que la imagen tenga borde redondeado
              //al 100% para que sea circular
              borderRadius: new BorderRadius.circular(100.0),
              child: Image.network(
                //imagen de internet
                _favs[position].image, //propiedad imagen
                height: 50.0, //alto
                width: 50.0, //ancho
              ),
            )
          ],
        ),
        trailing: Row(
          //Row para acomodar iconos al final
          mainAxisSize: MainAxisSize.min, //ordenamiento horizontal
          children: <Widget>[
            //array
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //navegar a editar amigo
                    builder: (context) => EditPetPage(_favs[position].id),
                  ),
                );
              },
            ),
            IconButton(
              //icono con botón
              icon: Icon(Icons.delete), //icono
              //evento press eliminar
              onPressed: () => _deleteFav(context, _favs[position], position),
            ),
          ],
        ),
      ),
    );
  }

  Widget server(BuildContext context) {
    return ListView.builder(
      //listview builder
      itemCount: _pets.length, //contamos los elementos de la lista
      itemBuilder:
          _petsBuilder, //llamamos a la función que renderiza cada elemento
    );
  }

  Widget _petsBuilder(BuildContext context, int pos) {
    return Card(
      //card
      margin: EdgeInsets.all(5.0), //margen
      child: ListTile(
        //Listile para ordenar
        //obtenemos el nombre del array pets propiedad name
        title: Text(_pets[pos].name),
        subtitle: Text('Edad: ${_pets[pos].age}'), //edad
        leading: Column(
          //creamos una columna para contener la imagen
          children: <Widget>[
            //array
            Padding(padding: EdgeInsets.all(0)), //padding
            ClipRRect(
              //haremos que la imagen tenga borde redondeado
              //al 100% para que sea circular
              borderRadius: new BorderRadius.circular(100.0),
              child: Image.network(
                //imagen de internet
                _pets[pos].image, //propiedad imagen
                height: 50.0, //alto
                width: 50.0, //ancho
              ),
            )
          ],
        ),
        trailing: Row(
          //Row para  iconos al final
          mainAxisSize: MainAxisSize.min, //ordenamiento horizontal
          children: <Widget>[
            //array
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      //navegar a editar amigo
                      builder: (context) => EditPetPage(_pets[pos].id)),
                );
              },
            ),
            IconButton(
              //icono con botón
              icon: Icon(Icons.delete), //icono
              //evento press eliminar llevará los parámetros contexto
              //la posicion del elemento, y el id para consumir el ws
              onPressed: () => deleteAlert(context, pos, _pets[pos].id),
            ),
          ],
        ),
      ),
    );
  }

  //función asincrona estandar para un alert
  Future deleteAlert(BuildContext context, int position, int id) async {
    return showDialog<Null>(
      //funcion showDialog
      context: context, //declaramos el contexto de la alerta
      builder: (BuildContext context) {
        //iniciamos el builder
        return AlertDialog(
          //retornamos un AlertDialog
          title: Text('Confirmar'), //titulo del alert
          content: const Text('Esta acción no puede deshacerse'), //body
          actions: <Widget>[
            //array de botones
            TextButton(
              //botón cancelar
              child: Text('Cancelar'), //texto del botón cancelar
              onPressed: () {
                //al presionar
                Navigator.of(context).pop(); //cerramos el alert
              },
            ),
            TextButton(
              //botón confirmar
              child: Text('Eliminar'), //texto del botón de confirmar
              onPressed: () {
                //al presionar
                //llamamos la función que elimina el elemento
                deletePet(context, position, id);
              },
            ),
          ],
        );
      },
    );
  }

  //funcion asincrona para eliminar elementos del servidor por ID
  void deletePet(context, int position, int id) async {
    String url = 'http://pets.memoadian.com/api/pets/$id'; //url

    //metodo delete
    return http.delete(Uri.parse(url)).then((http.Response response) {
      final int statusCode = response.statusCode;

      // si el status es erroneo
      if (statusCode < 200 || statusCode > 400) {
        print(response.body); //imprimimos el error en consola
        //y creamos una excepcion
        throw new Exception('Error al consumir el servicio');
      }

      //si todo sale bien.
      setState(() {
        //eliminamos el elemento de la vista
        _pets.removeAt(position);
      });

      // y cerramos el alert dialog
      Navigator.of(context).pop();
    });
  }

  void _deleteFav(BuildContext context, Fav fav, int position) async {
    //eliminamos de la base de datos interna
    dbHelper.deleteFav(fav.id).then((fav) {
      //al terminar seteamos el estado
      setState(() {
        //eliminando el elemento de la lista
        _favs.removeAt(position);
      });
    });
  }
}
