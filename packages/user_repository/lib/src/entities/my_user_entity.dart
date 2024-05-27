import 'package:equatable/equatable.dart';

class MyUserEntity extends Equatable {
  String id;
  String email;
  String name;
  String? picture;
  String? fcmToken;
  bool isOwner;

  MyUserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
    this.fcmToken,
    required this.isOwner,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture': picture,
      'fcmToken': fcmToken,
      'isOwner' : isOwner,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
        id: doc['id'] as String,
        email: doc['email'] as String,
        name: doc['name'] as String,
        picture: doc['picture'] as String?,
        fcmToken: doc['fcmToken'] as String?,
        isOwner: doc['isOwner'] as bool
    );
  }

  @override
  List<Object?> get props => [id, email, name, picture, fcmToken, isOwner];

  @override
  String toString() {
    return '''UserEntity: {
      id: $id,
      email: $email,
      name: $name,
      picture: $picture,
      fcmToken: $fcmToken,
      isOwner: $isOwner
    }''';
  }
}
