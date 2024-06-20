import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lista_mercado/SharedPreferencesHelper.dart';
import 'package:lista_mercado/modelProduto.dart';
import 'package:lista_mercado/addProdutoScreen.dart';

class ProdutoScreen extends StatefulWidget {
  final int categoriaId;
  final String categoriaNome;

  ProdutoScreen({required this.categoriaId, required this.categoriaNome});

  @override
  _ProdutoScreenState createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();
  List<Produto> _produtos = [];

  @override
  void initState() {
    super.initState();
    _refreshProdutos();
  }

  Future<void> _refreshProdutos() async {
    final produtos =
        await _prefsHelper.getProdutosByCategoria(widget.categoriaId);
    setState(() {
      _produtos = produtos;
    });
  }

  Future<void> _addProduto() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddProdutoScreen(
          categoriaId: widget.categoriaId,
          onSave: _refreshProdutos,
        ),
      ),
    );
  }

  Future<void> _addToSacola(Produto produto) async {
    await _prefsHelper.addToSacola(produto);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 300),
      content: Text('${produto.nome} adicionado à sacola'),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 227, 227),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 227, 227, 227),
          title: Text(widget.categoriaNome),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addProduto,
            ),
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Número de colunas
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.8, // Ajuste conforme necessário
          ),
          itemCount: _produtos.length,
          itemBuilder: (context, index) {
            final produto = _produtos[index];
            return SizedBox(
              child: Card(
                shadowColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 110,
                      child: produto.imagem.isNotEmpty
                          ? Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                image: DecorationImage(
                                  image: FileImage(File(produto.imagem)),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : Container(), // Adicione um Container vazio se não houver imagem
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        produto.nome,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'R\$ ${produto.preco.toStringAsFixed(2)}',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: SizedBox(
                        child: ElevatedButton(
                          onPressed: () => _addToSacola(produto),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 94, 196, 1),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(
                                  width:
                                      8), // Espaçamento entre o ícone e o texto
                              Text(
                                'Add to Bag',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }));
  }
}
