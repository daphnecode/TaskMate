class Item {
  final String icon;
  final int category;
  final int hunger;
  final int happy;
  final String name;
  int count;
  final int price;
  final String itemText;

  Item(
    {
      required this.icon, 
      required this.category,
      required this.hunger,
      required this.happy,
      required this.name, 
      required this.count, 
      required this.price,
      required this.itemText,
    }
  );

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      icon: json['icon'],
      category: json['category'],
      hunger: json['hunger'],
      happy: json['happy'],
      name: json['name'],
      count: json['count'],
      price: json['price'],
      itemText: json['itemText'],
    );
  }
  Map<String, dynamic> toJson() => {
    'icon': icon,
    'category': category,
    'hunger': hunger,
    'happy': happy,
    'name': name,
    'count': count,
    'price': price,
    'itemText': itemText,
  };
}

class Pets {
  final String image;
  final String name;
  int hunger;
  int happy;
  int level;
  int currentExp;

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
}