import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract interface class ItemRepository {
  Future<List<String>> getItems();
}

class FakeItemRepository implements ItemRepository {
  FakeItemRepository({this.fail = false, this.empty = false});

  bool fail;
  bool empty;

  @override
  Future<List<String>> getItems() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (fail) throw Exception('no connection');
    return empty ? const [] : const ['Apple', 'Banana', 'Cherry'];
  }
}

/// No BuildContext, no mounted — the model takes the repository.
class ListModel extends ChangeNotifier {
  ListModel(this._repo);

  final ItemRepository _repo;
  List<String> items = const [];
  Object? error;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.getItems();
    } on Exception catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ListModel(FakeItemRepository(fail: true))..load(),
      child: const MaterialApp(home: ListScreen()),
    ),
  );
}

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<ListModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: switch (m) {
        ListModel(loading: true) => const Center(
          child: CircularProgressIndicator(),
        ),
        ListModel(error: final Object _) => Center(
          child: FilledButton(onPressed: m.load, child: const Text('Retry')),
        ),
        ListModel(items: []) => const Center(child: Text('Nothing yet')),
        _ => ListView(children: [for (final i in m.items) ListTile(title: Text(i))]),
      },
    );
  }
}
