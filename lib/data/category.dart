class Categories {

  static List<Category> categories = [];

  static int getIdByName(String name){
    for(int i = 0; i< categories.length; ++i){
      if(categories[i].name == name){
        return categories[i].id;
      }
    }
    return 0;
  }
}

class Category {
  int id;
  String name;
  String signature;

  Category({required this.id, required this.name, required this.signature});

  Category.fromJson(Map<dynamic, dynamic> json)
      : id = int.parse(json['category_id']),
        name = json['category_name'],
        signature = json['category_sign'];

}
