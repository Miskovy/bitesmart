import 'package:bite_smart/features/profile/data/models/profile_setup_model.dart';
import 'package:equatable/equatable.dart';

enum ProfileSetupStatus { initial, collecting, submitting, success, failure }

class ProfileSetupState extends Equatable {
  final ProfileSetupModel data;
  final ProfileSetupStatus status;
  final String? errorMessage;

  const ProfileSetupState({
    this.data = const ProfileSetupModel(),
    this.status = ProfileSetupStatus.initial,
    this.errorMessage,
  });

  ProfileSetupState copyWith({
    ProfileSetupModel? data,
    ProfileSetupStatus? status,
    String? errorMessage,
  }) {
    return ProfileSetupState(
      data: data ?? this.data,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [data, status, errorMessage];
}
