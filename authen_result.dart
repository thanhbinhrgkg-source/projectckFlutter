class AuthenResult {
  final bool success;
  final String message;
  final bool needVerify;
  AuthenResult({
    required this.success,
    required this.message,
    this.needVerify = false,
  });
}
