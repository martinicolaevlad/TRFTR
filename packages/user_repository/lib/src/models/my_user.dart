import 'dart:ffi';

import 'package:equatable/equatable.dart';

import '../../user_repository.dart';

class MyUser extends Equatable{
  final String id;
  final String email;
  final String name;
  final String? picture;
  final bool isOwner;

  const MyUser({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
    required this.isOwner
  });
  
  static const empty = MyUser(
      id: '',
      email: '',
      name: '',
      picture: '',
      isOwner: false
  );
  
  MyUser copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
    bool? isOwner
  }){
    return MyUser(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        picture: picture ?? this.picture,
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
      isOwner: isOwner
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      picture: entity.picture,
      isOwner: entity.isOwner

    );
  }

  @override
  List<Object?> get props => [id,email,name,picture,isOwner];

}