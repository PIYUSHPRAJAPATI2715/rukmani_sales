import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

showToast(message, {ToastGravity? gravity}) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: message.toString().capitalize!,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: 4,
      fontSize: 15);
}
