import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lista_mercado/modelCategoria.dart';
import 'package:lista_mercado/modelProduto.dart';

class SharedPreferencesHelper {
  static const String categoriasKey = 'categorias';
  static const String produtosKeyPrefix = 'produtos_';
  static const String sacolaKey = 'sacola';

  Future<List<Categoria>> getCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriasString = prefs.getString(categoriasKey);
    if (categoriasString != null) {
      final List<dynamic> categoriasJson = jsonDecode(categoriasString);
      return categoriasJson.map((json) => Categoria.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveCategorias(List<Categoria> categorias) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriasJson =
        categorias.map((categoria) => categoria.toJson()).toList();
    prefs.setString(categoriasKey, jsonEncode(categoriasJson));
  }

  Future<List<Produto>> getProdutosByCategoria(int categoriaId) async {
    final prefs = await SharedPreferences.getInstance();
    final produtosString = prefs.getString('$produtosKeyPrefix$categoriaId');
    if (produtosString != null) {
      final List<dynamic> produtosJson = jsonDecode(produtosString);
      return produtosJson.map((json) => Produto.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveProdutos(List<Produto> produtos) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriaId = produtos.isNotEmpty ? produtos.first.categoriaId : -1;
    final produtosJson = produtos.map((produto) => produto.toJson()).toList();
    prefs.setString('$produtosKeyPrefix$categoriaId', jsonEncode(produtosJson));
  }

  Future<List<Produto>> getSacola() async {
    final prefs = await SharedPreferences.getInstance();
    final sacolaString = prefs.getString(sacolaKey);
    if (sacolaString != null) {
      final List<dynamic> sacolaJson = jsonDecode(sacolaString);
      return sacolaJson.map((json) => Produto.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveSacola(List<Produto> sacola) async {
    final prefs = await SharedPreferences.getInstance();
    final sacolaJson = sacola.map((produto) => produto.toJson()).toList();
    prefs.setString(sacolaKey, jsonEncode(sacolaJson));
  }

  Future<void> addToSacola(Produto produto) async {
    final sacola = await getSacola();
    sacola.add(produto);
    await saveSacola(sacola);
  }

  Future<void> removeFromSacola(int produtoId) async {
    final sacola = await getSacola();
    sacola.removeWhere((p) => p.id == produtoId);
    await saveSacola(sacola);
  }

  Future<void> clearSacola() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(sacolaKey);
  }
}
