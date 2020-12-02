import 'dart:io';

import 'package:contatos_flutter/helpers/Contact_helper.dart';
import 'package:flutter/material.dart';

import 'package:contatos_flutter/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOption {orderaz, orderza};

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState(){
    super.initState();
    _getAllContacts();
  }

  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          itemBuilder: (context, index){
            return _contactCard(context, index);
          },
          itemCount: contacts.length,
          padding: EdgeInsets.all(10.0),
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      onTap: (){
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ? FileImage(File(contacts[index].img)) : AssetImage("images/person.png")
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contacts[index].name ?? "Sem nome",
                      style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(contacts[index].email ?? "Sem email",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(contacts[index].phone ?? "Sem telefone",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  void _showOptions(BuildContext ctx, int index) async {
    showModalBottomSheet(
      context: ctx,
      builder: (context){
        return BottomSheet(
          onClosing: (){

          },
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child:
                    FlatButton(
                      child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: (){
                        launch("tel:${contacts[index].phone}");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child:
                    FlatButton(
                      child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: (){
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child:
                    FlatButton(
                      child: Text("Exluir", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: (){
                        helper.deleteContact(contacts[index].id);
                        Navigator.pop(context);
                        _getAllContacts();
                      },
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
    );
    if(recContact!=null){
      if(contact != null){
        await helper.updateContact(recContact);
      }else{
        recContact.id = await helper.getNumber()+1;
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }
}
