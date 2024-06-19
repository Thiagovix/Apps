// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lista_mercado/SharedPreferencesHelper.dart';
import 'package:lista_mercado/modelProduto.dart';

class SacolaScreen extends StatefulWidget {
  const SacolaScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SacolaScreenState createState() => _SacolaScreenState();
}

class _SacolaScreenState extends State<SacolaScreen> {
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();
  List<Produto> _sacola = [];

  @override
  void initState() {
    super.initState();
    _refreshSacola();
  }

  Future<void> _refreshSacola() async {
    final sacola = await _prefsHelper.getSacola();
    setState(() {
      _sacola = sacola;
    });
  }

  Future<void> _removeFromSacola(int produtoId) async {
    await _prefsHelper.removeFromSacola(produtoId);
    _refreshSacola();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(milliseconds: 300),
        content: Text('Produto removido da sacola'),
        backgroundColor: Colors.red,
      ),
    );
  }

  double _calcularTotal() {
    return _sacola.fold(0, (sum, item) => sum + item.preco);
  }

  Future<void> _finalizarCompra() async {
    double total = _calcularTotal();

    if (_sacola.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione itens à sacola antes de finalizar a compra.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostra o resultado da compra
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 227, 227, 227),
          title: const Text(
            'Compra Finalizada',
          ),
          content: Text(
            'O total da sua compra é R\$ ${total.toStringAsFixed(2)}',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // Cor de fundo do botão
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _limparSacola(); // Limpa a sacola ao fechar o dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _limparSacola() async {
    await _prefsHelper
        .clearSacola(); // Limpa a sacola no SharedPreferencesHelper
    _refreshSacola(); // Atualiza a lista após limpar a sacola
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 227, 227),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 227, 227, 227),
        centerTitle: true,
        title: const Text('Sacola'),
      ),
      body: _sacola.isEmpty
          ? const Center(
              child: Text("Sacola Vazia"),
            )
          : ListView.builder(
              itemCount: _sacola.length,
              itemBuilder: (context, index) {
                final produto = _sacola[index];
                return Dismissible(
                  key: UniqueKey(), // Chave única para o Dismissible
                  direction: DismissDirection
                      .endToStart, // Direção do deslize para excluir da direita para a esquerda
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    // Confirma a ação de dismiss
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmar"),
                          content:
                              const Text("Deseja remover este item da sacola?"),
                          backgroundColor: const Color.fromARGB(255, 255, 255,
                              255), // Cor de fundo do AlertDialog
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(false), // Cancela a exclusão
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.green, // Cor de fundo do botão
                              ),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(true), // Confirma a exclusão
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.red, // Cor de fundo do botão
                              ),
                              child: const Text("Confirmar"),
                            ),
                          ],
                        );
                      },
                    );
                  },

                  onDismissed: (DismissDirection direction) {
                    // Executa ação ao completar o dismiss (excluir)
                    _removeFromSacola(produto.id);
                  },
                  child: Card(
                    child: ListTile(
                      leading: produto.imagem.isNotEmpty
                          ? Image.file(File(produto.imagem))
                          : null,
                      title: Text(produto.nome),
                      subtitle: Text(
                          'Descrição: ${produto.descricao}\nPreço: R\$ ${produto.preco.toStringAsFixed(2)}'),
                      trailing:
                          const Icon(Icons.drag_handle), // Ícone para arrastar
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _sacola.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _finalizarCompra,
              label: const Text(
                'Finalizar Compra',
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              backgroundColor: Colors.green,
            )
          : null, // Mostra o botão apenas se a sacola não estiver vazia
    );
  }
}



// // ignore_for_file: use_build_context_synchronously

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:lista_mercado/SharedPreferencesHelper.dart';
// import 'package:lista_mercado/modelProduto.dart';

// class SacolaScreen extends StatefulWidget {
//   const SacolaScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _SacolaScreenState createState() => _SacolaScreenState();
// }

// class _SacolaScreenState extends State<SacolaScreen> {
//   final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();
//   List<Produto> _sacola = [];

//   @override
//   void initState() {
//     super.initState();
//     _refreshSacola();
//   }

//   Future<void> _refreshSacola() async {
//     final sacola = await _prefsHelper.getSacola();
//     setState(() {
//       _sacola = sacola;
//     });
//   }

//   Future<void> _removeFromSacola(int produtoId) async {
//     await _prefsHelper.removeFromSacola(produtoId);
//     _refreshSacola();
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       duration: Duration(milliseconds: 300),
//       content: Text('Produto removido da sacola'),
//       backgroundColor: Colors.red,
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: const Color.fromARGB(255, 227, 227, 227),
//         appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 227, 227, 227),
//           centerTitle: true,
//           title: const Text('Sacola'),
//         ),
//         body: _sacola.isNotEmpty
//             ? ListView.builder(
//                 itemCount: _sacola.length,
//                 itemBuilder: (context, index) {
//                   final produto = _sacola[index];
//                   return Card(
//                     child: ListTile(
//                       leading: produto.imagem.isNotEmpty
//                           ? Image.file(File(produto.imagem))
//                           : null,
//                       title: Text(produto.nome),
//                       subtitle: Text(
//                           'Descrição: ${produto.descricao}\nPreço: R\$ ${produto.preco.toStringAsFixed(2)}'),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.remove_shopping_cart),
//                         onPressed: () => _removeFromSacola(produto.id),
//                       ),
//                     ),
//                   );
//                 },
//               )
//             : const Center(
//                 child: Text("Sacola Vazia"),
//               ));
//   }
// }
