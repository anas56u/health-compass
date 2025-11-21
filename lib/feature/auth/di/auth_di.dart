import 'package:health_compass/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:health_compass/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:health_compass/feature/auth/domain/repository/auth_repository.dart';
import 'package:health_compass/feature/auth/domain/usecases/login_usecase.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/login_cubit.dart';

class AuthDI {
  // DataSource
  static AuthRemoteDataSource get authRemoteDataSource =>
      AuthRemoteDataSourceImpl();

  // Repository
  static AuthRepository get authRepository =>
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  // UseCases
  static LoginUseCase get loginUseCase => LoginUseCase(authRepository);

  // Cubits
  static LoginCubit get loginCubit => LoginCubit(loginUseCase: loginUseCase);
}
