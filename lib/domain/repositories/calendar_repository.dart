import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/calendar_activity.dart';

abstract class CalendarRepository {
  Future<Either<Failure, List<CalendarActivity>>> getActivities(String userId);

  Future<Either<Failure, CalendarActivity>> createActivity(
    CalendarActivity activity,
  );

  Future<Either<Failure, void>> inviteToActivity(
    String activityId,
    List<String> invitedUserIds,
  );

  Future<Either<Failure, List<String>>> getAvailableFriends(
    String userId,
    DateTime slot,
  );

  Future<Either<Failure, void>> syncCalendar(String userId);
}
