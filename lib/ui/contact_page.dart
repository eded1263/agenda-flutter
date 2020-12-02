import 'dart:io';

import 'package:contatos_flutter/helpers/Contact_helper.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  bool _userEdited = false;
  Contact _editedContact;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();


  @override
  void initState(){
    super.initState();
    if(widget.contact == null){
      _editedContact = Contact();
    }else{
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;

    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(_editedContact.name == null || _editedContact.name == '' ? "Novo contato" : _editedContact.name),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(_editedContact.name != null && _editedContact.name.isNotEmpty){
            Navigator.pop(context, _editedContact);
          }else{
            FocusScope.of(context).requestFocus(_nameFocus);
          }
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  ImagePicker ip = ImagePicker();
                  ip.getImage(source: ImageSource.camera).then((file){
                    if(file == null){
                      return;
                    }
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null ? FileImage(File(_editedContact.img)) : AssetImage("images/person.png")
                      )
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
                decoration: InputDecoration(
                    labelText: "Nome"
                ),
              ),
              TextField(
                controller: _emailController,
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.email = text;
                },
                decoration: InputDecoration(
                    labelText: "Email"
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                decoration: InputDecoration(
                    labelText: "Telefone"
                ),
              )
            ],
          )
      ),
    ), onWillPop: _requestPop);
  }

  Future<bool> _requestPop() async{
    if(_userEdited){
      showDialog(context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Descartar Alterações?"),
          content: Text("Se sair, todas as mudanças serão perdidas!"),
          actions: <Widget>[
            FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancelar")
            ),
            FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Sim")
            )
          ],
        );
      });
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }
}
