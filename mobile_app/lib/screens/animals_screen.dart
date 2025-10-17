import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/animals_provider.dart';
import '../providers/notifications_provider.dart';
import '../models/animal.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecies = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimalsProvider>().fetchAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Животные'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAnimalDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotificationsDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: Consumer<AnimalsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ошибка: ${provider.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchAnimals(),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.animals.isEmpty) {
                  return const Center(
                    child: Text('Животные не найдены'),
                  );
                }

                return ListView.builder(
                  itemCount: provider.animals.length,
                  itemBuilder: (context, index) {
                    final animal = provider.animals[index];
                    return _buildAnimalCard(animal);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Поиск животных...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              context.read<AnimalsProvider>().fetchAnimals(
                search: value,
                species: _selectedSpecies,
              );
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedSpecies.isEmpty ? null : _selectedSpecies,
            decoration: const InputDecoration(
              labelText: 'Вид животного',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: '', child: Text('Все')),
              DropdownMenuItem(value: 'dog', child: Text('Собаки')),
              DropdownMenuItem(value: 'cat', child: Text('Кошки')),
              DropdownMenuItem(value: 'bird', child: Text('Птицы')),
              DropdownMenuItem(value: 'rabbit', child: Text('Кролики')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSpecies = value ?? '';
              });
              context.read<AnimalsProvider>().fetchAnimals(
                search: _searchController.text,
                species: _selectedSpecies,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(Animal animal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    animal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(animal.species),
                  backgroundColor: Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Возраст: ${animal.age}'),
            Text('Пол: ${animal.gender}'),
            if (animal.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(animal.description),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  animal.isAdopted ? 'Усыновлен' : 'Доступен для усыновления',
                  style: TextStyle(
                    color: animal.isAdopted ? Colors.grey : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!animal.isAdopted)
                  ElevatedButton(
                    onPressed: () => _adoptAnimal(animal),
                    child: const Text('Усыновить'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adoptAnimal(Animal animal) async {
    // Показываем диалог для ввода данных усыновителя
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _AdoptionDialog(),
    );

    if (result != null) {
      final provider = context.read<AnimalsProvider>();
      final notificationProvider = context.read<NotificationsProvider>();
      
      final success = await provider.adoptAnimal(
        animalId: animal.id,
        adopterName: result['name']!,
        adopterEmail: result['email']!,
        adopterPhone: result['phone']!,
      );
      
      if (success) {
        // Отправляем уведомление об усыновлении
        await notificationProvider.sendNotification(
          title: 'Усыновление',
          message: 
              '${animal.name} был успешно усыновлен пользователем ${result['name']}!',
          type: 'success',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${animal.name} успешно усыновлен!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при усыновлении ${animal.name}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showAddAnimalDialog() async {
    final nameController = TextEditingController();
    final speciesController = TextEditingController();
    final ageController = TextEditingController();
    final genderController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить животное'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              TextField(
                controller: speciesController,
                decoration: const InputDecoration(labelText: 'Вид'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Возраст'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: 'Пол'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<AnimalsProvider>();
              final notificationProvider = 
                  context.read<NotificationsProvider>();
              
              final success = await provider.addAnimal(
                name: nameController.text,
                species: speciesController.text,
                age: int.tryParse(ageController.text) ?? 0,
                description: descriptionController.text,
                gender: genderController.text,
              );
              
              if (success) {
                try {
                  await notificationProvider.sendNotification(
                    title: 'Новое животное',
                    message: 
                        'Добавлено новое животное: ${nameController.text}',
                    type: 'info',
                  );
                } catch (e) {
                  debugPrint('Ошибка отправки уведомления: $e');
                  // Не блокируем добавление животного из-за ошибки уведомления
                }
              }
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                        ? 'Животное добавлено!' 
                        : 'Ошибка при добавлении'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNotificationsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Уведомления'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Consumer<NotificationsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.notifications.isEmpty) {
                return const Center(child: Text('Нет уведомлений'));
              }

              return ListView.builder(
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.message),
                    trailing: Text(
                      '${notification.createdAt.day}/${notification.createdAt.month}',
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => 
                context.read<NotificationsProvider>().fetchNotifications(),
            child: const Text('Обновить'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _AdoptionDialog extends StatefulWidget {
  const _AdoptionDialog();

  @override
  _AdoptionDialogState createState() => _AdoptionDialogState();
}

class _AdoptionDialogState extends State<_AdoptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Данные усыновителя'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите имя';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите email';
                }
                if (!value.contains('@')) {
                  return 'Введите корректный email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите телефон';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'email': _emailController.text,
                'phone': _phoneController.text,
              });
            }
          },
          child: const Text('Усыновить'),
        ),
      ],
    );
  }
}