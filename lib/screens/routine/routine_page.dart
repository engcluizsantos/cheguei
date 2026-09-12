import 'package:flutter/material.dart';
import 'package:cheguei/models/travel_routine_model.dart';
import 'package:cheguei/services/storage/storage_service.dart';
import 'package:cheguei/services/notifications/notification_service.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  TimeOfDay departureTime = const TimeOfDay(hour: 8, minute: 0);

  int minutesBefore = 60;
  bool routineEnabled = true;
  String selectedRoutineType = 'Trabalho';
  String? selectedDestination;

  void loadDestinationForRoutineType() {
    switch (selectedRoutineType) {
      case 'Casa':
        selectedDestination = StorageService.getHomeAddress();
        break;

      case 'Trabalho':
        selectedDestination = StorageService.getWorkAddress();
        break;

      case 'Faculdade':
        selectedDestination = StorageService.getCollegeAddress();
        break;
    }
  }

  final Set<int> selectedWeekdays = {
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  };

  Future<void> selectDepartureTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: departureTime,
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      departureTime = selectedTime;
    });
  }

  Future<void> saveRoutine() async {
    final destination = selectedDestination;

    if (destination == null || destination.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cadastre primeiro o endereço de $selectedRoutineType.',
          ),
        ),
      );
      return;
    }

    if (selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um dia da semana.')),
      );
      return;
    }

    final weekdays = selectedWeekdays.toList()..sort();

    final routine = TravelRoutineModel(
      name: selectedRoutineType,
      destination: destination,
      departureHour: departureTime.hour,
      departureMinute: departureTime.minute,
      minutesBefore: minutesBefore,
      weekdays: weekdays,
      enabled: routineEnabled,
    );

    await StorageService.saveTravelRoutine(routine);

    await NotificationService.scheduleTravelRoutine(routine);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rotina de $selectedRoutineType salva com sucesso.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rotinas'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de rotina',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedRoutineType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.route),
              ),
              items: const [
                DropdownMenuItem(value: 'Casa', child: Text('Casa')),
                DropdownMenuItem(value: 'Trabalho', child: Text('Trabalho')),
                DropdownMenuItem(value: 'Faculdade', child: Text('Faculdade')),
              ],

              //SELETOR
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedRoutineType = value;
                  loadDestinationForRoutineType();
                  loadSavedRoutine();
                });
              },
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedDestination?.trim().isNotEmpty == true
                          ? selectedDestination!
                          : 'Endereço não cadastrado',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Horário habitual de saída',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(
                departureTime.format(context),
                style: const TextStyle(fontSize: 18),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: selectDepartureTime,
            ),

            const SizedBox(height: 24),

            const Text(
              'Antecedência da notificação',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              initialValue: minutesBefore,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notifications_active),
              ),
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 minutos antes')),
                DropdownMenuItem(value: 30, child: Text('30 minutos antes')),
                DropdownMenuItem(value: 45, child: Text('45 minutos antes')),
                DropdownMenuItem(value: 60, child: Text('1 hora antes')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  minutesBefore = value;
                });
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Dias da semana',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    (DateTime.monday, 'Seg'),
                    (DateTime.tuesday, 'Ter'),
                    (DateTime.wednesday, 'Qua'),
                    (DateTime.thursday, 'Qui'),
                    (DateTime.friday, 'Sex'),
                    (DateTime.saturday, 'Sáb'),
                    (DateTime.sunday, 'Dom'),
                  ].map((day) {
                    return FilterChip(
                      label: Text(day.$2),
                      selected: selectedWeekdays.contains(day.$1),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedWeekdays.add(day.$1);
                          } else {
                            selectedWeekdays.remove(day.$1);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Rotina ativa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'O Cheguei poderá enviar lembretes antes do deslocamento.',
              ),
              value: routineEnabled,
              onChanged: (value) {
                setState(() {
                  routineEnabled = value;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveRoutine,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loadSavedRoutine() {
    final routines = StorageService.getTravelRoutines();

    TravelRoutineModel? savedRoutine;

    for (final routine in routines) {
      if (routine.name == selectedRoutineType) {
        savedRoutine = routine;
        break;
      }
    }

    if (savedRoutine == null) {
      departureTime = const TimeOfDay(hour: 8, minute: 0);

      minutesBefore = 60;

      selectedWeekdays
        ..clear()
        ..addAll({
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        });

      routineEnabled = true;

      return;
    }

    departureTime = TimeOfDay(
      hour: savedRoutine.departureHour,
      minute: savedRoutine.departureMinute,
    );

    minutesBefore = savedRoutine.minutesBefore;

    selectedWeekdays
      ..clear()
      ..addAll(savedRoutine.weekdays);

    routineEnabled = savedRoutine.enabled;
  }

  @override
  void initState() {
    super.initState();

    loadDestinationForRoutineType();
    loadSavedRoutine();
  }
}
