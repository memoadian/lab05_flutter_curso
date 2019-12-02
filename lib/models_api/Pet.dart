class Pet { // creamos una clase Pet
  //creamos las variables para cada propiedad
  final int id;
  final String name;
  final String desc;
  final int age;
  final String image;
  final String type;
  final int typeId;//id del tipo de petAmigo
  final String status;
  final int statusId;//status del petAmigo

  //asignamos las variables en el constructor
  Pet({
    this.id,
    this.name,
    this.desc,
    this.age,
    this.image,
    this.type,
    this.typeId,//añadimos al constructor
    this.status,
    this.statusId//añadimos al constructor
  });

  /* mapeamos la respuesta para usarla más facilmente
   * en los items y clases de la aplicación
   * */
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      age: json['age'],
      image: json['image'] ?? 'logo_flutter.png',
      type: json['type']['name'],
      typeId: json['type']['id'],
      status: json['status']['name'],
      statusId: json['status']['id']
    );
  }

  //añadimos una función para mapear los datos del formulario
  Map toMap() {
    var map = Map<String, dynamic>();
    map['name'] = name;
    map['desc'] = desc;
    map['age'] = age.toString();//transformamos int a String
    map['image'] = image;
    map['typeId'] = typeId.toString();//transformamos int a String
    map['statusId'] = statusId.toString();//transformamos int a String
 
    return map;
  }
}