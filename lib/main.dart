import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'HImV7Cqpv87FD9CRtBfdACdYMhxnDWG53fxwxVrx';
  final keyClientKey = 'WMW3C1WjnbvLzXhqkursByoPlneevA9vSEhbzKrm';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    title: 'Contacts',
    theme: ThemeData(
      primaryColor: Colors.white,
    ),
    home: ContactsApp(),
  ));
}

class ContactsApp extends StatefulWidget {
  const ContactsApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ContactsAppState createState() => _ContactsAppState();
}

class _ContactsAppState extends State<ContactsApp> {
  List<Contact> contacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(contacts[index].name),
            subtitle: Text(contacts[index].phoneNumber),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  contacts.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddContactDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddContactDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String phoneNumber = '';
        String address = '';
        String zipCode = '';
        String birthDay = '';

        return AlertDialog(
          title: const Text('Add Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) {
                  phoneNumber = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (value) {
                  address = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Zip Code'),
                onChanged: (value) {
                  zipCode = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Birthday'),
                onChanged: (value) {
                  birthDay = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  contacts.add(Contact(
                    name: name,
                    phoneNumber: phoneNumber,
                    address: address,
                    zipCode: zipCode,
                    birthDay: birthDay,
                  ));
                });
                // Save the contact to Back4App
                final contact = ParseObject('Contacts');
                contact.set('name', name);
                contact.set('phoneNumber', phoneNumber);
                contact.set('address', address);
                contact.set('zipCode', zipCode);
                contact.set('birthDay', birthDay);

                final ParseResponse parseResponse = await contact.save();
                String? contactId = null; // Initialize contactId to null

                if (parseResponse.success) {
                  contactId =
                      (parseResponse.results!.first as ParseObject).objectId!;
                  print('Object created: $contactId');
                } else {
                  print(
                      'Object created with failed: ${parseResponse.error.toString()}');
                }

                // Save the birthday to Back4App
                if (contactId != null) {
                  final birthday = ParseObject('Birthdays');
                  birthday.set('contactID', contactId);
                  birthday.set('birthDay', birthDay);
                  await birthday.save();
                }

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class Contact {
  final String name;
  final String phoneNumber;
  final String address;
  final String zipCode;
  final String birthDay;

  Contact({
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.zipCode,
    required this.birthDay,
  });
}

class Birthday {
  final String contactId;
  final String birthDay;

  Birthday({
    required this.contactId,
    required this.birthDay,
  });
}
