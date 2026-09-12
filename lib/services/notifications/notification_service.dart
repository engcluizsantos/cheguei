import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cheguei/models/travel_routine_model.dart';

class NotificationService {

  static int _routineNotificationBaseId(String routineName) {
  switch (routineName) {
    case 'Casa':
      return 1000;

    case 'Trabalho':
      return 2000;

    case 'Faculdade':
      return 3000;

    default:
      return 4000;
  }
}

  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: initializationSettings);
  }

  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'cheguei_test_channel',
      'Notificações de teste',
      channelDescription:
          'Canal utilizado para testar as notificações do Cheguei.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: 1,
      title: 'Cheguei',
      body: 'Sua primeira notificação do Cheguei está funcionando! 🚀',
      notificationDetails: notificationDetails,
    );
  }

  static Future<void> scheduleTestNotification() async {
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(minutes: 1));

    const androidDetails = AndroidNotificationDetails(
      'cheguei_scheduled_channel',
      'Notificações agendadas',
      channelDescription:
          'Canal utilizado para notificações agendadas do Cheguei.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id: 2,
      title: 'Cheguei',
      body: 'Hora de se preparar para o seu deslocamento! 🚍',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> scheduleTravelRoutine(TravelRoutineModel routine) async {
    await cancelTravelRoutineNotifications(routine.name);

    if (!routine.enabled) {
      return;
    }

    final baseId = _routineNotificationBaseId(routine.name);

    for (final weekday in routine.weekdays) {
      final departure = _nextWeekdayTime(
        weekday: weekday,
        hour: routine.departureHour,
        minute: routine.departureMinute,
      );

      final scheduledDate = departure.subtract(
        Duration(minutes: routine.minutesBefore),
      );

      const androidDetails = AndroidNotificationDetails(
        'cheguei_routine_channel',
        'Rotinas de deslocamento',
        channelDescription:
            'Lembretes recorrentes para rotinas de deslocamento.',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        id: baseId + weekday,
        title: 'Cheguei',
        body:
            'Seu deslocamento para ${routine.name} está se aproximando. Destino: ${routine.destination}',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static tz.TZDateTime _nextWeekdayTime({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != weekday || !scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> cancelTravelRoutineNotifications(
  String routineName,
) async {
  final baseId = _routineNotificationBaseId(routineName);

  for (var weekday = DateTime.monday;
      weekday <= DateTime.sunday;
      weekday++) {
    await _notifications.cancel(
      id: baseId + weekday,
    );
  }
}
}
