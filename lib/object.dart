class Item {
  final String icon;
  final int category;
  final String name;
  final int hunger;
  final int happy;
  int count;
  final int price;
  final String itemText;

  Item(
    {
      required this.icon, 
      required this.category,
      required this.name, 
      required this.hunger,
      required this.happy,
      required this.count, 
      required this.price,
      required this.itemText,
    }
  );

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      icon: json['icon'],
      category: json['category'],
      name: json['name'],
      hunger: json['hunger'],
      happy: json['happy'],
      count: json['count'],
      price: json['price'],
      itemText: json['itemText'],
    );
  }
  Map<String, dynamic> toJson() => {
    'icon': icon,
    'category': category,
    'name': name,
    'hunger': hunger,
    'happy': happy,
    'count': count,
    'price': price,
    'itemText': itemText,
  };
  
}

class Pets {
  String image;
  String name;
  int hunger;
  int happy;
  int level;
  double currentExp;
  String styleID;

  Pets(
    {
      required this.image, 
      required this.name,
      required this.hunger,
      required this.happy,
      required this.level,
      required this.currentExp,
      required this.styleID,
    }
  );

  factory Pets.fromMap(Map<String, dynamic> map) {
    return Pets(
      image: map['image'],
      name: map['name'],
      hunger: map['hunger'],
      happy: map['happy'],
      level: map['level'],
      currentExp: map['currentExp'],
      styleID: map['styleID'],
    );
  }
  Map<String, dynamic> toJson() => {
    'image': image,
    'name': name,
    'hunger': hunger,
    'happy': happy,
    'level': level,
    'currentExp': currentExp,
    'styleID': styleID,
  };

  factory Pets.copyPet(Pets newPet) {
    return Pets(
      image: newPet.image,
      name: newPet.name,
      hunger: newPet.hunger,
      happy: newPet.happy,
      level: newPet.level,
      currentExp: newPet.currentExp,
      styleID: newPet.styleID,
    );
  }
  factory Pets.fromJson(Map<String, dynamic> json) {
    return Pets(
      image: json['image'],
      name: json['name'],
      hunger: json['hunger'],
      happy: json['happy'],
      level: json['level'],
      currentExp: json['currentExp'],
      styleID: "",
    );
  }
}

class Users {
  int point;
  String image;
  String name;

  Users(
    {
      required this.point,
      required this.image,
      required this.name,
    }
  );

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      point: json['point'],
      image: json['image'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'point': point,
    'image': image,
    'name': name,
  };
}
/*
class Item {
  final String icon;
  final int category;
  final String name;
  final int hunger;
  final int happy;
  int count;
  final int price;
  final String itemText;

  Item(
    {
      required this.icon, 
      required this.category,
      required this.name, 
      required this.hunger,
      required this.happy,
      required this.count, 
      required this.price,
      required this.itemText,
    }
  );

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      icon: json['icon'],
      category: json['category'],
      name: json['name'],
      hunger: json['hunger'],
      happy: json['happy'],
      count: json['count'],
      price: json['price'],
      itemText: json['itemText'],
    );
  }
  Map<String, dynamic> toJson() => {
    'icon': icon,
    'category': category,
    'name': name,
    'hunger': hunger,
    'happy': happy,
    'count': count,
    'price': price,
    'itemText': itemText,
  };
}

class Pets {
  String image;
  String name;
  int hunger;
  int happy;
  int level;
  double currentExp;

  Pets(
    {
      required this.image, 
      required this.name,
      required this.hunger,
      required this.happy,
      required this.level,
      required this.currentExp,
    }
  );

  factory Pets.fromJson(Map<String, dynamic> json) {
    return Pets(
      image: json['image'],
      name: json['name'],
      hunger: json['hunger'],
      happy: json['happy'],
      level: json['level'],
      currentExp: json['currentExp'],
    );
  }
  Map<String, dynamic> toJson() => {
    'image': image,
    'name': name,
    'hunger': hunger,
    'happy': happy,
    'level': level,
    'currentExp': currentExp,
  };

  factory Pets.copyPet(Pets newPet) {
    return Pets(
      image: newPet.image,
      name: newPet.name,
      hunger: newPet.hunger,
      happy: newPet.happy,
      level: newPet.level,
      currentExp: newPet.currentExp,
    );
  }
}

class Users {
  int point;
  String image;
  String name;

  Users(
    {
      required this.point,
      required this.image,
      required this.name,
    }
  );

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      point: json['point'],
      image: json['image'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'point': point,
    'image': image,
    'name': name,
  };
}
*/