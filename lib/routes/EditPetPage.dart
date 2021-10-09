import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'dart:convert'; //para usar json
import 'package:http/http.dart' as http; //http
import 'package:lab_05_flutter_curso/models_api/Pet.dart'; //model Pet
import 'package:lab_05_flutter_curso/main.dart'; //vista principal

class EditPetPage extends StatefulWidget {
  final int? id; //variable id

  EditPetPage(this.id); //constructor

  @override
  createState() => EditPetPageState(); //estado
}

class EditPetPageState extends State<EditPetPage> {
  //variable _pet para guardar datos del server
  Pet _pet = Pet();
  //declaramos una variable donde guardaremos el item seleccionado
  String _selectedType = 'Por favor escoge';
  //variable para guardar el Id el item
  String? _selectedTypeId;
  //variable auxiliar SwitchListTile
  bool _rescue = false;
  //image file for picker image
  XFile? _imageFile;
  ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;

  //global key para validar
  GlobalKey<FormState> _formKey = GlobalKey();

  //controladores para los inputs de texto
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  String? typeId; //type id para el dropdown
  int? statusId; //statusId (rescatado o no)

  //Lista clave valor para los items del dropdown
  List<PetKeyValue> _data = [
    PetKeyValue(key: 'Perrito', value: '1'),
    PetKeyValue(key: 'Gatito', value: '2'),
  ];

  @override
  void initState() {
    super.initState();
    _getEditPet();
  }

