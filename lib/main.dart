import 'package:flutter/material.dart';
import 'routes/HomePage.dart';
import 'routes/AdminPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  //variable para validar el color escogido
  bool _isOrange = false;
  //declaramos variable de tipo shared preference
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadColor();
  }

  //cargar color del tema
  _loadColor() async {
    //obtenemos la instancia de las shared preferences
    prefs = await SharedPreferences.getInstance();
    setState(() {//seteamos el estado
      //obtenemos la preferencia con la clave 'orange'
      //con un getter booleano y la guardamos en la variable
      //_isOrange, si no existe "??" indica que por defecto
      //retornará false.
      _isOrange = (prefs.getBool('orange') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Save A Friend",
      theme: ThemeData(
        //obtenemos el color seteado de shared
        primarySwatch: (_isOrange) ? Colors.deepOrange : Colors.blue,
      ),
      /*
       * hacemos un wrapper Builder para no tenere problemas
       * con el Navigator hacia AdminPage y otras rutas.
      */
      home: Builder (
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Salva a un amigo"),
            actions: <Widget>[//elementos lado derecho appbar
              Builder(//builder
                //función para entregar eventos del builder
                builder: (context) => IconButton(//botón con ícono
                  icon: Icon(Icons.settings),//ícono settings
                  //al presionar abrimos el endDrawer
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  //al mantener presionado el botón lanzamos un tooltip
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                )
              )
            ],
          ),
          /* INICIO DRAWER */
          drawer: Drawer(
            child: ListView(//lista de elementos
              children: <Widget>[//array
                ListTile(//elemento de la lista
                  leading: Icon(Icons.home),//icono, puede ser una imagen
                  title: Text('Inicio'),//texto del título
                  //onTap: () {}, //lo manejaremos más adelante
                ),
                ListTile(//elemento de la lista
                  leading: Icon(Icons.pets),
                  title: Text('Administrar'),
                  onTap: () {//declaramos el evento para este elemento
                    Navigator.push(context,//creamos una instancia Navigator con el contexto
                      MaterialPageRoute(//instancia Material Page Route
                        builder: (context) => AdminPage(),//mandamos al adminpage
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          /* FIN DRAWER */
          endDrawer: Drawer(//drawer lado derecho
            child: Column(//columna para array de elementos
              children: <Widget>[//array
                AppBar(//appbar del drawer
                  //ocultamos el icono por defecto al abrir el drawer
                  automaticallyImplyLeading: false,
                  title: Text('Settings'),//título del drawer
                  actions: <Widget>[//ícono personalizado de drawer
                    new IconButton(//ícono presionable
                      icon: new Icon(Icons.close),//ícono para el botón
                      onPressed: () => (//al presionar
                        Navigator.pop(context)//cerrar el drawer
                      ),
                    )
                  ],
                ),
                Column (//columna
                  children: <Widget>[//array
                    SwitchListTile(//switch con label
                      value: _isOrange,//seteamos el valor true o false
                      //cuando detectamos el evento change
                      onChanged: (val) => setState(() {//seteamos el estado
                        _isOrange = val;//asignamos el nuevo valor a la variable
                        //guardamos el valor en shared
                        prefs.setBool('orange', _isOrange);
                      }),
                      //texto de label
                      title: Text('Tema Naranja'),
                    ),
                  ]
                ),
              ],
            ),
          ),          
          body: HomePage(),
        ),
      ),
    );
  }
}