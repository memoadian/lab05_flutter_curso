class Fav {
  int _id;//id interno
  String _name;//nombre
  String _age;//edad
  String _image;//
 
  //constructor
  Fav(this._name, this._age, this._image);

  //mapeamos los elementos dinamicamente
  Fav.map(dynamic obj) {
    this._id = obj['id'];
    this._name = obj['name'];
    this._age = obj['age'];
    this._image = obj['image'];
  }

  //getters
  int get id => _id;
  String get name => _name;
  String get age => _age;
  String get image => _image;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {//si el id no viene nulo
      map['id'] = _id;//lo asignamos
    }
    map['name'] = _name;
    map['age'] = _age;
    map['image'] = _image;

    return map;
  }

  Fav.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._age = map['age'];
    this._image = map['image'];
  }
}