// ignore_for_file: unused_local_variable, unnecessary_new

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lista_mercado/SharedPreferencesHelper.dart';
import 'package:lista_mercado/main.dart';
import 'package:lista_mercado/modelCategoria.dart';

class AddCategoriaScreen extends StatefulWidget {
  final VoidCallback onSave;

  const AddCategoriaScreen({super.key, required this.onSave});

  @override
  // ignore: library_private_types_in_public_api
  _AddCategoriaScreenState createState() => _AddCategoriaScreenState();
}

class _AddCategoriaScreenState extends State<AddCategoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  File? _image;
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nenhuma imagem selecionada.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao selecionar imagem: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _saveCategoria() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        final categorias = await _prefsHelper.getCategorias();
        final novoId = categorias.isNotEmpty
            ? categorias.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1
            : 1;
        final novaCategoria = Categoria(
          id: novoId,
          nome: _nomeController.text,
          descricao: _descricaoController.text,
          imagem: _image!.path,
        );

        categorias.add(novaCategoria);
        await _prefsHelper.saveCategorias(categorias);

        widget.onSave();
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const MainScreen(),
        )); // Retorna para a tela anterior
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao salvar categoria: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Por favor, preencha todos os campos e selecione uma imagem.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusNode myFocusNode = new FocusNode();

    return LayoutBuilder(builder: ((context, constraints) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 227, 227),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 227, 227, 227),
          centerTitle: true,
          title: const Text('Nova Categoria'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                const SizedBox(
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
                const SizedBox(
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
                                side: const BorderSide(color: Colors.grey),
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
                                color: Color.fromARGB(255, 255, 255, 255),
                                size: 40,
                              ),
                              Text(
                                "Upload Images here",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 253, 253, 253)),
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
                  onPressed: _saveCategoria,
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
    }));
  }
}
