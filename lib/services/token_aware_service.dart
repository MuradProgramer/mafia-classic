abstract class 
TokenAwareService {
  Future<String> getAccessToken();
  Future<void> refreshToken();
  bool isTokenExpired();

  Future<void> executeWithTokenCheck(Function apiMethod) async {
    if (isTokenExpired()) {
      await refreshToken();
    }
    final accessToken = await getAccessToken();
    await apiMethod(accessToken);
  }
}