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

  Map<String, dynamic> toMap() => {
    'icon': icon,
    'category': category,
    'name': name,
    'hunger': hunger,
    'happy': happy,
    'count': count,
    'price': price,
    'itemText': itemText,
  };

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      icon: map['icon'],
      category: map['category'],
      name: map['name'],
      hunger: map['hunger'],
      happy: map['happy'],
      count: map['count'],
      price: map['price'],
      itemText: map['itemText'],
    );
  }
  
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
  
  Map<String, dynamic> toMap() => {
    'image': image,
    'name': name,
    'hunger': hunger,
    'happy': happy,
    'level': level,
    'currentExp': currentExp,
    'styleID': styleID,
  };
}

// Pet 레벨 정보 클래스
class PetLevel {
  final int level;
  final int expToNext;  // 다음 레벨까지 필요한 경험치
  final int totalExp;   // 누적 경험치

  const PetLevel({
    required this.level,
    required this.expToNext,
    required this.totalExp,
  });
}

// 1~100 레벨 데이터 테이블
const List<PetLevel> petLevelTable = [
  PetLevel(level: 1, expToNext: 5, totalExp: 5),
  PetLevel(level: 2, expToNext: 5, totalExp: 10),
  PetLevel(level: 3, expToNext: 5, totalExp: 15),
  PetLevel(level: 4, expToNext: 6, totalExp: 21),
  PetLevel(level: 5, expToNext: 6, totalExp: 27),
  PetLevel(level: 6, expToNext: 6, totalExp: 33),
  PetLevel(level: 7, expToNext: 6, totalExp: 39),
  PetLevel(level: 8, expToNext: 7, totalExp: 46),
  PetLevel(level: 9, expToNext: 7, totalExp: 53),
  PetLevel(level: 10, expToNext: 7, totalExp: 60),
  PetLevel(level: 11, expToNext: 7, totalExp: 67),
  PetLevel(level: 12, expToNext: 8, totalExp: 75),
  PetLevel(level: 13, expToNext: 8, totalExp: 83),
  PetLevel(level: 14, expToNext: 8, totalExp: 91),
  PetLevel(level: 15, expToNext: 8, totalExp: 99),
  PetLevel(level: 16, expToNext: 9, totalExp: 108),
  PetLevel(level: 17, expToNext: 9, totalExp: 117),
  PetLevel(level: 18, expToNext: 10, totalExp: 127),
  PetLevel(level: 19, expToNext: 10, totalExp: 137),
  PetLevel(level: 20, expToNext: 10, totalExp: 147),
  PetLevel(level: 21, expToNext: 11, totalExp: 158),
  PetLevel(level: 22, expToNext: 11, totalExp: 169),
  PetLevel(level: 23, expToNext: 11, totalExp: 180),
  PetLevel(level: 24, expToNext: 12, totalExp: 192),
  PetLevel(level: 25, expToNext: 12, totalExp: 204),
  PetLevel(level: 26, expToNext: 13, totalExp: 217),
  PetLevel(level: 27, expToNext: 13, totalExp: 230),
  PetLevel(level: 28, expToNext: 14, totalExp: 244),
  PetLevel(level: 29, expToNext: 14, totalExp: 258),
  PetLevel(level: 30, expToNext: 15, totalExp: 273),
  PetLevel(level: 31, expToNext: 16, totalExp: 289),
  PetLevel(level: 32, expToNext: 16, totalExp: 305),
  PetLevel(level: 33, expToNext: 17, totalExp: 322),
  PetLevel(level: 34, expToNext: 17, totalExp: 339),
  PetLevel(level: 35, expToNext: 18, totalExp: 357),
  PetLevel(level: 36, expToNext: 19, totalExp: 376),
  PetLevel(level: 37, expToNext: 19, totalExp: 395),
  PetLevel(level: 38, expToNext: 20, totalExp: 415),
  PetLevel(level: 39, expToNext: 21, totalExp: 436),
  PetLevel(level: 40, expToNext: 22, totalExp: 458),
  PetLevel(level: 41, expToNext: 23, totalExp: 481),
  PetLevel(level: 42, expToNext: 24, totalExp: 505),
  PetLevel(level: 43, expToNext: 24, totalExp: 529),
  PetLevel(level: 44, expToNext: 25, totalExp: 554),
  PetLevel(level: 45, expToNext: 26, totalExp: 580),
  PetLevel(level: 46, expToNext: 27, totalExp: 607),
  PetLevel(level: 47, expToNext: 28, totalExp: 635),
  PetLevel(level: 48, expToNext: 30, totalExp: 665),
  PetLevel(level: 49, expToNext: 31, totalExp: 696),
  PetLevel(level: 50, expToNext: 32, totalExp: 728),
  PetLevel(level: 51, expToNext: 33, totalExp: 761),
  PetLevel(level: 52, expToNext: 34, totalExp: 795),
  PetLevel(level: 53, expToNext: 36, totalExp: 831),
  PetLevel(level: 54, expToNext: 37, totalExp: 868),
  PetLevel(level: 55, expToNext: 38, totalExp: 906),
  PetLevel(level: 56, expToNext: 40, totalExp: 946),
  PetLevel(level: 57, expToNext: 41, totalExp: 987),
  PetLevel(level: 58, expToNext: 43, totalExp: 1030),
  PetLevel(level: 59, expToNext: 45, totalExp: 1075),
  PetLevel(level: 60, expToNext: 46, totalExp: 1121),
  PetLevel(level: 61, expToNext: 48, totalExp: 1169),
  PetLevel(level: 62, expToNext: 50, totalExp: 1219),
  PetLevel(level: 63, expToNext: 52, totalExp: 1271),
  PetLevel(level: 64, expToNext: 54, totalExp: 1325),
  PetLevel(level: 65, expToNext: 56, totalExp: 1381),
  PetLevel(level: 66, expToNext: 58, totalExp: 1439),
  PetLevel(level: 67, expToNext: 61, totalExp: 1500),
  PetLevel(level: 68, expToNext: 63, totalExp: 1563),
  PetLevel(level: 69, expToNext: 65, totalExp: 1628),
  PetLevel(level: 70, expToNext: 68, totalExp: 1696),
  PetLevel(level: 71, expToNext: 70, totalExp: 1766),
  PetLevel(level: 72, expToNext: 73, totalExp: 1839),
  PetLevel(level: 73, expToNext: 76, totalExp: 1915),
  PetLevel(level: 74, expToNext: 79, totalExp: 1994),
  PetLevel(level: 75, expToNext: 82, totalExp: 2076),
  PetLevel(level: 76, expToNext: 85, totalExp: 2161),
  PetLevel(level: 77, expToNext: 88, totalExp: 2249),
  PetLevel(level: 78, expToNext: 92, totalExp: 2341),
  PetLevel(level: 79, expToNext: 95, totalExp: 2436),
  PetLevel(level: 80, expToNext: 99, totalExp: 2535),
  PetLevel(level: 81, expToNext: 103, totalExp: 2638),
  PetLevel(level: 82, expToNext: 107, totalExp: 2745),
  PetLevel(level: 83, expToNext: 111, totalExp: 2856),
  PetLevel(level: 84, expToNext: 115, totalExp: 2971),
  PetLevel(level: 85, expToNext: 119, totalExp: 3090),
  PetLevel(level: 86, expToNext: 124, totalExp: 3214),
  PetLevel(level: 87, expToNext: 129, totalExp: 3343),
  PetLevel(level: 88, expToNext: 134, totalExp: 3477),
  PetLevel(level: 89, expToNext: 139, totalExp: 3616),
  PetLevel(level: 90, expToNext: 144, totalExp: 3760),
  PetLevel(level: 91, expToNext: 150, totalExp: 3910),
  PetLevel(level: 92, expToNext: 156, totalExp: 4066),
  PetLevel(level: 93, expToNext: 162, totalExp: 4228),
  PetLevel(level: 94, expToNext: 168, totalExp: 4396),
  PetLevel(level: 95, expToNext: 174, totalExp: 4570),
  PetLevel(level: 96, expToNext: 181, totalExp: 4751),
  PetLevel(level: 97, expToNext: 188, totalExp: 4939),
  PetLevel(level: 98, expToNext: 195, totalExp: 5134),
  PetLevel(level: 99, expToNext: 203, totalExp: 5337),
  PetLevel(level: 100, expToNext: 210, totalExp: 5547),
];

class Users {
  int currentPoint;
  int gotPoint;
  String nowPet;
  Map<String, dynamic> setting;
  

  Users(
    {
      required this.currentPoint,
      required this.gotPoint,
      required this.nowPet,
      required this.setting,
    }
  );

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      currentPoint: map['currentPoint'],
      gotPoint: map['gotPoint'],
      nowPet: map['nowPet'],
      setting: {
        'darkMode': map['setting']['darkMode'],
        'listSort': "사전 순",
        'placeID': "assets/images/prairie.png",
        'push': map['setting']['push'],
        'sound': map['setting']['sound']
      },
    );
  }

  Map<String, dynamic> toMap() => {
    'currentPoint': currentPoint,
    'gotPoint': gotPoint,
    'nowPet': nowPet,
    'setting': setting,
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