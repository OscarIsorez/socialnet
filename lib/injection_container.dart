import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import 'core/network/network_info.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/fake_auth_remote_datasource.dart';
import 'data/datasources/remote/event_remote_datasource.dart';
import 'data/datasources/remote/fake_event_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/event_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/event_repository.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/events/create_event_usecase.dart';
import 'domain/usecases/events/get_nearby_events_usecase.dart';
import 'domain/usecases/events/update_event_usecase.dart';
import 'domain/usecases/events/verify_event_usecase.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/event/event_bloc.dart';
import 'presentation/bloc/map/map_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (!getIt.isRegistered<Connectivity>()) {
    getIt.registerLazySingleton<Connectivity>(Connectivity.new);
  }

  if (!getIt.isRegistered<NetworkInfo>()) {
    getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt.get<Connectivity>()),
    );
  }

  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      FakeAuthRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<EventRemoteDataSource>()) {
    getIt.registerLazySingleton<EventRemoteDataSource>(
      FakeEventRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
    );
  }

  if (!getIt.isRegistered<EventRepository>()) {
    getIt.registerLazySingleton<EventRepository>(
      () =>
          EventRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
    );
  }

  if (!getIt.isRegistered<SignInUseCase>()) {
    getIt.registerLazySingleton<SignInUseCase>(() => SignInUseCase(getIt()));
  }

  if (!getIt.isRegistered<SignUpUseCase>()) {
    getIt.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(getIt()));
  }

  if (!getIt.isRegistered<SignOutUseCase>()) {
    getIt.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(getIt()));
  }

  if (!getIt.isRegistered<GetCurrentUserUseCase>()) {
    getIt.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<CreateEventUseCase>()) {
    getIt.registerLazySingleton<CreateEventUseCase>(
      () => CreateEventUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<GetNearbyEventsUseCase>()) {
    getIt.registerLazySingleton<GetNearbyEventsUseCase>(
      () => GetNearbyEventsUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<UpdateEventUseCase>()) {
    getIt.registerLazySingleton<UpdateEventUseCase>(
      () => UpdateEventUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<VerifyEventUseCase>()) {
    getIt.registerLazySingleton<VerifyEventUseCase>(
      () => VerifyEventUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        signInUseCase: getIt(),
        signUpUseCase: getIt(),
        signOutUseCase: getIt(),
        getCurrentUserUseCase: getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<EventBloc>()) {
    getIt.registerFactory<EventBloc>(
      () => EventBloc(
        createEventUseCase: getIt(),
        updateEventUseCase: getIt(),
        verifyEventUseCase: getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<MapBloc>()) {
    getIt.registerFactory<MapBloc>(
      () => MapBloc(getNearbyEventsUseCase: getIt()),
    );
  }
}
