

import 'package:ChatFlutter/repositories/notification_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> independentProviders = [
  Provider(create: (_) => NotificationRepository())
];