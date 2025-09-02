class Pokemon {
  String? nome;
  String? image;
  int? id;

  Pokemon({this.nome, this.image, this.id});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      nome: json['name'],
      image: json['sprites']?['front_default'],
      id: json['id'],
    );
  }
}
