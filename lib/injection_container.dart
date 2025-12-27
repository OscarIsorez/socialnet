import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import 'core/network/network_info.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/fake_auth_remote_datasource.dart';
import 'data/datasources/remote/event_remote_datasource.dart';
import 'data/datasources/remote/fake_event_remote_datasource.dart';
import 'data/datasources/remote/fake_search_remote_datasource.dart';
import 'data/datasources/remote/fake_social_remote_datasource.dart';
import 'data/datasources/remote/search_remote_datasource.dart';
import 'data/datasources/remote/social_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/event_repository_impl.dart';
import 'data/repositories/search_repository_impl.dart';
import 'data/repositories/social_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/event_repository.dart';
import 'domain/repositories/search_repository.dart';
import 'domain/repositories/social_repository.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/events/create_event_usecase.dart';
import 'domain/usecases/events/get_nearby_events_usecase.dart';
import 'domain/usecases/events/get_user_created_events.dart';
import 'domain/usecases/events/update_event_usecase.dart';
import 'domain/usecases/events/verify_event_usecase.dart';
import 'domain/usecases/search/filter_events_usecase.dart';
import 'domain/usecases/search/get_suggested_events_usecase.dart';
import 'domain/usecases/search/search_events_usecase.dart';
import 'domain/usecases/search/search_users_usecase.dart';
import 'domain/usecases/social/get_user_profile.dart';
import 'domain/usecases/social/update_user_profile.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/event/event_bloc.dart';
import 'presentation/bloc/map/map_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/bloc/search/search_bloc.dart';

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

  if (!getIt.isRegistered<SocialRemoteDataSource>()) {
    getIt.registerLazySingleton<SocialRemoteDataSource>(
      FakeSocialRemoteDataSource.new,
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

  if (!getIt.isRegistered<SocialRepository>()) {
    getIt.registerLazySingleton<SocialRepository>(
      () =>
          SocialRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
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

  if (!getIt.isRegistered<GetUserCreatedEvents>()) {
    getIt.registerLazySingleton<GetUserCreatedEvents>(
      () => GetUserCreatedEvents(getIt()),
    );
  }

  if (!getIt.isRegistered<GetUserProfile>()) {
    getIt.registerLazySingleton<GetUserProfile>(() => GetUserProfile(getIt()));
  }

  if (!getIt.isRegistered<UpdateUserProfile>()) {
    getIt.registerLazySingleton<UpdateUserProfile>(
      () => UpdateUserProfile(getIt()),
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

  if (!getIt.isRegistered<ProfileBloc>()) {
    getIt.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getUserProfile: getIt(),
        updateUserProfile: getIt(),
        getUserCreatedEvents: getIt(),
      ),
    );
  }

  // Search
  if (!getIt.isRegistered<SearchRemoteDataSource>()) {
    getIt.registerLazySingleton<SearchRemoteDataSource>(
      FakeSearchRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<SearchRepository>()) {
    getIt.registerLazySingleton<SearchRepository>(
      () =>
          SearchRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
    );
  }

  if (!getIt.isRegistered<SearchEventsUseCase>()) {
    getIt.registerLazySingleton<SearchEventsUseCase>(
      () => SearchEventsUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<SearchUsersUseCase>()) {
    getIt.registerLazySingleton<SearchUsersUseCase>(
      () => SearchUsersUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<FilterEventsUseCase>()) {
    getIt.registerLazySingleton<FilterEventsUseCase>(
      () => FilterEventsUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<GetSuggestedEventsUseCase>()) {
    getIt.registerLazySingleton<GetSuggestedEventsUseCase>(
      () => GetSuggestedEventsUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<SearchBloc>()) {
    getIt.registerFactory<SearchBloc>(
      () => SearchBloc(
        searchEventsUseCase: getIt(),
        searchUsersUseCase: getIt(),
        filterEventsUseCase: getIt(),
        getSuggestedEventsUseCase: getIt(),
      ),
    );
  }
}
