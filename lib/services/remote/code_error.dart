// const String wrongPassworld = 'WRONG_PASSWORD';

extension CodeExString on String? {
  String? get toLang {
    switch (this) {
      case 'WRONG_PASSWORD':
        return 'Password is wrong 😐';
    }
    return '$this 😐';
  }
}
