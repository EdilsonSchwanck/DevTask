import 'package:intl/intl.dart';


abstract final class Formatters {

  static String date(DateTime value, String locale) =>
      DateFormat.yMMMd(locale).format(value);

  static String dateTime(DateTime value, String locale) =>
      DateFormat.yMMMd(locale).add_Hm().format(value);

  static String percent(double value, String locale) =>
      NumberFormat.percentPattern(locale).format(value);
}
