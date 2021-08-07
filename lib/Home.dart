import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:minhas_anotacoes/helper/AnotacaoHelper.dart';
import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>.empty(growable: true);

  _exibirTelaRemover({Anotacao? anotacao}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Remover Anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Deseja realmente remover a Anotação?"),
              ],
            ),
            actions: <Widget>[
              // TextButton utilizado para substituir o widget deprecated FLATBUTTON
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () {
                  _removerAnotacao(anotacao!.id!);
                  Navigator.pop(context);
                },
                child: Text("Remover"),
              ),
            ],
          );
        });
  }

  _exibirTelaCadastro({Anotacao? anotacao}) {
    String textoSalvarAtualizar = "";

    if (anotacao != null) {
      // Atualizando
      _tituloController.text = anotacao.titulo.toString();
      _descricaoController.text = anotacao.descricao.toString();
      textoSalvarAtualizar = "Atualizar";
    } else {
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Adicionar";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$textoSalvarAtualizar anotação"),
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // Define o espaçamento da coluna minimo para exibir o item
            children: <Widget>[
              TextField(
                controller: _tituloController,
                autofocus: true, // para abrir a dialog com o focus nesse campo
                decoration: InputDecoration(
                  labelText: "Título",
                  hintText: "Digite o título...",
                ),
              ),
              TextField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  hintText: "Digite a descrição...",
                ),
              ),
            ],
          ),
          actions: <Widget>[
            // TextButton utilizado para substituir o widget deprecated FLATBUTTON
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                Navigator.pop(context);
              },
              child: Text("$textoSalvarAtualizar"),
            ),
          ],
        );
      },
    );
  }

  _recuperarAnatocacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = List<Anotacao>.empty(growable: true);

    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });
    print("Lista anotações: " + anotacoesRecuperadas.toString());
  }

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelecionada == null) {
      // salva
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
      print("salvar anotação: " + resultado.toString());
    } else {
      // atualiza
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
      print("atualiza anotação: " + resultado.toString());
    }

    _descricaoController.clear();
    _tituloController.clear();

    _recuperarAnatocacoes();
  }

  _formatarData(String data) {
    var formatador = DateFormat("dd/MM/y H:m");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);

    _recuperarAnatocacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnatocacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _anotacoes.length,
              itemBuilder: (context, index) {
                final anotacao = _anotacoes[index];
                return Card(
                  child: ListTile(
                    title: Text("${anotacao.titulo}"),
                    subtitle: Text(
                        "${_formatarData(anotacao.data!)} - ${anotacao.descricao}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            _exibirTelaCadastro(anotacao: anotacao);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _exibirTelaRemover(anotacao: anotacao);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green, // Define a cor do botão Floating
        foregroundColor: Colors.white, // Define a cor do texto do botão
        child: Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    );
  }
}
