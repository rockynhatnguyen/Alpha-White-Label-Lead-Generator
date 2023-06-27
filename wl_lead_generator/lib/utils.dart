import 'package:flutter_dotenv/flutter_dotenv.dart';

class Utils {
  static String getDateEndpoint() {
    return getEndpoint() + (dotenv.get('GET_DATE_PATH'));
  }

  static String getPostFormEndpoint() {
    return getEndpoint() + (dotenv.get('POST_FORM_PATH'));
  }

  static String getUpdateOptinEndpoint() {
    return getEndpoint() + (dotenv.get('UPDATE_OPTIN_PATH'));
  }

  static String getEndpoint() {
    if ((dotenv.get('USE_LOCAL_ENDPOINT')) == "true") {
      return dotenv.get('LOCAL_ENDPOINT');
    } else {
      return dotenv.get('REMOTE_ENDPOINT');
    }
    ;
  }
}
