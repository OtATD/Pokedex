import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'pokemon.dart'; // importe sua classe aqui

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 194, 86, 43),
        ),
      ),
      home: const MyHomePage(title: 'Pokedex!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Pokemon> pokemons = [];
  List<Pokemon> filteredPokemons = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Dio dio = Dio();

  int offset = 0;
  bool isLoading = false;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _buscarPokemon();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading) {
        _buscarPokemon();
      }
    });

    _controller.addListener(() {
      _filterPokemons(_controller.text);
    });
  }

  Future<void> _buscarPokemon() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final response = await dio.get(
        'https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$limit',
      );

      final results = response.data['results'] as List;

      final novosPokemons = await Future.wait(
        results.map((element) async {
          final nome = element['name'];
          final detalhes = await dio.get(
            'https://pokeapi.co/api/v2/pokemon/$nome',
          );

          return Pokemon.fromJson(detalhes.data);
        }),
      );

      setState(() {
        pokemons.addAll(novosPokemons);
        filteredPokemons = pokemons;
        offset += limit;
      });
    } catch (e) {
      print("Erro ao buscar pokemons: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterPokemons(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredPokemons = pokemons;
      } else {
        filteredPokemons = pokemons.where((p) {
          final nomeMatch = p.nome?.toLowerCase().contains(lowerQuery) ?? false;
          final idMatch = p.id?.toString() == lowerQuery;
          return nomeMatch || idMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: TextField(
          controller: _controller,
          onChanged: _filterPokemons,
          decoration: const InputDecoration(
            hintText: "Buscar por nome ou número...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: filteredPokemons.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: filteredPokemons.length + 1,
                itemBuilder: (context, index) {
                  if (index < filteredPokemons.length) {
                    final poke = filteredPokemons[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            poke.image ??
                                'https://via.placeholder.com/50', // fallback
                          ),
                          radius: 25,
                        ),
                        title: Text(
                          "Nº ${poke.id} - ${poke.nome?.toUpperCase()}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else {
                    return isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }
                },
              ),
      ),
    );
  }
}
