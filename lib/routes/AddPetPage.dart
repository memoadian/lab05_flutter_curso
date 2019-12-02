import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'dart:convert';//para usar json
import 'package:progress_dialog/progress_dialog.dart';//progress dialgo al enviar form
import 'package:http/http.dart' as http;//http
import 'package:lab_02/models_api/Pet.dart';//model Pet
import 'package:lab_02/main.dart';//vista principal
import 'package:shared_preferences/shared_preferences.dart';

class AddPetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Añadir Amigo"),
      ),
      body: FormAddPet()
    );
  }
}

class FormAddPet extends StatefulWidget {
  @override
  createState() => FormAddPetState();
}

class FormAddPetState extends State<FormAddPet> {
  //declaramos una variable donde guardaremos el item seleccionado
  String _selectedType = 'Por favor escoge';
  //variable para guardar el Id el item
  String _selectedTypeId;
  //variable auxiliar SwitchListTile
  bool _rescue = false;
  //image file for picker image
  File _imageFile;
  //creamos la variable del progress Dialog
  ProgressDialog pr;

  //global key para validar
  GlobalKey<FormState> _formKey = GlobalKey();

  //declaramos una función para ver si está validado
  bool _validate = false;

  //controladores para los inputs de texto
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  //Lista clave valor para los items del dropdown
  List<PetKeyValue> _data = [
    PetKeyValue(key: 'Perrito', value: '1'),
    PetKeyValue(key: 'Gatito', value: '2'),
  ];

  //declaramos variable de tipo shared preference
  SharedPreferences prefs;
  //variable para validar el color escogido
  bool _isOrange = false;

  @override
  void initState() {
    super.initState();
    _loadColor();//cargar color
  }

