import 'package:collection/collection.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NewHelper {
  static OverlayEntry overlayLoader(context) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: Colors.deepPurpleAccent.withOpacity(0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.threeArchedCircle(color: Colors.deepPurpleAccent, size: 40),
            ],
          ),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry loader) {
    try {
      loader.remove();
      // ignore: empty_catches
    } catch (e) {}
  }

//   Future<File?> addFilePicker({
//     List<String>? allowedExtensions
// }) async {
//     try {
//       final item = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: allowedExtensions ?? ['jpg', 'png', 'jpeg'],
//       );
//       if (item == null) {
//         return null;
//       } else {
//         return File(item.files.first.path!);
//       }
//     } on PlatformException catch (e) {
//       throw Exception(e);
//     }
//   }

  // Future<List<File>?> addFilePickerList() async {
  //   try {
  //     final item = await FilePicker.platform.pickFiles(
  //       allowMultiple: true,
  //       type: FileType.custom,
  //       allowedExtensions: ['jpg'],
  //     );
  //     if (item == null) {
  //       return null;
  //     } else {
  //       return item.files.map((e) => File(e.path!)).toList();
  //     }
  //   } on PlatformException catch (e) {
  //     throw Exception(e);
  //   }
  // }

  Future<File?> addImagePicker({ImageSource imageSource = ImageSource.gallery, int imageQuality = 80}) async {
    try {
      final item = await ImagePicker().pickImage(source: imageSource, imageQuality: imageQuality);
      if (item == null) {
        return null;
      } else {
        return File(item.path);
      }
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

  Future<List<File>?> multiImagePicker({int imageQuality = 80}) async {
    try {
      final item = await ImagePicker().pickMultiImage(imageQuality: imageQuality);
      return List.generate(min(5, item.length), (index) => File(item[index].path));
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

  static showImagePickerSheet({
    required Function(File image) gotImage,
    Function(bool image)? removeImage,
    required BuildContext context,
    bool? removeOption,
  }) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Select Image',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurpleAccent),
        ),
        // message: Text('Message'),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Cancel");
          },
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Gallery'),
            onPressed: () {
              // pickImage(
              //     ImageSource.gallery);
              NewHelper().addImagePicker(imageSource: ImageSource.gallery, imageQuality: 60).then((value) {
                if (value == null) return;
                gotImage(value);
                Get.back();
              });
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              NewHelper().addImagePicker(imageSource: ImageSource.camera, imageQuality: 60).then((value) {
                if (value == null) return;
                gotImage(value);
                Get.back();
              });
            },
          ),
          if (removeOption == true)
            CupertinoActionSheetAction(
              child: const Text('Remove'),
              onPressed: () {
                Get.back();
                if (removeImage != null) {
                  removeImage(true);
                }
              },
            ),
        ],
      ),
    );
  }
}

extension ConvertToNum on String {
  num? get convertToNum {
    return num.tryParse(this);
  }

  num get toNum {
    return num.tryParse(this) ?? 0;
  }

  bool get isValidEmail {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    return (regex.hasMatch(this)) ? false : true;
  }

  String? validateEmpty(String gg) {
    return trim().isEmpty ? "$gg is required" : null;
  }

  String get checkNullable {
    if (this == "null") return "";
    return this;
  }
}

// extension CheckNull on String?{
//   String get checkNull{
//     return this ?? "";
//   }
// }

// extension GG on dynamic{
//
//   String get checkNullable{
//     if(this == null) return"";
//     return toString();
//   }
// }

extension GetTotal on List<num> {
  num get getTotal {
    return sum;
  }
}

extension Spacing on num {
  SizedBox get spaceX => SizedBox(
        width: toDouble(),
      );
  SizedBox get spaceY => SizedBox(
        height: toDouble(),
      );

  Duration get inSecond {
    return Duration(seconds: toInt());
  }

  Duration get inMilliSeconds {
    return Duration(milliseconds: toInt());
  }
}

extension GetContext on BuildContext {
  Size get getSize => MediaQuery.of(this).size;

  void get navigate {
    Scrollable.ensureVisible(this, alignment: .25, duration: const Duration(milliseconds: 600));
  }
}

// extension ValidateErrors on TextEditingController{
//   bool get checkEmpty{
//     if(text.trim().isNotEmpty)return false;
//     BuildContext? context1 = getKey.currentContext;
//     if(context1 != null) {
//       context1.navigate;
//       return true;
//     } else {
//       return false;
//     }
//   }
//   bool get checkNum{
//     if((num.tryParse(text.trim()) ?? 0) > 0)return false;
//     BuildContext? context1 = getKey.currentContext;
//     if(context1 != null) {
//       context1.navigate;
//       return true;
//     } else {
//       return false;
//     }
//   }
//
//   bool get checkBoth{
//     // print("checkEmpty.....   $checkEmpty");
//     // print("checkNum.....   $checkNum");
//     return checkEmpty || checkNum;
//   }
// }

// extension ToShimmer on Widget{
//   Widget get toShimmer{
//     return Shimmer.fromColors(
//       baseColor: Colors.grey,
//       highlightColor: Colors.white,
//       child: this,
//     );
//   }
// }

extension ConvertToDateon on Duration {
  DateTime get fromTodayStart {
    DateTime now = DateTime.now();
    DateTime gg = DateTime(now.year, now.month, now.day);
    return gg.add(this);
  }
}

const audioType = [
  "mp3",
];

extension ChangeFont on TextStyle {
  TextStyle get changeFont {
    return GoogleFonts.urbanist().merge(this);
  }
}

// showToast(message,{ToastGravity? gravity}) {
//   Fluttertoast.cancel();
//   Fluttertoast.showToast(
//       msg: message.toString().capitalize!,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: gravity ?? ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 4,
//       backgroundColor: primaryColor,
//       textColor: Colors.white,
//       fontSize: 15);
// }
