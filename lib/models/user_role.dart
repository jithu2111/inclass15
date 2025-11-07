enum UserRole {
  admin,
  viewer,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  bool get canEdit {
    return this == UserRole.admin;
  }

  bool get canDelete {
    return this == UserRole.admin;
  }

  bool get canCreate {
    return this == UserRole.admin;
  }
}