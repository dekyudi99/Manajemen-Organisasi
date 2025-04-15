import 'package:flutter/material.dart';
import 'package:manajemen_organisasi/models/person.dart';
import 'package:manajemen_organisasi/services/api.dart';
import 'package:manajemen_organisasi/pages/formPerson.dart';

class ListPerson extends StatefulWidget {
  const ListPerson({Key? key}) : super(key: key);

  @override
  State<ListPerson> createState() => _ListPersonState();
}

class _ListPersonState extends State<ListPerson> {
  final PersonService _personService = PersonService();
  late Future<List<Person>> _futurePersons;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _futurePersons = _personService.fetchPersons();
    });
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final success = await _personService.deletePerson(id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToForm(BuildContext context, {Person? person}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonFormPage(person: person),
      ),
    );

    if (result == true) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Aduan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<Person>>(
                    future: _futurePersons,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Gagal memuat data',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshData,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Tidak ada data',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      final persons = snapshot.data!
                          .where((person) =>
                              person.titleIssues.toLowerCase().contains(_searchQuery) ||
                              person.descriptionIssues.toLowerCase().contains(_searchQuery) ||
                              person.nim.toLowerCase().contains(_searchQuery))
                          .toList();

                      if (persons.isEmpty) {
                        return const Center(
                          child: Text('Tidak ditemukan data yang sesuai'),
                        );
                      }

                      return ListView.builder(
                        itemCount: persons.length,
                        itemBuilder: (context, index) {
                          final person = persons[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  person.imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            person.imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image, size: 60),
                                          ),
                                        )
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.image, size: 40),
                                        ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          person.titleIssues,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          person.descriptionIssues,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text('${person.rating}'),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                person.divisionDepartmentName,
                                                style: const TextStyle(color: Colors.blue),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'NIM: ${person.nim}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () =>
                                            _navigateToForm(context, person: person),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () =>
                                            _confirmDelete(person.idCustomerService),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}