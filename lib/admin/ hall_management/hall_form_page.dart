import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HallFormPage extends StatefulWidget {
  final String? docId;
  final dynamic data;

  const HallFormPage({super.key, this.docId, this.data});

  @override
  State<HallFormPage> createState() => _HallFormPageState();
}

class _HallFormPageState extends State<HallFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController name, capacity, location, price;
  bool available = true;

  @override
  void initState() {
    name = TextEditingController(text: widget.data?['name'] ?? '');
    capacity =
        TextEditingController(text: widget.data?['capacity']?.toString() ?? '');
    location =
        TextEditingController(text: widget.data?['location'] ?? '');
    price =
        TextEditingController(text: widget.data?['pricePerHour']?.toString() ?? '');
    available = widget.data?['available'] ?? true;
    super.initState();
  }

  void saveHall() {
    final data = {
      'name': name.text,
      'capacity': int.parse(capacity.text),
      'location': location.text,
      'pricePerHour': double.parse(price.text),
      'available': available,
    };

    if (widget.docId == null) {
      FirebaseFirestore.instance.collection('halls').add(data);
    } else {
      FirebaseFirestore.instance
          .collection('halls')
          .doc(widget.docId)
          .update(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hall Form')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Hall Name')),
              TextFormField(controller: capacity, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number),
              TextFormField(controller: location, decoration: const InputDecoration(labelText: 'Location')),
              TextFormField(controller: price, decoration: const InputDecoration(labelText: 'Price Per Hour'), keyboardType: TextInputType.number),
              SwitchListTile(
                title: const Text('Available'),
                value: available,
                onChanged: (v) => setState(() => available = v),
              ),
              ElevatedButton(onPressed: saveHall, child: const Text('SAVE')),
            ],
          ),
        ),
      ),
    );
  }
}
