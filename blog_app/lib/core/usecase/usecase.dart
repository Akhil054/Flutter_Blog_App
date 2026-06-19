import 'package:blog_app/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// usecase inferface created
/// Doing only one task..
abstract interface class UseCase<SucessType, Params>{
  Future<Either<Failure,SucessType>> call(Params params);
  
}