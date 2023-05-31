import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key, this.contact});

  final Contact? contact;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  //craindo focos para os TextFields
  final _nameFocus = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  bool _userEdited = false;
  late Contact _editedContact;

  @override
  void initState() {
    super.initState();
    //para acessar o atributo da outra classe, coloque widget - que é o ContactPage -  e o atributo
    if (widget.contact == null) {
      //se não passou nenhum contato para editar, cria um novo contato
      _editedContact = Contact();
    } else {
      //transforma o contato que passou para a página em um mapa e criando um novo contato através desse mapa
      _editedContact = Contact.fromMap(
          widget.contact!.toMap()); //fazendo cópia do contato existente
      _nameController.text = _editedContact.name!;
      _emailController.text = _editedContact.email ?? ''; //se for null, então passa string vazia
      _phoneController.text = _editedContact.phone ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //chama uma função quando der um pop antes de sair da tela
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          //se for um novo contato, aparece 'novo contato', senão vai aparecer o próprio nome
          title: Text(_editedContact.name ?? 'Novo Contato'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name != null &&
                _editedContact.name!.isNotEmpty) {
              Navigator.pop(context,
                  _editedContact); //retorna para a tela anterior e retorna o contato editado
            } else {
              //quando clicar em salvar e estiver vazio, vai focar o campo vazio
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  //executa o código, abre a cêmera e espera tirar a foto
                  _imagePicker.pickImage(source: ImageSource.camera).then((file) {
                    //Se o usuário abriu e fechou a câmera sem tirar a foto, somente retorna
                    if(file == null) return;
                    //caso contrário, pega o caminho da foto
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _editedContact.img != null
                            ? FileImage(File(_editedContact.img!))
                            : const AssetImage('images/person.png') as ImageProvider),
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (text) {
                  _userEdited = true; //indica que mudou algo
                  setState(() {
                    //setState para mudar o nome na appbar
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (text) {
                  _userEdited = true; //indica que mudou algo
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                onChanged: (text) {
                  _userEdited = true; //indica que mudou algo
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) { //se usuário digitou
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Descartar Alterações?'),
            content: const Text('Se sair, as alterações serão perdidas.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); //pop para remover o diálogo
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); //pop para remover o diálogo
                  Navigator.pop(context); //pop para sair da tela de contato
                },
                child: const Text('Sim'),
              ),
            ],
          );
        },
      );
      return Future.value(false); //retorna para o WillPopScope que NÃO pode sair da tela automaticamente
    }else{
      return Future.value(true); //retorna para o WillPopScope que pode sair da tela automaticamente
    }
  }
}