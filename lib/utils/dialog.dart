import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

mixin DialogUtil {
  static ProgressDialog progressDialog(
      {@required BuildContext context,
      String message = 'Please wait...',
      bool dissmiss = true}) {
    final pr = ProgressDialog(context,
        type: ProgressDialogType.Normal,
        isDismissible: dissmiss,
        showLogs: false);
    pr.style(
        message: message,
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CupertinoActivityIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    return pr;
  }
}
