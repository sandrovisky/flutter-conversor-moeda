import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance/quotations?key=e6f7043f";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: const InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber),
          ))));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  void _realChange(String text) {
    double real = double.parse(text.isEmpty ? "0" : text);
    dolarController.text = (real * dolar).toStringAsFixed(2);
    euroController.text = (real * euro).toStringAsFixed(2);

		

    if (real == 0) {
      _clearAll();
    }
  }

  void _dolarChange(String text) {
    double dolar = double.parse(text.isEmpty ? "0" : text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);

    if (dolar == 0) {
      _clearAll();
    }
  }

  void _euroChange(String text) {
    double euro = double.parse(text.isEmpty ? "0" : text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);

    if (euro == 0) {
      _clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("\$ CONVERSOR \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar dados...",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "R\$  ", realController, _realChange),
                      const Divider(),
                      buildTextField(
                          "Dolar", "US\$  ", dolarController, _dolarChange),
                      const Divider(),
                      buildTextField(
                          "Euros", "€  ", euroController, _euroChange),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController control, Function(String) changeFunc) {
  return TextField(
    controller: control,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    inputFormatters: [CurrencyTextInputFormatter(symbol: "", turnOffGrouping: true)],
    style: const TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: changeFunc,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