  //cargar color del tema
  _loadColor() async {
    //obtenemos la instancia de las shared preferences
    prefs = await SharedPreferences.getInstance();
    setState(() {//seteamos el estado
      //obtenemos la preferencia con la clave 'orange'
      _isOrange = (prefs.getBool('orange') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(//creamos una vista scrolleable
      child: Form(//añadimos un form
        key: _formKey, //añadimos la llave a nuestro form
        //añadimos autovalidate para hacer dinámica la validación de los inputs
        autovalidate: _validate,
        child: _form(),//llamamos desde aqui la funcion que construye el form
      ),
    );
  }

  Widget _form () {
    return Container(//añadimos un contenedor
      padding: EdgeInsets.all(10.0),//padding
      child: Column(//column para multiples hijos
        children: <Widget>[//array
          TextFormField(//text form field para validar
            controller: titleController,//para obtener el contenido del input
            decoration: InputDecoration(
              icon: Icon(Icons.pets),//añadimos un icono
              hintText: 'Nombre', //placeholder
              labelText: 'Nombre:' //label
            ),
            maxLength: 32,
            //usamos una función flecha para llamar la función validar
            validator: (value) => _validReq(value, 'Coloca un nombre a tu amigo'),
          ),
          TextFormField(//text form field para validar
            controller: descriptionController,
            //keyboard type multiline para escribir texto largo
            keyboardType: TextInputType.multiline,
            maxLines: null,//definimos null para no poner limites
            decoration: InputDecoration(
              icon: Icon(Icons.book),//añadimos un icono
              hintText: 'Descripción', //placeholder
              labelText: 'Descripción:' //label
            ),
            maxLength: 512,
            validator: (value) => _validReq(value, 'Agrega una descripción'),
          ),
          TextFormField(//text form field para validar
            controller: ageController,
            //input de tipo numérico
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              icon: Icon(Icons.date_range),//añadimos un icono
              hintText: 'Edad en años', //placeholder
              labelText: 'Edad (Años):' //label
            ),
            maxLength: 2,
            validator: (value) => _validAge(value, 'Coloca la edad aproximada de tu amigo'),
          ),
          Container(//agregamos un container para manejar espacios
            padding: EdgeInsets.only(left: 5.0, top: 10.0),//padding left y top
            child: DropdownButton<PetKeyValue>(//Declaramos el widget dropdown
              hint: Text(_selectedType),//texto placeholder
              isExpanded: true,//expandimos el elemento al 100%
              items: _data.map((data) {//mapeamos el array de tipos
                return DropdownMenuItem<PetKeyValue>(//retornamos cada item
                  value: data,//valor id
                  child: Text(data.key),//texto del valor
                );
              }).toList(),//convertimos en lista
              onChanged: (PetKeyValue value) {//evento change
                _selectedType = value.key;//texto
                setState(() {//seteamos el estado
                  _selectedTypeId = value.value;//cambiamos el elemento seleccionado
                });
              },
            ),
          ),
          //usamos switch list tile en lugar de switch para colocar un
          //label a la izquierda y no centrar el switch
          SwitchListTile(
            title: Text('Rescatado'),//label
            value: _rescue,//activo o inactivo
            onChanged: (bool value) {//evento change param bool
              setState(() {//set state dentro de stateful widget
                _rescue = value;//seteamos el nuevo valor de _rescue
              });
            },
          ),
          _chooseImage(context),
          SizedBox(//sized box permite manejar dimensiones de sus hijos
            width: double.infinity,//colocamos un ancho que se ajuste al padre
            child: RaisedButton(//declaramos el botón sin icono
              onPressed: () => _validateForm(),//al presionar llamamos la funcion validar
              color: (_isOrange) ? Colors.green : Colors.blue,//color
              textColor: Colors.white,//color de texto
              //usamos stack para colocar el icono
              //este elemento nos permite posicionar elementos
              //superpuestos en otros sin afectar espacios
              child: Stack(
                alignment: Alignment.centerLeft,//alineamos al centro a la izquierda
                children: <Widget>[//array de hijos
                  Icon(Icons.send),//icono
                  //colocamos un row para contener el label y ocupar
                  //todo el ancho disponible del botón
                  Row(
                    //centramos el texto
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[//array
                      Text('Enviar')//texto, aqui centrar no sirve
                    ]
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //función escoger imagen
  Widget _chooseImage(BuildContext context) {
    return Center(//centrareamos la imagen
      child: Column(//columna para usar array
        children: <Widget>[//array
          _imageDefault(),//llamamos la funcion imagen por defecto
          RaisedButton(//botón para seleccionar imagen
            child: Text('Escoger Imágen'),//Texto del botón
            //evento press que llama la función para seleccionar
            //imagen pasando la fuente gallery o camera
            onPressed: () => _pickImage(ImageSource.gallery)
          )
        ],
      ),
    );
  }

  _pickImage(ImageSource source) async {//funcion asincrona
    //asignamos la fuente a la variable _imageFile
    _imageFile = await ImagePicker.pickImage(source: source);
    setState(() {//función set state
      //asignamos la variable para que se refleje en la vista
      _imageFile = _imageFile;
    });
  }

  Widget _imageDefault () {//widget imagen por defecto
    return FutureBuilder<File>(//retornamos un future builder de la imagen
      builder: (context, snapshot) {//snapshot de la imagen seleccionada
        return Container(//contenedor
          child: _imageFile == null //si la imagen es nula
                ? Text ('Seleccionar imagen')//colocamos un texto
                //si no es nula retornamos la imagen seleccionada
                : Image.file(_imageFile, width: 300, height: 300),
        );
      }
    );
  }

  void _validateForm () {
    //si todos los inputs son válidos
    if (_formKey.currentState.validate()) {
      //iniciamos la configuración del progress dialog      
      pr = new ProgressDialog(context, 
        type: ProgressDialogType.Normal,//progress normal
        isDismissible: false,//no puede ser cerrado manual
      );
      pr.show();//mostramos el progress dialog

      Pet newPet = Pet(//creamos un nuevo Pet
        name: titleController.text,//nombre del title controller
        desc: descriptionController.text,//descripcion
        //si la edad está vacía por alguna razón la seteamos a 0
        //si no obtenemos el valor numérico del String
        age: (ageController.text != '') ? int.parse(ageController.text) : 0,
        image: _getImage(),//obtenemos la imagen de la función getImage
        typeId: int.parse(_selectedTypeId),//obtenemos el valor numérico del tipo
        statusId: (_rescue) ? 2 : 1,//si el PetAmigo es rescatado 2 - si no 1
      );

      //pasámos el endpoint a la función createPost y el modelo 
      createPost('http://pets.memoadian.com/api/pets', newPet.toMap());
    } else {
      setState(() {
        //seteamos la variable validate a true para hacer dinamico el
        //o los inputs a corregir
        _validate = true;
      });
    }
  }

  String _validReq (String value, String message) {
    //colocamos un condicional corto
    return (value.length == 0) ? message : null;
  }

  String _validAge (String value, String message) {//validar edad
    String patttern = r'(^[0-9]+$)';//usamos un regex para 2 digitos
    RegExp regExp = RegExp(patttern);//instanciamos la clase
    if (value.length == 0) {//validamos primero si no esun input vacío
      return message;//retornamos el mensaje personalizado
    } else if (!regExp.hasMatch(value)) {//validamos si el contenido hace match
      return 'La edad debe ser un número';//retornamos mensaje por defecto
    } else {//si todo está bien
      return null;//retornamos null
    }
  }

  //función para devolver la imagen en base64
  String _getImage () {
    //si la imagen es nula retornamos un String vacío
    if (_imageFile == null) return '';
    //transformamos la imagen a String base64
    String base64Image = base64Encode(_imageFile.readAsBytesSync());
    return base64Image;//retornamos la imagen transformada
  }

  //create post con dos parámetros (endpoint y maps de datos)
  void createPost(String url, Map body) async {//asincrono
    return http.post(url, body: body)//hacemos el request post
      .then((http.Response response) {//cuando responde
        final int statusCode = response.statusCode;//obtenemos el código de respuesta
  
        //si el status es diferente de los considerados correctos
        if (statusCode < 200 || statusCode > 400 || json == null) {
          pr.dismiss();//cerramos el progress dialog
          //creamos una excepción
          throw new Exception("Error while fetching data"+response.body);
        }

        //si todo sale bien mandamos a la vista principal
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ),
        );
      }
    );
  }
}

class PetKeyValue {
  String key;
  String value;

  PetKeyValue({this.key, this.value});
}