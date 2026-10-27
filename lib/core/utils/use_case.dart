import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

// Abstract class (عقد) لكل Use Case في التطبيق
// كل UseCase بيأخذ Params ويرجع إما Failure أو Output
// Either<Failure, Output> معناها: أو خطأ أو نجاح - مش هيرجع null أبداً
abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

// كلاس فارغ بيُستخدم لما الـ UseCase مش محتاج أي parameters
// بدل ما تبعت null، بتبعت NoParams()
class NoParams {
  const NoParams();
}
