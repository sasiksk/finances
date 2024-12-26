import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> sendSms(String phoneNumber, String message) async {
  try {
    // Request SMS permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }

    if (status.isGranted) {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: <String, String>{
          'body': message,
        },
      );
      if (await canLaunch(smsUri.toString())) {
        await launch(smsUri.toString());
        print('SMS sent to $phoneNumber');
      } else {
        print('Could not launch SMS app');
      }
    } else {
      print('SMS permission denied');
    }
  } catch (error) {
    print('Failed to send SMS: $error');
  }
}
