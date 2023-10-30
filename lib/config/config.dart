 enum Flavor { DEV, PROD }

Flavor? flavor;
String? production;

String get baseUrl {
  switch (flavor) {
    case Flavor.DEV:
      return 'https://test-api.baeit.co.kr/api/v1/app/';
    case Flavor.PROD:
      return 'https://api.baeit.co.kr/api/v1/app/';
    default:
      return 'https://test-api.baeit.co.kr/api/v1/app/';
  }
}

String get baseChatUrl {
  switch (flavor) {
    case Flavor.DEV:
      return 'wss://test-stomp.baeit.co.kr/chat';
    case Flavor.PROD:
      return 'wss://stomp.baeit.co.kr/chat';
    default:
      return 'wss://test-stomp.baeit.co.kr/chat';
  }
}