  Future<Null> _getEditPet() async {
    //consumimos el webservice pasando el parámetro id
    final response = await http
        .get(Uri.parse("http://pets.memoadian.com/api/pets/${widget.id}"));

    //si la respuesta es correcta responderá con 200
    if (response.statusCode == 200) {
      //guardamos la respuesta en una variable en json
      final result = json.decode(response.body);
      setState(() {
        _pet = Pet.fromJson(result); //mapeamos el resultado en el modelo
        titleController.text =
            _pet.name; //asignamos el nombre al titleController
        descriptionController.text = _pet.desc; //descriptionController
        ageController.text = _pet.age.toString(); //ageController en String
        typeId = _pet.typeId.toString(); //typeId en String
        statusId = _pet.statusId; //statusId en integer
        //estas variables se setean por si el usuario no activa
        //la funcion on changed del form
        _rescue = (statusId == 2) ? true : false; //condicional rescatado
        _selectedTypeId = typeId; //el tipo seleccionado
      });
    } else {
      throw Exception('Fallo al cargar información del servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Amigo'),
      ),
      body: SingleChildScrollView(
        //creamos una vista scrolleable
        child: Form(
            //añadimos un form
            key: _formKey, //añadimos la llave a nuestro form
            //añadimos autovalidate para hacer dinámica la validación de los inputs
            autovalidateMode: AutovalidateMode.always,
            child: (_pet.name != null) //si pet tiene datos
                ? _form() //mostramos el form
                : progress() //si no, cargamos la función progress
            ),
      ),
    );
  }

  Widget progress() {
    return SizedBox(
      //la usamos para determinar las medidas
      width: double.infinity, //full width
      height: 300.0, //height 300
      child: Center(
        //centramos
        child: CircularProgressIndicator(), //progress circular
      ),
    );
  }

  Widget _form() {
    return Container(
      //añadimos un contenedor
      padding: EdgeInsets.all(10.0), //padding
      child: Column(
        //column para multiples hijos
        children: <Widget>[
          //array
          TextFormField(
            //text form field para validar
            controller: titleController, //para obtener el contenido del input
            decoration: InputDecoration(
                icon: Icon(Icons.pets), //añadimos un icono
                hintText: 'Nombre', //placeholder
                labelText: 'Nombre:' //label
                ),
            maxLength: 32,
            //usamos una función flecha para llamar la función validar
            validator: (value) =>
                _validReq("$value", 'Coloca un nombre a tu amigo'),
          ),
          TextFormField(
            //text form field para validar
            controller: descriptionController,
            //keyboard type multiline para escribir texto largo
            keyboardType: TextInputType.multiline,
            maxLines: null, //definimos null para no poner limites
            decoration: InputDecoration(
                icon: Icon(Icons.book), //añadimos un icono
                hintText: 'Descripción', //placeholder
                labelText: 'Descripción:' //label
                ),
            maxLength: 512,
            validator: (value) => _validReq("$value", 'Agrega una descripción'),
          ),
          TextFormField(
            //text form field para validar
            controller: ageController,
            //input de tipo numérico
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                icon: Icon(Icons.date_range), //añadimos un icono
                hintText: 'Edad en años', //placeholder
                labelText: 'Edad (Años):' //label
                ),
            maxLength: 2,
            validator: (value) =>
                _validAge("$value", 'Coloca la edad aproximada de tu amigo'),
          ),
          Container(
            //agregamos un container para manejar espacios
            padding: EdgeInsets.only(left: 5.0, top: 10.0), //padding left y top
            child: DropdownButton<PetKeyValue>(
              //Declaramos el widget dropdown
              hint: Text(_selectedType), //texto placeholder
              //firstWhere devuelve la primera coincidencia de un array, en este caso buscamos
              //el elemento cuyo value sea igual al typeId de los datos y si no hay devolverá null
              value: _data.firstWhere(
                (data) => data.value == typeId,
                orElse: () => PetKeyValue(key: 'Perrito', value: '1'),
              ),
              isExpanded: true, //expandimos el elemento al 100%
              items: _data.map((data) {
                //mapeamos el array de tipos
                return DropdownMenuItem<PetKeyValue>(
                  //retornamos cada item
                  value: data, //valor id
                  child: Text("${data.key}"), //texto del valor
                );
              }).toList(), //convertimos en lista
              onChanged: (PetKeyValue? value) {
                //evento change
                _selectedType = "${value!.key}"; //texto
                setState(() {
                  //seteamos el estado
                  _selectedTypeId =
                      value.value; //cambiamos el elemento seleccionado
                });
              },
            ),
          ),
          //usamos switch list tile en lugar de switch para colocar un
          //label a la izquierda y no centrar el switch
          SwitchListTile(
            title: Text('Rescatado'), //label
            value: _rescue, //activo o inactivo
            onChanged: (bool value) {
              //evento change param bool
              setState(() {
                //set state dentro de stateful widget
                _rescue = value; //seteamos el nuevo valor de _rescue
              });
            },
          ),
          //pasamos el contexto y el snapshot
          _chooseImage(context),
          SizedBox(
            //sized box permite manejar dimensiones de sus hijos
            width: double.infinity, //colocamos un ancho que se ajuste al padre
            child: ElevatedButton(
              //declaramos el botón sin icono
              onPressed: () =>
                  _validateForm(), //al presionar llamamos la funcion validar
              //usamos stack para colocar el icono
              //este elemento nos permite posicionar elementos
              //superpuestos en otros sin afectar espacios
              child: Stack(
                alignment:
                    Alignment.centerLeft, //alineamos al centro a la izquierda
                children: <Widget>[
                  //array de hijos
                  Icon(Icons.send), //icono
                  //colocamos un row para contener el label y ocupar
                  //todo el ancho disponible del botón
                  Row(
                      //centramos el texto
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //array
                        Text('Enviar') //texto, aqui centrar no sirve
                      ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //función escoger imagen con parámetro context y snapshot
  Widget _chooseImage(BuildContext context) {
    return Center(
      //centrareamos la imagen
      child: Column(
        //columna para usar array
        children: <Widget>[
          //array
          //llamamos la funcion imagen por defecto
          //y pasamos de nuevo el snapshot
          _imageDefault(),
          ElevatedButton(
              //botón para seleccionar imagen
              child: Text('Escoger Imágen'), //Texto del botón
              //evento press que llama la función para seleccionar
              //imagen pasando la fuente gallery o camera
              onPressed: () => _pickImage(ImageSource.gallery))
        ],
      ),
    );
  }

  _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
      );
      setState(() {
        _imageFile = pickedFile as XFile;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
      print(_pickImageError);
    }
  }

  Widget _imageDefault() {
    //widget imagen por defecto
    if (_pet.image != null) {
      //si la propiedad image no es nula
      //retornamos un future builder de la imagen al ser seleccionada
      return FutureBuilder<File>(builder: (context, snapshot) {
        //snapshot de la imagen seleccionada
        return Container(
          //contenedor
          child: _imageFile == null //si la imagen es nula
              //colocamos la imagen del server
              ? Image.network(_pet.image)
              //si no es nula retornamos la imagen seleccionada
              : Image.file(
                  File(_imageFile!.path),
                  width: 300,
                  height: 150,
                ),
        );
      });
    }

    //por defecto retornamos un progress circular
    return CircularProgressIndicator();
  }

  void _validateForm() {
    //si todos los inputs son válidos
    if (_formKey.currentState!.validate()) {
      //iniciamos la configuración del progress dialog
      showLoaderDialog(context);

      Pet newPet = Pet(
        //creamos un nuevo Pet
        name: titleController.text, //nombre del title controller
        desc: descriptionController.text, //descripcion
        //si la edad está vacía por alguna razón la seteamos a 0
        //si no obtenemos el valor numérico del String
        age: (ageController.text != '') ? int.parse(ageController.text) : 0,
        image: _getImage(), //obtenemos la imagen de la función getImage
        typeId: int.parse(
            "$_selectedTypeId"), //obtenemos el valor numérico del tipo
        statusId: (_rescue) ? 2 : 1, //si el PetAmigo es rescatado 2 - si no 1
      );

      //pasámos el endpoint a la función updatePost y el modelo
      updatePost(
          'http://pets.memoadian.com/api/pets/$widget.id', newPet.toMap());
    }
  }

  String? _validReq(String value, String message) {
    //colocamos un condicional corto
    return (value.length == 0) ? message : null;
  }

  String? _validAge(String value, String message) {
    //validar edad
    String patttern = r'(^[0-9]+$)'; //usamos un regex para 2 digitos
    RegExp regExp = RegExp(patttern); //instanciamos la clase
    if (value.length == 0) {
      //validamos primero si no esun input vacío
      return message; //retornamos el mensaje personalizado
    } else if (!regExp.hasMatch(value)) {
      //validamos si el contenido hace match
      return 'La edad debe ser un número'; //retornamos mensaje por defecto
    } else {
      //si todo está bien
      return null; //retornamos null
    }
  }

  //función para devolver la imagen en base64
  String _getImage() {
    //si la imagen es nula retornamos un String vacío
    if (_imageFile == null) return '';
    //transformamos la imagen a String base64
    File _image = File("$_imageFile");
    String base64Image = base64Encode(_image.readAsBytesSync());
    return base64Image; //retornamos la imagen transformada
  }

  //create post con dos parámetros (endpoint y maps de datos)
  void updatePost(String url, Map body) async {
    //asincrono
    return http.put(Uri.parse(url), body: body) //hacemos el request put
        .then((http.Response response) {
      //cuando responde
      final int statusCode =
          response.statusCode; //obtenemos el código de respuesta

      //si el status es diferente de los considerados correctos
      if (statusCode < 200 || statusCode > 400) {
        //creamos una excepción
        throw new Exception("Error while fetching data" + response.body);
      }

      //si todo sale bien mandamos a la vista principal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(),
        ),
      );
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class PetKeyValue {
  String? key;
  String? value;

  PetKeyValue({
    this.key,
    this.value,
  });
}
