
import '../../../../core/common/entites/user.dart';

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
    /// Supabase's raw auth User.toJson() has no top-level 'name' - the name
    /// entered at sign up lives under 'user_metadata' instead. Fall back to
    /// that so login/sign up don't leave the name blank; a 'profiles' row
    /// (queried by getCurrentUserData) still takes priority when present.
    final metadata = map['user_metadata'] as Map<String, dynamic>?;
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? metadata?['name'] ?? '',
    );
  }

}