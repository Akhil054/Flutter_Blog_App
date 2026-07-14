import '../../core/common/entites/user.dart';

class UserModel extends User{
  ///extends the entity present in domain layer

  /// asking the id from constrcutor  and passing to super class i.e user using super.id
  UserModel({
    required super.id,
    required super.email,
    required super.name
  });

  ///converting it into JSON
  factory UserModel.fromJson(Map<String, dynamic>map){
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
    );
  }

}