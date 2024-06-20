import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lista_mercado/SharedPreferencesHelper.dart';
import 'package:lista_mercado/modelProduto.dart';

class AddProdutoScreen extends StatefulWidget {
  final int categoriaId;
  final VoidCallback onSave;

  AddProdutoScreen({required this.categoriaId, required this.onSave});

  @override
  _AddProdutoScreenState createState() => _AddProdutoScreenState();
}

class _AddProdutoScreenState extends State<AddProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  File? _image;
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduto() async {
    if (_formKey.currentState!.validate() && _image != null) {
      final produtos =
          await _prefsHelper.getProdutosByCategoria(widget.categoriaId);
      final novoId = produtos.isNotEmpty
          ? produtos.map((p) => p.id).reduce((a, b) => a > b ? a : b) +
              1 +
              widget.categoriaId
          : 1;
      final novoProduto = Produto(
        id: novoId,
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        preco: double.parse(_precoController.text),
        imagem: _image!.path,
        categoriaId: widget.categoriaId,
      );

      produtos.add(novoProduto);
      await _prefsHelper.saveProdutos(produtos);

      widget.onSave();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 227, 227),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 227, 227, 227),
          title: const Text('Adicionar Produto'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    floatingLabelStyle: TextStyle(
                      color: Color.fromARGB(255, 94, 196, 1),
                    ),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 94, 196, 1),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    floatingLabelStyle: TextStyle(
                      color: Color.fromARGB(255, 94, 196, 1),
                    ),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 94, 196, 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                    floatingLabelStyle: TextStyle(
                      color: Color.fromARGB(255, 94, 196, 1),
                    ),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 94, 196, 1),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o preço';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                const SizedBox(height: 16.0),
                _image == null
                    ? SizedBox(
                        width: 300,
                        height: 200,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                          onPressed: _pickImage,
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: Color.fromARGB(255, 55, 71, 79),
                                size: 40,
                              ),
                              Text(
                                "Upload Images here",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 55, 71, 79)),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey),
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveProduto,
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(
                      ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 94, 196, 1),
                    ),
                  ),
                  child: const Stack(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          color: Colors.white,
                          Icons.shopping_bag_outlined,
                          size: 20,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Salvar', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
