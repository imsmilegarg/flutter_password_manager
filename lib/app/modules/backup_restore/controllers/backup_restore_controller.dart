import 'package:get/get.dart';
import 'package:password_manager/app/core/utils/helpers.dart';
import 'package:password_manager/app/core/values/strings.dart';
import 'package:password_manager/app/data/models/backup_model.dart';
import 'package:password_manager/app/data/models/password_model.dart';
import 'package:password_manager/app/data/services/file_service.dart';
import 'package:password_manager/app/data/services/shared_pref_service.dart';
import 'package:password_manager/app/modules/home/controllers/home_controller.dart';

////TODOs For Future Version;
// enum BackupOptions {
//   FullEncrypted,
//   PasswordsEncrypted,
//   UnEncrypted,
// }

class BackupRestoreController extends GetxController {
  late int? _lastBackupTime;
  late final int? totalPasswords;
  late final List<Password> _passwords;
  late final bool showBackupButton;
  late final bool showShareFileButton;

  bool backupButtonLoading = false;
  bool restoreButtonLoading = false;

  final String backupButtonId = "Backup Button";
  final String backupTimeId = "Backup Time";
  final String passwordsId = "Total Passwords";
  final String restoreButtonId = "Restore Button";

  final noPassErrorMsg = "You Do Not Have Any Passwords Saved!";

  late final instance = initComponents();

  String get lastBackupTime {
    if (_lastBackupTime != null) {
      return DateTime.fromMillisecondsSinceEpoch(_lastBackupTime!).toString();
    }
    return "Never";
  }

  Future<bool> initComponents() async {
    _lastBackupTime = await Get.find<SharedPrefService>().storage.getInt(
          lastBackup,
        );

    _passwords = Get.find<HomeController>().passwords;
    showShareFileButton = await Get.find<FileService>().isFileExists(
      backupFileName,
    );
    totalPasswords = _passwords.length;
    showBackupButton = totalPasswords != 0;
    return true;
  }

  void toggleBackupLoading(bool value) {
    backupButtonLoading = value;
    update([backupButtonId]);
  }

  void toggleRestoreLoading(bool value) {
    restoreButtonLoading = value;
    update([restoreButtonId]);
  }

  void performBackup() async {
    if (totalPasswords == 0) {
      errorSnackbar(noPassErrorMsg);
      return;
    }
    toggleBackupLoading(true);
    await _backup();
    toggleBackupLoading(false);
  }

  void performRestore() {}

  Future _backup() async {
    int time = DateTime.now().millisecondsSinceEpoch;
    Backup backup = Backup(
      dateCreated: time,
      passwords: _passwords,
    );

    final string = backup.toString();

    final fileService = Get.find<FileService>();
    final file = await fileService.createTextFile(string, backupFileName);

    await Get.find<SharedPrefService>().storage.setInt(lastBackupTime, time);
    _lastBackupTime = time;
    update([backupTimeId]);
    await fileService.shareFile(file.path);
  }

  void shareFile() async {
    final fileService = Get.find<FileService>();
    final fullPath = await fileService.getFullPath(backupFileName);
    fileService.shareFile(fullPath);
  }
}
