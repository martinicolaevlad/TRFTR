import 'dart:ffi';

import 'package:equatable/equatable.dart';

import '../../user_repository.dart';

class MyUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? picture;
  final String? fcmToken;
  final bool isOwner;

  const MyUser({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
    this.fcmToken,
    required this.isOwner,
  });

  static const empty = MyUser(
      id: '',
      email: '',
      name: '',
      picture: null,
      fcmToken: null,
      isOwner: false
  );

  MyUser copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
    String? fcmToken,
    bool? isOwner,
  }) {
    return MyUser(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        picture: picture ?? this.picture,
        fcmToken: fcmToken ?? this.fcmToken,
        isOwner: isOwner ?? this.isOwner
    );
  }

  bool get isEmpty => this == MyUser.empty;
  bool get isNotEmpty => this != MyUser.empty;

  MyUserEntity toEntity() {
    return MyUserEntity(
        id: id,
        email: email,
        name: name,
        picture: picture,
        fcmToken: fcmToken,
        isOwner: isOwner
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
        id: entity.id,
        email: entity.email,
        name: entity.name,
        picture: entity.picture,
        fcmToken: entity.fcmToken,
        isOwner: entity.isOwner
    );
  }

  @override
  List<Object?> get props => [id, email, name, picture, fcmToken, isOwner];
}
