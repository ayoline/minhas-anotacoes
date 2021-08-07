import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';

class AnotacaoHelper {
  static final String nomeTabela = "anotacao";
  static final String colunaId = "id";
  static final String colunaTitulo = "titulo";
  static final String colunaDescricao = "descricao";
  static final String colunaData = "data";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  // ignore: empty_constructor_bodies
  AnotacaoHelper._internal() {}

  get db async {
    Database _db = await inicializarDB();
    return _db;
  }

  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE $nomeTabela ("
        "$colunaId INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$colunaTitulo VARCHAR, "
        "$colunaDescricao TEXT, "
        "$colunaData DATETIME)";
    await db.execute(sql);
  }

  inicializarDB() async {
    final caminhoBancoDados = await getDatabasesPath();

    final localBancoDados =
        caminhoBancoDados.toString() + "banco_minhas_anotacoes.db";

    var db = await openDatabase(
      localBancoDados,
      version: 1,
      onCreate: _onCreate,
    );

    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    var bandoDados = await db;

    int resultado = await bandoDados.insert(nomeTabela, anotacao.toMap());
    return resultado;
  }

  recuperarAnotacoes() async {
    var bandoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY $colunaData DESC ";

    List anotacoes = await bandoDados.rawQuery(sql);
    return anotacoes;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;

    return await bancoDados.update(
      nomeTabela,
      anotacao.toMap(),
      where: "id = ?",
      whereArgs: [anotacao.id],
    );
  }

  Future<int> removerAnotacao(int id) async {
    var bancoDados = await db;
    return await bancoDados.delete(
      nomeTabela,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
