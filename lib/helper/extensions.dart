
import 'package:flutter/cupertino.dart';

extension GetMediaQuery on BuildContext{
  Size get getSize {
    return MediaQuery.sizeOf(this);
  }

  Future get navigate async {
    return await Scrollable.ensureVisible(this, alignment: .25, duration: const Duration(milliseconds: 600));
  }
}