class Categoria {
  int id;
  String nome;
  String descricao;
  String imagem;

  Categoria({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagem,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] ?? 0, // Use um valor padrão se o ID for nulo
      nome: json['nome'],
      descricao: json['descricao'],
      imagem: json['imagem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'imagem': imagem,
    };
  }
}