// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Folder Authenticator';

  @override
  String get settings => '設定';

  @override
  String get about => 'アプリについて';

  @override
  String get licenses => 'ライセンス';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get aboutFolderAuthenticator => 'Folder Authenticatorについて';

  @override
  String get aboutDescription =>
      '時間ベースワンタイムパスワード（TOTP）を効率的に管理できるFlutterベースのモバイルアプリケーションです。';

  @override
  String get features => '機能:';

  @override
  String get featureOrganizeWithFolders => '• TOTPエントリをフォルダで整理';

  @override
  String get featureSecureEncryption => '• TOTPシークレットの安全な暗号化';

  @override
  String get featureQRCodeScanning => '• 簡単セットアップのためのQRコードスキャン';

  @override
  String get featureExportFunctionality => '• バックアップ用のエクスポート機能';

  @override
  String get featureCleanIntuitive => '• シンプルで直感的なユーザーインターフェース';

  @override
  String get featureOfflineAccess => '• 全てのTOTPコードへのオフラインアクセス';

  @override
  String get featureHierarchicalOrganization => '• ネストしたフォルダによる階層的な整理';

  @override
  String get featureRealTimeSync => '• TOTPコードのリアルタイム同期';

  @override
  String version(String version) {
    return 'バージョン: $version';
  }

  @override
  String get versionUnknown => 'バージョン: 不明';

  @override
  String get versionLoading => 'バージョン: 読み込み中...';

  @override
  String get close => '閉じる';

  @override
  String get totpDetails => 'TOTP詳細';

  @override
  String get export => 'エクスポート';

  @override
  String refreshesIn(int seconds) {
    return '$seconds秒後に更新';
  }

  @override
  String get copyCode => 'コードをコピー';

  @override
  String get codeCopiedToClipboard => 'コードをクリップボードにコピーしました';

  @override
  String get name => '名前';

  @override
  String get issuer => '発行者';

  @override
  String get deleteTotpEntry => 'TOTPエントリを削除';

  @override
  String deleteConfirmation(String name) {
    return '「$name」を削除してもよろしいですか？';
  }

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get editTotp => 'TOTP編集';

  @override
  String get totpEntryUpdated => 'TOTPエントリが更新されました';

  @override
  String get exportTotp => 'TOTPエクスポート';

  @override
  String get copyUri => 'URIをコピー';

  @override
  String get uriCopiedToClipboard => 'URIをクリップボードにコピーしました';

  @override
  String get showSecret => 'シークレットを表示';

  @override
  String get secretCopiedToClipboard => 'シークレットをクリップボードにコピーしました';

  @override
  String get securityWarning => '警告: このシークレットは安全に保管し、誰にも共有しないでください。';

  @override
  String get editFolder => 'フォルダ編集';

  @override
  String get deleteFolder => 'フォルダを削除';

  @override
  String deleteFolderConfirmation(String name) {
    return '「$name」を削除してもよろしいですか？';
  }

  @override
  String get folderName => 'フォルダ名';

  @override
  String get selectFolderPath => 'フォルダパスを選択';

  @override
  String get folderPathSelectionDialog => 'フォルダパス選択ダイアログ';

  @override
  String get ok => 'OK';

  @override
  String get save => '保存';

  @override
  String get addNew => '新規追加';

  @override
  String get addTotpManually => '手動でTOTPを追加';

  @override
  String get scanQrCode => 'QRコードをスキャン';

  @override
  String get addFolder => 'フォルダを追加';

  @override
  String folderCreated(String name) {
    return 'フォルダ「$name」が作成されました';
  }

  @override
  String errorCreatingFolder(String error) {
    return 'フォルダ作成エラー: $error';
  }

  @override
  String get add => '追加';

  @override
  String get addTotp => 'TOTP追加';

  @override
  String get secret => 'シークレット';

  @override
  String get issuerOptional => '発行者（オプション）';

  @override
  String get totpEntryAddedSuccessfully => 'TOTPエントリが正常に追加されました';

  @override
  String get invalidTotpQrCode => '無効なTOTP QRコード';

  @override
  String errorProcessingQrCode(String error) {
    return 'QRコード処理エラー: $error';
  }

  @override
  String get root => 'ルート';

  @override
  String errorLoadingFolderEntries(String error) {
    return 'フォルダエントリの読み込みエラー: $error';
  }

  @override
  String get noTotpEntriesOrSubfolders => 'TOTPエントリまたはサブフォルダが見つかりません';

  @override
  String get errorLoadingTotpEntry => 'TOTPエントリの読み込みエラー';

  @override
  String secondsShort(int seconds) {
    return '$seconds秒';
  }

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get systemDefault => 'システムのデフォルト';
}
