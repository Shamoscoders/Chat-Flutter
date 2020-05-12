import 'package:intl/intl.dart';

mixin TimeFormat {
  static String timeStamp(String time) {
    return DateFormat('dd MMM kk:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(time)));
  }
}
