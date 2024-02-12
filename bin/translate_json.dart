import 'package:translate_json/translate_json.dart' as translate_json;
import 'dart:io';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:args/args.dart';
import 'package:translator/translator.dart';
import 'package:cli_util/cli_logging.dart' show Logger;
import 'package:interact/interact.dart';

final GoogleTranslator translator = GoogleTranslator();

// Translates the input String to specified language
Future<String> translate(
  String sourceText, {
  String to = 'en',
}) async {
  String translation = await translator
      .translate(sourceText, to: to)
      .then((value) => value.text);
  return translation;
}

void main(List<String> arguments) async {
  
  var argParser = ArgParser();
  argParser
    ..addFlag('verbose', abbr: 'v')
    ..addFlag('replace', abbr: 'r')
    ..addFlag('pretty-print', abbr: 'p')
    ..addOption('source-language', abbr: 's')
    ..addOption('output-dir', abbr: 'o');

  var parsedArgs = argParser.parse(arguments);

  var logger = parsedArgs['verbose'] ? Logger.verbose() : Logger.standard();

  if(parsedArgs.rest.isEmpty) {
    logger.stderr('❗ You need to provide the path to the file.');
    exit(-1);
  }
  
  File inputFile = File(parsedArgs.rest[0]);

  if(!inputFile.existsSync()) {
    logger.stderr('❗The source file does not exist.');
    exit(-1);
  }

  if(parsedArgs.rest.length < 2) {
    logger.stderr('❗You need to provide the language to translate to as the second argument.');
    exit(-1);
  }

  String targetLanguage = parsedArgs.rest[1];
  
  late Directory outputDir;
  if(parsedArgs['output-dir'] != null) {
    outputDir = Directory(parsedArgs['output-dir']);
    if(!outputDir.existsSync()){
      logger.stderr('❗The output directory does not exist');
      exit(-1);
    }
  } else {
    outputDir = Directory.current;
  }

  File outputFile = File('${outputDir.path}/$targetLanguage.json');

  if(outputFile.existsSync() && !parsedArgs['replace']) {
    logger.stderr('The destination file already exists');
  }

  String input = inputFile.readAsStringSync();
  Map<String, String> table = {};
  
  var uuid = Uuid();
  Map<String,dynamic> json = jsonDecode(input, reviver: (k, v) {
    if(v is String){
      String key = uuid.v4();
      table[key] = v;
      return key;
    }
    return v;
  });

  String temp = jsonEncode(json);

  final progress = Progress(
    length: table.keys.length,
    //size: 0.5, // optional, will be 1 by default
    rightPrompt: (current) => ' ${current.toString().padLeft(3)}/${table.keys.length}',
  ).interact();

  for(var key in table.keys) {
    table[key] = await translate(table[key]!, to: targetLanguage);
    progress.increase(1);
  }

  progress.done();

  Map<String,dynamic> translated = jsonDecode(temp, reviver: (k, v) {
    if(v is String){      
      return table[v] ?? v;
    }
    return v;
  });

  var encoder = parsedArgs['pretty-print'] ? JsonEncoder.withIndent("     ") : JsonEncoder();
  
  outputFile.writeAsStringSync(encoder.convert(translated));

  logger.stdout('✅ All done. Translated ${table.keys.length} phrases.');

}
