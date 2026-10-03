import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('zh')];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'百米分析'**
  String get appTitle;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'確認'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'儲存'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'編輯'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'關閉'**
  String get close;

  /// No description provided for @actions.
  ///
  /// In zh, this message translates to:
  /// **'操作'**
  String get actions;

  /// No description provided for @notes.
  ///
  /// In zh, this message translates to:
  /// **'備註'**
  String get notes;

  /// No description provided for @noNotes.
  ///
  /// In zh, this message translates to:
  /// **'無備註'**
  String get noNotes;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'語言'**
  String get language;

  /// No description provided for @chinese.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @switchLanguage.
  ///
  /// In zh, this message translates to:
  /// **'切換語言'**
  String get switchLanguage;

  /// No description provided for @navRecord.
  ///
  /// In zh, this message translates to:
  /// **'錄影'**
  String get navRecord;

  /// No description provided for @navUpload.
  ///
  /// In zh, this message translates to:
  /// **'上傳'**
  String get navUpload;

  /// No description provided for @navPlayback.
  ///
  /// In zh, this message translates to:
  /// **'回放'**
  String get navPlayback;

  /// No description provided for @navSupport.
  ///
  /// In zh, this message translates to:
  /// **'支援'**
  String get navSupport;

  /// No description provided for @navPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隱私權政策'**
  String get navPolicy;

  /// No description provided for @navLogout.
  ///
  /// In zh, this message translates to:
  /// **'登出'**
  String get navLogout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'確認登出'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'您確定要登出系統嗎？'**
  String get logoutConfirmMessage;

  /// No description provided for @login.
  ///
  /// In zh, this message translates to:
  /// **'登入'**
  String get login;

  /// No description provided for @register.
  ///
  /// In zh, this message translates to:
  /// **'註冊'**
  String get register;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'使用者名稱'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In zh, this message translates to:
  /// **'請輸入使用者名稱'**
  String get usernameHint;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'密碼'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In zh, this message translates to:
  /// **'請輸入密碼'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In zh, this message translates to:
  /// **'確認密碼'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'請再次輸入密碼'**
  String get confirmPasswordHint;

  /// No description provided for @rememberMe.
  ///
  /// In zh, this message translates to:
  /// **'記住我'**
  String get rememberMe;

  /// No description provided for @dontHaveAccount.
  ///
  /// In zh, this message translates to:
  /// **'還沒有帳號？立即註冊'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In zh, this message translates to:
  /// **'已有帳號？立即登入'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In zh, this message translates to:
  /// **'兩次輸入的密碼不一致'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginFailed.
  ///
  /// In zh, this message translates to:
  /// **'登入失敗'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In zh, this message translates to:
  /// **'註冊失敗'**
  String get registerFailed;

  /// No description provided for @loginSuccess.
  ///
  /// In zh, this message translates to:
  /// **'登入成功'**
  String get loginSuccess;

  /// No description provided for @registerSuccess.
  ///
  /// In zh, this message translates to:
  /// **'註冊成功'**
  String get registerSuccess;

  /// No description provided for @selectRunner.
  ///
  /// In zh, this message translates to:
  /// **'選擇選手'**
  String get selectRunner;

  /// No description provided for @searchRunner.
  ///
  /// In zh, this message translates to:
  /// **'搜尋選手...'**
  String get searchRunner;

  /// No description provided for @addRunner.
  ///
  /// In zh, this message translates to:
  /// **'新增選手'**
  String get addRunner;

  /// No description provided for @runnerName.
  ///
  /// In zh, this message translates to:
  /// **'選手姓名'**
  String get runnerName;

  /// No description provided for @enterRunnerName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入選手姓名'**
  String get enterRunnerName;

  /// No description provided for @analysisHistory.
  ///
  /// In zh, this message translates to:
  /// **'歷史分析紀錄'**
  String get analysisHistory;

  /// No description provided for @noHistoryFound.
  ///
  /// In zh, this message translates to:
  /// **'暫無分析紀錄'**
  String get noHistoryFound;

  /// No description provided for @cameras.
  ///
  /// In zh, this message translates to:
  /// **'相機'**
  String get cameras;

  /// No description provided for @statusDone.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get statusDone;

  /// No description provided for @statusProcessing.
  ///
  /// In zh, this message translates to:
  /// **'處理中'**
  String get statusProcessing;

  /// No description provided for @statusFailed.
  ///
  /// In zh, this message translates to:
  /// **'失敗'**
  String get statusFailed;

  /// No description provided for @statusPending.
  ///
  /// In zh, this message translates to:
  /// **'待處理'**
  String get statusPending;

  /// No description provided for @sessionInfo.
  ///
  /// In zh, this message translates to:
  /// **'跑步資訊'**
  String get sessionInfo;

  /// No description provided for @analysisStatus.
  ///
  /// In zh, this message translates to:
  /// **'分析狀態'**
  String get analysisStatus;

  /// No description provided for @dateTime.
  ///
  /// In zh, this message translates to:
  /// **'日期時間'**
  String get dateTime;

  /// No description provided for @cameraCount.
  ///
  /// In zh, this message translates to:
  /// **'相機數量'**
  String get cameraCount;

  /// No description provided for @totalTime.
  ///
  /// In zh, this message translates to:
  /// **'總時間'**
  String get totalTime;

  /// No description provided for @avgVelocity.
  ///
  /// In zh, this message translates to:
  /// **'平均速度'**
  String get avgVelocity;

  /// No description provided for @avgAcceleration.
  ///
  /// In zh, this message translates to:
  /// **'平均加速度'**
  String get avgAcceleration;

  /// No description provided for @avgStepLength.
  ///
  /// In zh, this message translates to:
  /// **'平均步幅'**
  String get avgStepLength;

  /// No description provided for @unitSeconds.
  ///
  /// In zh, this message translates to:
  /// **'秒'**
  String get unitSeconds;

  /// No description provided for @unitMps.
  ///
  /// In zh, this message translates to:
  /// **'公尺/秒'**
  String get unitMps;

  /// No description provided for @unitMps2.
  ///
  /// In zh, this message translates to:
  /// **'公尺/秒²'**
  String get unitMps2;

  /// No description provided for @unitMeters.
  ///
  /// In zh, this message translates to:
  /// **'公尺'**
  String get unitMeters;

  /// No description provided for @downloadPdfReport.
  ///
  /// In zh, this message translates to:
  /// **'下載 PDF 報告'**
  String get downloadPdfReport;

  /// No description provided for @downloadCsvData.
  ///
  /// In zh, this message translates to:
  /// **'下載 CSV 數據'**
  String get downloadCsvData;

  /// No description provided for @deleteSessionConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'刪除分析紀錄'**
  String get deleteSessionConfirmTitle;

  /// No description provided for @deleteSessionConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'確認要刪除此筆分析紀錄嗎？此動作無法復原。'**
  String get deleteSessionConfirmMessage;

  /// No description provided for @tabOverallPerformance.
  ///
  /// In zh, this message translates to:
  /// **'運動學指標'**
  String get tabOverallPerformance;

  /// No description provided for @tabJointAngles.
  ///
  /// In zh, this message translates to:
  /// **'關節角度'**
  String get tabJointAngles;

  /// No description provided for @tabSymmetry.
  ///
  /// In zh, this message translates to:
  /// **'左右腳步對稱'**
  String get tabSymmetry;

  /// No description provided for @noChartData.
  ///
  /// In zh, this message translates to:
  /// **'暫無圖表資料'**
  String get noChartData;

  /// No description provided for @deleteRunnerConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'刪除選手'**
  String get deleteRunnerConfirmTitle;

  /// No description provided for @deleteRunnerConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'確認要刪除選手「{name}」及其所有紀錄嗎？'**
  String deleteRunnerConfirmMessage(String name);

  /// No description provided for @recordControl.
  ///
  /// In zh, this message translates to:
  /// **'錄影控制'**
  String get recordControl;

  /// No description provided for @cameraSettings.
  ///
  /// In zh, this message translates to:
  /// **'相機設定'**
  String get cameraSettings;

  /// No description provided for @fps.
  ///
  /// In zh, this message translates to:
  /// **'FPS'**
  String get fps;

  /// No description provided for @countdownTimer.
  ///
  /// In zh, this message translates to:
  /// **'倒數計時'**
  String get countdownTimer;

  /// No description provided for @startRecording.
  ///
  /// In zh, this message translates to:
  /// **'開始錄影'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In zh, this message translates to:
  /// **'停止錄影'**
  String get stopRecording;

  /// No description provided for @cameraStatusReady.
  ///
  /// In zh, this message translates to:
  /// **'就緒'**
  String get cameraStatusReady;

  /// No description provided for @cameraStatusNotReady.
  ///
  /// In zh, this message translates to:
  /// **'尚未就緒'**
  String get cameraStatusNotReady;

  /// No description provided for @recaptureSnapshot.
  ///
  /// In zh, this message translates to:
  /// **'📷 重新擷取'**
  String get recaptureSnapshot;

  /// No description provided for @setAnchor.
  ///
  /// In zh, this message translates to:
  /// **'設置錨點'**
  String get setAnchor;

  /// No description provided for @confirmAnchor.
  ///
  /// In zh, this message translates to:
  /// **'確認錨點'**
  String get confirmAnchor;

  /// No description provided for @clearAnchor.
  ///
  /// In zh, this message translates to:
  /// **'清除錨點'**
  String get clearAnchor;

  /// No description provided for @markAllPointsPrompt.
  ///
  /// In zh, this message translates to:
  /// **'請先標註完所有 6 個錨點'**
  String get markAllPointsPrompt;

  /// No description provided for @distanceDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'實際距離設定 (公尺)'**
  String get distanceDialogTitle;

  /// No description provided for @distanceDialogSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'請輸入兩段跑道縱向距離與跑道寬度，以進行精確公尺換算：'**
  String get distanceDialogSubtitle;

  /// No description provided for @distanceLeftToCenter.
  ///
  /// In zh, this message translates to:
  /// **'左線 (1-4) 至中線 (5-6) 縱向距離 (m)'**
  String get distanceLeftToCenter;

  /// No description provided for @distanceCenterToRight.
  ///
  /// In zh, this message translates to:
  /// **'中線 (5-6) 至右線 (2-3) 縱向距離 (m)'**
  String get distanceCenterToRight;

  /// No description provided for @runwayWidth.
  ///
  /// In zh, this message translates to:
  /// **'跑道寬度 (m)'**
  String get runwayWidth;

  /// No description provided for @distanceInvalidPrompt.
  ///
  /// In zh, this message translates to:
  /// **'請輸入大於 0 的有效數值'**
  String get distanceInvalidPrompt;

  /// No description provided for @applyAndSave.
  ///
  /// In zh, this message translates to:
  /// **'確認並套用'**
  String get applyAndSave;

  /// No description provided for @dragToAdjust.
  ///
  /// In zh, this message translates to:
  /// **'拖曳以調整位置'**
  String get dragToAdjust;

  /// No description provided for @tapToMarkPoint.
  ///
  /// In zh, this message translates to:
  /// **'點擊或滑動以標註'**
  String get tapToMarkPoint;

  /// No description provided for @point1.
  ///
  /// In zh, this message translates to:
  /// **'點 1 (左上)'**
  String get point1;

  /// No description provided for @point2.
  ///
  /// In zh, this message translates to:
  /// **'點 2 (右上)'**
  String get point2;

  /// No description provided for @point3.
  ///
  /// In zh, this message translates to:
  /// **'點 3 (右下)'**
  String get point3;

  /// No description provided for @point4.
  ///
  /// In zh, this message translates to:
  /// **'點 4 (左下)'**
  String get point4;

  /// No description provided for @point5.
  ///
  /// In zh, this message translates to:
  /// **'點 5 (中上)'**
  String get point5;

  /// No description provided for @point6.
  ///
  /// In zh, this message translates to:
  /// **'點 6 (中下)'**
  String get point6;

  /// No description provided for @cameraNotAssigned.
  ///
  /// In zh, this message translates to:
  /// **'尚未分配相機編號'**
  String get cameraNotAssigned;

  /// No description provided for @orientationLandscapeRequired.
  ///
  /// In zh, this message translates to:
  /// **'請將手機橫放以開始錄影'**
  String get orientationLandscapeRequired;

  /// No description provided for @connectedStatus.
  ///
  /// In zh, this message translates to:
  /// **'連線狀態'**
  String get connectedStatus;

  /// No description provided for @controlGranted.
  ///
  /// In zh, this message translates to:
  /// **'已取得控制權'**
  String get controlGranted;

  /// No description provided for @controlDenied.
  ///
  /// In zh, this message translates to:
  /// **'要求控制權被拒絕'**
  String get controlDenied;

  /// No description provided for @connectionError.
  ///
  /// In zh, this message translates to:
  /// **'連線錯誤: {error}'**
  String connectionError(String error);

  /// No description provided for @connectionDisconnected.
  ///
  /// In zh, this message translates to:
  /// **'連線已斷開'**
  String get connectionDisconnected;

  /// No description provided for @tabUploadAll.
  ///
  /// In zh, this message translates to:
  /// **'一次性上傳'**
  String get tabUploadAll;

  /// No description provided for @tabUploadSeparately.
  ///
  /// In zh, this message translates to:
  /// **'分批上傳'**
  String get tabUploadSeparately;

  /// No description provided for @tabUnanalyzedHistory.
  ///
  /// In zh, this message translates to:
  /// **'未分析歷史'**
  String get tabUnanalyzedHistory;

  /// No description provided for @basicInfo.
  ///
  /// In zh, this message translates to:
  /// **'基本資訊'**
  String get basicInfo;

  /// No description provided for @selectRunnerRequired.
  ///
  /// In zh, this message translates to:
  /// **'請選擇選手'**
  String get selectRunnerRequired;

  /// No description provided for @selectDate.
  ///
  /// In zh, this message translates to:
  /// **'選擇日期'**
  String get selectDate;

  /// No description provided for @uploadAndAnalyze.
  ///
  /// In zh, this message translates to:
  /// **'上傳並分析'**
  String get uploadAndAnalyze;

  /// No description provided for @selectVideo.
  ///
  /// In zh, this message translates to:
  /// **'選擇影片'**
  String get selectVideo;

  /// No description provided for @videoSelected.
  ///
  /// In zh, this message translates to:
  /// **'已選擇影片'**
  String get videoSelected;

  /// No description provided for @anchorSet.
  ///
  /// In zh, this message translates to:
  /// **'錨點已設定'**
  String get anchorSet;

  /// No description provided for @anchorNotSet.
  ///
  /// In zh, this message translates to:
  /// **'尚未設定錨點'**
  String get anchorNotSet;

  /// No description provided for @mustSetAnchorsForAllCameras.
  ///
  /// In zh, this message translates to:
  /// **'請先設置所有相機的錨點'**
  String get mustSetAnchorsForAllCameras;

  /// No description provided for @selectVideoFirst.
  ///
  /// In zh, this message translates to:
  /// **'請先上傳影片'**
  String get selectVideoFirst;

  /// No description provided for @uploading.
  ///
  /// In zh, this message translates to:
  /// **'上傳中...'**
  String get uploading;

  /// No description provided for @uploadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'上傳成功'**
  String get uploadSuccess;

  /// No description provided for @uploadFailed.
  ///
  /// In zh, this message translates to:
  /// **'上傳失敗'**
  String get uploadFailed;

  /// No description provided for @anchorDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'設置錨點 (相機 {index})'**
  String anchorDialogTitle(int index);

  /// No description provided for @selectAnchorToMark.
  ///
  /// In zh, this message translates to:
  /// **'選擇要標註的錨點：'**
  String get selectAnchorToMark;

  /// No description provided for @leftStart.
  ///
  /// In zh, this message translates to:
  /// **'左上'**
  String get leftStart;

  /// No description provided for @rightStart.
  ///
  /// In zh, this message translates to:
  /// **'右上'**
  String get rightStart;

  /// No description provided for @rightEnd.
  ///
  /// In zh, this message translates to:
  /// **'右下'**
  String get rightEnd;

  /// No description provided for @leftEnd.
  ///
  /// In zh, this message translates to:
  /// **'左下'**
  String get leftEnd;

  /// No description provided for @centerStart.
  ///
  /// In zh, this message translates to:
  /// **'中上'**
  String get centerStart;

  /// No description provided for @centerEnd.
  ///
  /// In zh, this message translates to:
  /// **'中下'**
  String get centerEnd;

  /// No description provided for @undo.
  ///
  /// In zh, this message translates to:
  /// **'上一步'**
  String get undo;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get clear;

  /// No description provided for @magnifier.
  ///
  /// In zh, this message translates to:
  /// **'放大鏡'**
  String get magnifier;

  /// No description provided for @guide.
  ///
  /// In zh, this message translates to:
  /// **'標註指引'**
  String get guide;

  /// No description provided for @guideDescription.
  ///
  /// In zh, this message translates to:
  /// **'依序點擊畫面標記跑道四角點（左上、右上、右下、左下），中線點將自動計算產生，完成後可直接拖曳微調。'**
  String get guideDescription;

  /// No description provided for @guideDescriptionMobile.
  ///
  /// In zh, this message translates to:
  /// **'點選下方「點 1 (左上)」至「點 6 (中下)」按鈕選定目標點，再點擊或拖曳畫面標註位置；中線點將自動計算，亦可手動微調。'**
  String get guideDescriptionMobile;

  /// No description provided for @noUnanalyzedSessions.
  ///
  /// In zh, this message translates to:
  /// **'暫無未分析紀錄'**
  String get noUnanalyzedSessions;

  /// No description provided for @startAnalysis.
  ///
  /// In zh, this message translates to:
  /// **'開始分析'**
  String get startAnalysis;

  /// No description provided for @deleteUnanalyzedConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確認要刪除此筆未分析紀錄嗎？'**
  String get deleteUnanalyzedConfirm;

  /// No description provided for @progressTranscode.
  ///
  /// In zh, this message translates to:
  /// **'影片轉檔完成'**
  String get progressTranscode;

  /// No description provided for @progressTracking.
  ///
  /// In zh, this message translates to:
  /// **'影片追蹤 (Tracking) 完成'**
  String get progressTracking;

  /// No description provided for @progressPose.
  ///
  /// In zh, this message translates to:
  /// **'姿勢估計 (Pose Estimation) 完成'**
  String get progressPose;

  /// No description provided for @progressPostProcessing.
  ///
  /// In zh, this message translates to:
  /// **'資料後處理完成'**
  String get progressPostProcessing;

  /// No description provided for @progressSaved.
  ///
  /// In zh, this message translates to:
  /// **'全部結束並存檔'**
  String get progressSaved;

  /// No description provided for @supportTitle.
  ///
  /// In zh, this message translates to:
  /// **'聯絡與技術支援'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'如有任何系統使用問題或反饋，歡迎隨時與我們聯繫。'**
  String get supportSubtitle;

  /// No description provided for @contactEmail.
  ///
  /// In zh, this message translates to:
  /// **'支援信箱'**
  String get contactEmail;

  /// No description provided for @systemVersion.
  ///
  /// In zh, this message translates to:
  /// **'系統版本'**
  String get systemVersion;

  /// No description provided for @policyTitle.
  ///
  /// In zh, this message translates to:
  /// **'隱私權政策'**
  String get policyTitle;

  /// No description provided for @policyLastUpdated.
  ///
  /// In zh, this message translates to:
  /// **'最後更新日期'**
  String get policyLastUpdated;

  /// No description provided for @masterDevice.
  ///
  /// In zh, this message translates to:
  /// **'主控裝置'**
  String get masterDevice;

  /// No description provided for @masterDeviceDescription.
  ///
  /// In zh, this message translates to:
  /// **'負責控制所有裝置的開始與結束錄影'**
  String get masterDeviceDescription;

  /// No description provided for @expectedDeviceCount.
  ///
  /// In zh, this message translates to:
  /// **'預計連線裝置數: '**
  String get expectedDeviceCount;

  /// No description provided for @createRecordingRoom.
  ///
  /// In zh, this message translates to:
  /// **'建立錄影房間'**
  String get createRecordingRoom;

  /// No description provided for @orDivider.
  ///
  /// In zh, this message translates to:
  /// **'或'**
  String get orDivider;

  /// No description provided for @slaveDevice.
  ///
  /// In zh, this message translates to:
  /// **'錄影手機'**
  String get slaveDevice;

  /// No description provided for @enterRoomNumber.
  ///
  /// In zh, this message translates to:
  /// **'輸入房間號碼'**
  String get enterRoomNumber;

  /// No description provided for @selectCameraPosition.
  ///
  /// In zh, this message translates to:
  /// **'選擇相機位置'**
  String get selectCameraPosition;

  /// No description provided for @joinRecordingRoom.
  ///
  /// In zh, this message translates to:
  /// **'加入錄影房間'**
  String get joinRecordingRoom;

  /// No description provided for @roomNumber.
  ///
  /// In zh, this message translates to:
  /// **'房間號碼'**
  String get roomNumber;

  /// No description provided for @currentRole.
  ///
  /// In zh, this message translates to:
  /// **'目前身份'**
  String get currentRole;

  /// No description provided for @roleMaster.
  ///
  /// In zh, this message translates to:
  /// **'主控端 (Master)'**
  String get roleMaster;

  /// No description provided for @roleSlave.
  ///
  /// In zh, this message translates to:
  /// **'錄影端 (Slave)'**
  String get roleSlave;

  /// No description provided for @localRecording.
  ///
  /// In zh, this message translates to:
  /// **'本機參與錄影'**
  String get localRecording;

  /// No description provided for @changeCameraPosition.
  ///
  /// In zh, this message translates to:
  /// **'更改相機位置:'**
  String get changeCameraPosition;

  /// No description provided for @connectedDevices.
  ///
  /// In zh, this message translates to:
  /// **'已連線設備清單:'**
  String get connectedDevices;

  /// No description provided for @waitingForConnection.
  ///
  /// In zh, this message translates to:
  /// **'等待連線中...'**
  String get waitingForConnection;

  /// No description provided for @roomHost.
  ///
  /// In zh, this message translates to:
  /// **'房主'**
  String get roomHost;

  /// No description provided for @recordingInProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在錄影中...'**
  String get recordingInProgress;

  /// No description provided for @stopRecordingAndUpload.
  ///
  /// In zh, this message translates to:
  /// **'停止錄影並上傳'**
  String get stopRecordingAndUpload;

  /// No description provided for @startSyncRecording.
  ///
  /// In zh, this message translates to:
  /// **'開始同步錄影'**
  String get startSyncRecording;

  /// No description provided for @requestControl.
  ///
  /// In zh, this message translates to:
  /// **'要求主控權'**
  String get requestControl;

  /// No description provided for @takeControl.
  ///
  /// In zh, this message translates to:
  /// **'取得主控權'**
  String get takeControl;

  /// No description provided for @waitingForControlApproval.
  ///
  /// In zh, this message translates to:
  /// **'等待房主審核中...'**
  String get waitingForControlApproval;

  /// No description provided for @leaveRoom.
  ///
  /// In zh, this message translates to:
  /// **'離開房間'**
  String get leaveRoom;

  /// No description provided for @controlTransferRequest.
  ///
  /// In zh, this message translates to:
  /// **'主控權轉移要求'**
  String get controlTransferRequest;

  /// No description provided for @controlTransferMessage.
  ///
  /// In zh, this message translates to:
  /// **'設備 {id} 正在要求此房間的主控權，您同意轉移嗎？'**
  String controlTransferMessage(String id);

  /// No description provided for @approve.
  ///
  /// In zh, this message translates to:
  /// **'同意'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In zh, this message translates to:
  /// **'拒絕'**
  String get reject;

  /// No description provided for @uploadSeparately.
  ///
  /// In zh, this message translates to:
  /// **'分別上傳'**
  String get uploadSeparately;

  /// No description provided for @uploadAll.
  ///
  /// In zh, this message translates to:
  /// **'一起上傳'**
  String get uploadAll;

  /// No description provided for @date.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get date;

  /// No description provided for @time.
  ///
  /// In zh, this message translates to:
  /// **'時間'**
  String get time;

  /// No description provided for @camera.
  ///
  /// In zh, this message translates to:
  /// **'相機'**
  String get camera;

  /// No description provided for @clickToUpload.
  ///
  /// In zh, this message translates to:
  /// **'點擊上傳'**
  String get clickToUpload;

  /// No description provided for @upload.
  ///
  /// In zh, this message translates to:
  /// **'上傳'**
  String get upload;

  /// No description provided for @newRecord.
  ///
  /// In zh, this message translates to:
  /// **'新增紀錄'**
  String get newRecord;

  /// No description provided for @selectRecord.
  ///
  /// In zh, this message translates to:
  /// **'選擇紀錄'**
  String get selectRecord;

  /// No description provided for @pleaseSelectRecordToUpload.
  ///
  /// In zh, this message translates to:
  /// **'請選擇欲上傳的紀錄'**
  String get pleaseSelectRecordToUpload;

  /// No description provided for @cameraIndexNumber.
  ///
  /// In zh, this message translates to:
  /// **'第幾個相機'**
  String get cameraIndexNumber;

  /// No description provided for @pleaseSelectRunnerFirst.
  ///
  /// In zh, this message translates to:
  /// **'請先選擇跑者'**
  String get pleaseSelectRunnerFirst;

  /// No description provided for @pleaseUploadAllVideos.
  ///
  /// In zh, this message translates to:
  /// **'請上傳所有視頻'**
  String get pleaseUploadAllVideos;

  /// No description provided for @noUnanalyzedRecords.
  ///
  /// In zh, this message translates to:
  /// **'目前沒有未分析的紀錄'**
  String get noUnanalyzedRecords;

  /// No description provided for @switchLens.
  ///
  /// In zh, this message translates to:
  /// **'更換鏡頭'**
  String get switchLens;

  /// No description provided for @pleaseSelectRunnerToRecord.
  ///
  /// In zh, this message translates to:
  /// **'請先選擇選手才能開始錄影'**
  String get pleaseSelectRunnerToRecord;

  /// No description provided for @camerasNotAllConnected.
  ///
  /// In zh, this message translates to:
  /// **'尚有相機未連線 (目前: {current}/{total})'**
  String camerasNotAllConnected(int current, int total);

  /// No description provided for @camerasNotAllReady.
  ///
  /// In zh, this message translates to:
  /// **'部分相機尚未橫放裝置 (未就緒)'**
  String get camerasNotAllReady;

  /// No description provided for @autoUploading.
  ///
  /// In zh, this message translates to:
  /// **'自動上傳中...'**
  String get autoUploading;

  /// No description provided for @pleaseHoldDeviceHorizontally.
  ///
  /// In zh, this message translates to:
  /// **'請橫放裝置錄製'**
  String get pleaseHoldDeviceHorizontally;

  /// No description provided for @pleaseSetAnchorFullscreen.
  ///
  /// In zh, this message translates to:
  /// **'請進入全螢幕設定錨點'**
  String get pleaseSetAnchorFullscreen;

  /// No description provided for @noVideoData.
  ///
  /// In zh, this message translates to:
  /// **'無影片資料'**
  String get noVideoData;

  /// No description provided for @analysisFailedTitle.
  ///
  /// In zh, this message translates to:
  /// **'分析失敗！'**
  String get analysisFailedTitle;

  /// No description provided for @analysisFailedDescription.
  ///
  /// In zh, this message translates to:
  /// **'此次影片分析失敗，您可以在右側操作卡片中將其刪除'**
  String get analysisFailedDescription;

  /// No description provided for @metricDistance.
  ///
  /// In zh, this message translates to:
  /// **'距離'**
  String get metricDistance;

  /// No description provided for @metricVelocity.
  ///
  /// In zh, this message translates to:
  /// **'速度'**
  String get metricVelocity;

  /// No description provided for @metricAcceleration.
  ///
  /// In zh, this message translates to:
  /// **'加速度'**
  String get metricAcceleration;

  /// No description provided for @metricDistanceUnit.
  ///
  /// In zh, this message translates to:
  /// **'距離 (m)'**
  String get metricDistanceUnit;

  /// No description provided for @metricVelocityUnit.
  ///
  /// In zh, this message translates to:
  /// **'速度 (m/s)'**
  String get metricVelocityUnit;

  /// No description provided for @metricAccelerationUnit.
  ///
  /// In zh, this message translates to:
  /// **'加速度 (m/s²)'**
  String get metricAccelerationUnit;

  /// No description provided for @timeWithUnit.
  ///
  /// In zh, this message translates to:
  /// **'時間 (s)'**
  String get timeWithUnit;

  /// No description provided for @chartKneeAngle.
  ///
  /// In zh, this message translates to:
  /// **'膝關節角度'**
  String get chartKneeAngle;

  /// No description provided for @chartHipAngle.
  ///
  /// In zh, this message translates to:
  /// **'髖關節角度'**
  String get chartHipAngle;

  /// No description provided for @chartElbowFlexion.
  ///
  /// In zh, this message translates to:
  /// **'手肘彎曲角度'**
  String get chartElbowFlexion;

  /// No description provided for @chartPelvisTorsoAngle.
  ///
  /// In zh, this message translates to:
  /// **'骨盆軀幹角度'**
  String get chartPelvisTorsoAngle;

  /// No description provided for @angleUnit.
  ///
  /// In zh, this message translates to:
  /// **'角度 (度)'**
  String get angleUnit;

  /// No description provided for @legendLeft.
  ///
  /// In zh, this message translates to:
  /// **'左側'**
  String get legendLeft;

  /// No description provided for @legendRight.
  ///
  /// In zh, this message translates to:
  /// **'右側'**
  String get legendRight;

  /// No description provided for @longJumpMode.
  ///
  /// In zh, this message translates to:
  /// **'跳遠模式'**
  String get longJumpMode;

  /// No description provided for @longJumpModeDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用錨點幾何與起跳前腳步校正偵測起跳、最長騰空及落地；錨點範圍須涵蓋跑道與沙坑'**
  String get longJumpModeDescription;

  /// No description provided for @viewUploadedVideo.
  ///
  /// In zh, this message translates to:
  /// **'查看影片'**
  String get viewUploadedVideo;

  /// No description provided for @tourStep.
  ///
  /// In zh, this message translates to:
  /// **'步驟 {current} / {total}'**
  String tourStep(int current, int total);

  /// No description provided for @tourPrevious.
  ///
  /// In zh, this message translates to:
  /// **'上一步'**
  String get tourPrevious;

  /// No description provided for @tourNext.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get tourNext;

  /// No description provided for @tourSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳過導覽'**
  String get tourSkip;

  /// No description provided for @tourFinish.
  ///
  /// In zh, this message translates to:
  /// **'完成導覽'**
  String get tourFinish;

  /// No description provided for @tourHelp.
  ///
  /// In zh, this message translates to:
  /// **'操作指引'**
  String get tourHelp;

  /// No description provided for @tourReplay.
  ///
  /// In zh, this message translates to:
  /// **'重新觀看教學'**
  String get tourReplay;

  /// No description provided for @tourNavSidebarTitle.
  ///
  /// In zh, this message translates to:
  /// **'主選單導覽列'**
  String get tourNavSidebarTitle;

  /// No description provided for @tourNavSidebarDesc.
  ///
  /// In zh, this message translates to:
  /// **'可在此快速切換「跑步分析」、「影片上傳」與「同步錄影」三大功能模組。'**
  String get tourNavSidebarDesc;

  /// No description provided for @tourNavLangTitle.
  ///
  /// In zh, this message translates to:
  /// **'多國語系切換'**
  String get tourNavLangTitle;

  /// No description provided for @tourNavLangDesc.
  ///
  /// In zh, this message translates to:
  /// **'支援繁體中文與 English 即時切換，系統也會自動辨識瀏覽器預設語系。'**
  String get tourNavLangDesc;

  /// No description provided for @tourNavHelpTitle.
  ///
  /// In zh, this message translates to:
  /// **'隨時開啟操作指引'**
  String get tourNavHelpTitle;

  /// No description provided for @tourNavHelpDesc.
  ///
  /// In zh, this message translates to:
  /// **'在任何畫面點擊「❓」即可重新啟動該頁面的步驟式操作說明。'**
  String get tourNavHelpDesc;

  /// No description provided for @tourPlaybackRunnerTitle.
  ///
  /// In zh, this message translates to:
  /// **'跑者選擇與切換'**
  String get tourPlaybackRunnerTitle;

  /// No description provided for @tourPlaybackRunnerDesc.
  ///
  /// In zh, this message translates to:
  /// **'點擊此處可下拉選擇欲查看的跑者，並載入該跑者的所有歷史分析紀錄。'**
  String get tourPlaybackRunnerDesc;

  /// No description provided for @tourPlaybackSidebarToggleTitle.
  ///
  /// In zh, this message translates to:
  /// **'側邊欄收摺與展開'**
  String get tourPlaybackSidebarToggleTitle;

  /// No description provided for @tourPlaybackSidebarToggleDesc.
  ///
  /// In zh, this message translates to:
  /// **'點擊此圖示按鈕可快速收摺或展開左側的歷史分析紀錄面板，釋放更多空間以檢視影像與圖表。'**
  String get tourPlaybackSidebarToggleDesc;

  /// No description provided for @tourPlaybackHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'歷史紀錄列表'**
  String get tourPlaybackHistoryTitle;

  /// No description provided for @tourPlaybackHistoryDesc.
  ///
  /// In zh, this message translates to:
  /// **'列出該跑者的所有跑步分析場次，點擊可切換至不同紀錄。'**
  String get tourPlaybackHistoryDesc;

  /// No description provided for @tourPlaybackMobileRecordTitle.
  ///
  /// In zh, this message translates to:
  /// **'開啟歷史紀錄選單'**
  String get tourPlaybackMobileRecordTitle;

  /// No description provided for @tourPlaybackMobileRecordDesc.
  ///
  /// In zh, this message translates to:
  /// **'點擊此卡片可開啟該跑者的歷史分析紀錄列表，切換至不同紀錄場次。'**
  String get tourPlaybackMobileRecordDesc;

  /// No description provided for @tourPlaybackPlayerTitle.
  ///
  /// In zh, this message translates to:
  /// **'連續跑步影像播放器'**
  String get tourPlaybackPlayerTitle;

  /// No description provided for @tourPlaybackPlayerDesc.
  ///
  /// In zh, this message translates to:
  /// **'依序串接各相機機位的連續跑步動態影像，拖曳時間軸可與運動學圖表即時連動同步分析。'**
  String get tourPlaybackPlayerDesc;

  /// No description provided for @tourPlaybackInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'動作與統計資訊'**
  String get tourPlaybackInfoTitle;

  /// No description provided for @tourPlaybackInfoDesc.
  ///
  /// In zh, this message translates to:
  /// **'呈現步頻、步幅、平均速度、總時間等關鍵數據與分析狀態。'**
  String get tourPlaybackInfoDesc;

  /// No description provided for @tourPlaybackChartsTitle.
  ///
  /// In zh, this message translates to:
  /// **'運動學指標與關節角度圖表'**
  String get tourPlaybackChartsTitle;

  /// No description provided for @tourPlaybackChartsDesc.
  ///
  /// In zh, this message translates to:
  /// **'包含距離、速度、加速度與各關節（膝/髖/手肘/軀幹）隨時間變化的波形曲線，支援點擊展開收摺與懸浮數值查看。'**
  String get tourPlaybackChartsDesc;

  /// No description provided for @tourPlaybackActionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'操作功能與報表匯出'**
  String get tourPlaybackActionsTitle;

  /// No description provided for @tourPlaybackActionsDesc.
  ///
  /// In zh, this message translates to:
  /// **'提供下載 PDF 跑步分析綜合報告、匯出 CSV 關節運動學原始數據，以及刪除此筆分析場次的功能。'**
  String get tourPlaybackActionsDesc;

  /// No description provided for @tourRecordMasterTitle.
  ///
  /// In zh, this message translates to:
  /// **'主控端：建立房間'**
  String get tourRecordMasterTitle;

  /// No description provided for @tourRecordMasterDesc.
  ///
  /// In zh, this message translates to:
  /// **'欲作為總控制端的裝置，在此設定預期參與的相機總數 (1~5 台)，點擊「建立錄影房間」生成專屬房號。'**
  String get tourRecordMasterDesc;

  /// No description provided for @tourRecordSlaveTitle.
  ///
  /// In zh, this message translates to:
  /// **'從機端：加入房間與機位'**
  String get tourRecordSlaveTitle;

  /// No description provided for @tourRecordSlaveDesc.
  ///
  /// In zh, this message translates to:
  /// **'作為各視角相機的從機裝置，在此輸入主控端生成的房號並選擇負責的相機機位（如相機 2）後加入房間。'**
  String get tourRecordSlaveDesc;

  /// No description provided for @tourRecordConfigTitle.
  ///
  /// In zh, this message translates to:
  /// **'主控端：參數配置與跑者設定'**
  String get tourRecordConfigTitle;

  /// No description provided for @tourRecordConfigDesc.
  ///
  /// In zh, this message translates to:
  /// **'主控端可指定跑者、預期相機總數 (1~5 台)、幀率 (FPS) 與備註資訊。'**
  String get tourRecordConfigDesc;

  /// No description provided for @tourRecordLocalTitle.
  ///
  /// In zh, this message translates to:
  /// **'主控端：本機鏡頭錄影'**
  String get tourRecordLocalTitle;

  /// No description provided for @tourRecordLocalDesc.
  ///
  /// In zh, this message translates to:
  /// **'主控端亦可作為其中一台相機機位參與錄影，開啟開關後可指派主控端鏡頭所負責的相機機位編號。'**
  String get tourRecordLocalDesc;

  /// No description provided for @tourRecordDevicesTitle.
  ///
  /// In zh, this message translates to:
  /// **'連線設備清單與機位就緒'**
  String get tourRecordDevicesTitle;

  /// No description provided for @tourRecordDevicesDesc.
  ///
  /// In zh, this message translates to:
  /// **'即時監控主控端與所有從機連線狀態。各相機裝置將手機水平橫放並完成跑道校正後，即會亮起綠燈代表已就緒。'**
  String get tourRecordDevicesDesc;

  /// No description provided for @tourRecordCameraTitle.
  ///
  /// In zh, this message translates to:
  /// **'相機即時預覽與進入全螢幕'**
  String get tourRecordCameraTitle;

  /// No description provided for @tourRecordCameraDesc.
  ///
  /// In zh, this message translates to:
  /// **'呈現即時相機畫面，支援鏡頭切換與變焦拉桿。點擊右上角全螢幕按鈕即可放大進入全螢幕畫面。'**
  String get tourRecordCameraDesc;

  /// No description provided for @tourRecordAnchorToggleTitle.
  ///
  /// In zh, this message translates to:
  /// **'全螢幕相機與啟動錨點設定'**
  String get tourRecordAnchorToggleTitle;

  /// No description provided for @tourRecordAnchorToggleDesc.
  ///
  /// In zh, this message translates to:
  /// **'進入全螢幕相機後，點擊左上角「設定錨點」按鈕，系統將自動擷取即時畫面並進入跑道空間校正模式。'**
  String get tourRecordAnchorToggleDesc;

  /// No description provided for @tourRecordAnchorPointsTitle.
  ///
  /// In zh, this message translates to:
  /// **'跑道六點空間校正'**
  String get tourRecordAnchorPointsTitle;

  /// No description provided for @tourRecordAnchorPointsDesc.
  ///
  /// In zh, this message translates to:
  /// **'在凍結畫面上依序點擊標記跑道四角點與中線點（或直接拖曳既有錨點進行微調），確認 6 點標註完成後點擊「確認錨點」。'**
  String get tourRecordAnchorPointsDesc;

  /// No description provided for @tourRecordAnchorPointsDescMobile.
  ///
  /// In zh, this message translates to:
  /// **'點選下方「點 1 (左上)」至「點 6 (中下)」錨點按鈕切換目標，在全螢幕畫面上點擊或拖曳以精確標註跑道 6 個錨點，完成後點擊「確認錨點」。'**
  String get tourRecordAnchorPointsDescMobile;

  /// No description provided for @tourRecordDistanceDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'設定跑道實際物理長度'**
  String get tourRecordDistanceDialogTitle;

  /// No description provided for @tourRecordDistanceDialogDesc.
  ///
  /// In zh, this message translates to:
  /// **'在此對話框中輸入跑道頂部（左至中）與底部（中至右）的真實公尺距離，點擊「套用並儲存」建立精確空間坐標系。'**
  String get tourRecordDistanceDialogDesc;

  /// No description provided for @tourRecordFullscreenRecordTitle.
  ///
  /// In zh, this message translates to:
  /// **'主控端：全螢幕同步錄影'**
  String get tourRecordFullscreenRecordTitle;

  /// No description provided for @tourRecordFullscreenRecordDesc.
  ///
  /// In zh, this message translates to:
  /// **'主控端在全螢幕相機畫面下，亦可直接點擊右下角的紅色錄影按鈕啟動所有相機同步錄影，無需返回房間主畫面。'**
  String get tourRecordFullscreenRecordDesc;

  /// No description provided for @tourRecordAnchorDoneTitle.
  ///
  /// In zh, this message translates to:
  /// **'校正完成與返回房間'**
  String get tourRecordAnchorDoneTitle;

  /// No description provided for @tourRecordAnchorDoneDesc.
  ///
  /// In zh, this message translates to:
  /// **'儲存後畫面回復即時相機預覽，左上角顯示綠色「錨點已設定」標籤。點擊右上角按鈕即可離開全螢幕返回房間。'**
  String get tourRecordAnchorDoneDesc;

  /// No description provided for @tourRecordButtonTitle.
  ///
  /// In zh, this message translates to:
  /// **'從機控制權與一鍵同步錄影'**
  String get tourRecordButtonTitle;

  /// No description provided for @tourRecordButtonDesc.
  ///
  /// In zh, this message translates to:
  /// **'從機可隨時點擊「請求控制權」升級為主控端。全員就緒後由主控端一鍵發送同步錄影指令，錄影結束後所有相機並行自動上傳！'**
  String get tourRecordButtonDesc;

  /// No description provided for @tourRecordMasterButtonTitle.
  ///
  /// In zh, this message translates to:
  /// **'主控端：一鍵同步錄影與並行上傳'**
  String get tourRecordMasterButtonTitle;

  /// No description provided for @tourRecordMasterButtonDesc.
  ///
  /// In zh, this message translates to:
  /// **'待所有機位設備皆完成校正並就緒（綠燈），由主控端點擊紅色「開始錄影」按鈕即可同步啟動所有相機，錄影結束後全機位自動並行上傳！'**
  String get tourRecordMasterButtonDesc;

  /// No description provided for @tourRecordSlaveButtonTitle.
  ///
  /// In zh, this message translates to:
  /// **'從機端：等待指令與請求控制權'**
  String get tourRecordSlaveButtonTitle;

  /// No description provided for @tourRecordSlaveButtonDesc.
  ///
  /// In zh, this message translates to:
  /// **'從機端將等待主控端發送同步錄影指令；若現場有需求，從機亦可點擊「請求控制權」升級為主控端接管全場控制！'**
  String get tourRecordSlaveButtonDesc;

  /// No description provided for @tourRecordSlaveCameraPosTitle.
  ///
  /// In zh, this message translates to:
  /// **'從機端：更改相機機位'**
  String get tourRecordSlaveCameraPosTitle;

  /// No description provided for @tourRecordSlaveCameraPosDesc.
  ///
  /// In zh, this message translates to:
  /// **'從機加入房間後，若需切換負責的相機視角（例如改為相機 3），可在此下拉選單隨時切換，系統將即時同步更新機位配置。'**
  String get tourRecordSlaveCameraPosDesc;

  /// No description provided for @tourRecordRequestControlTitle.
  ///
  /// In zh, this message translates to:
  /// **'從機端：請求主控權'**
  String get tourRecordRequestControlTitle;

  /// No description provided for @tourRecordRequestControlDesc.
  ///
  /// In zh, this message translates to:
  /// **'從機端完成空間校正並確認就緒後，將等待主控端發送錄影指令；若現場需要變更操作者，可點擊此按鈕向主控端「請求控制權」，經主控端確認同意後即可接管房間轉為主控端身份。'**
  String get tourRecordRequestControlDesc;

  /// No description provided for @tourRecordLeaveRoomTitle.
  ///
  /// In zh, this message translates to:
  /// **'離開房間'**
  String get tourRecordLeaveRoomTitle;

  /// No description provided for @tourRecordLeaveRoomDesc.
  ///
  /// In zh, this message translates to:
  /// **'點擊此按鈕可中斷目前房間連線並返回錄影首頁。若為主控端離開將會結束該房間連線，從機端離開則僅退出本機連線。'**
  String get tourRecordLeaveRoomDesc;

  /// No description provided for @tourRecordChoicePrompt.
  ///
  /// In zh, this message translates to:
  /// **'請選擇欲說明的流程：'**
  String get tourRecordChoicePrompt;

  /// No description provided for @tourRecordChoiceBoth.
  ///
  /// In zh, this message translates to:
  /// **'兩者皆看'**
  String get tourRecordChoiceBoth;

  /// No description provided for @tourRecordChoiceMaster.
  ///
  /// In zh, this message translates to:
  /// **'僅看「主控端」'**
  String get tourRecordChoiceMaster;

  /// No description provided for @tourRecordChoiceSlave.
  ///
  /// In zh, this message translates to:
  /// **'僅看「從機端 (Slave)」'**
  String get tourRecordChoiceSlave;

  /// No description provided for @tourRecordRoomInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'房間號碼與目前身分'**
  String get tourRecordRoomInfoTitle;

  /// No description provided for @tourRecordRoomInfoDesc.
  ///
  /// In zh, this message translates to:
  /// **'進入房間後，頂部清楚標示當前專屬「房間號碼」（提供其他相機裝置輸入加入）以及本機在此房間中的「目前身分」（主控端或從機端）。'**
  String get tourRecordRoomInfoDesc;

  /// No description provided for @tourRecordMasterRoomInfoDesc.
  ///
  /// In zh, this message translates to:
  /// **'建立房間後生成專屬「房間號碼」，並標記為「主控端」身分。其他相機裝置輸入此房號即可加入此連線房間。'**
  String get tourRecordMasterRoomInfoDesc;

  /// No description provided for @tourRecordSlaveRoomInfoDesc.
  ///
  /// In zh, this message translates to:
  /// **'成功加入房間後，頂部顯示當前連線之「房間號碼」與「從機端」身分標籤，確認已正確連入主控端所建立之錄影房間。'**
  String get tourRecordSlaveRoomInfoDesc;

  /// No description provided for @tourRecordShareTitle.
  ///
  /// In zh, this message translates to:
  /// **'邀請相機加入（QR Code 與連結）'**
  String get tourRecordShareTitle;

  /// No description provided for @tourRecordShareDesc.
  ///
  /// In zh, this message translates to:
  /// **'主控端可點擊「分享房間」產生專屬 QR Code 供其他手機掃描，或點擊「複製連結」發送加入房間網址，其他裝置開啟後將自動進入此房間進行同步錄影。'**
  String get tourRecordShareDesc;

  /// No description provided for @tourRecordInquiryTitle.
  ///
  /// In zh, this message translates to:
  /// **'請選擇欲導覽的錄影流程'**
  String get tourRecordInquiryTitle;

  /// No description provided for @tourRecordInquirySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'主控端與從機端 (Slave) 的初始操作流程不同，請選擇您欲了解的角色模式：'**
  String get tourRecordInquirySubtitle;

  /// No description provided for @tourRecordInquiryBothTitle.
  ///
  /// In zh, this message translates to:
  /// **'兩者皆看 (完整流程)'**
  String get tourRecordInquiryBothTitle;

  /// No description provided for @tourRecordInquiryBothDesc.
  ///
  /// In zh, this message translates to:
  /// **'完整檢視主控端與從機端雙方的所有操作步驟與協作流程。'**
  String get tourRecordInquiryBothDesc;

  /// No description provided for @tourRecordInquiryBothSteps.
  ///
  /// In zh, this message translates to:
  /// **'共 17 步驟'**
  String get tourRecordInquiryBothSteps;

  /// No description provided for @tourRecordInquiryMasterTitle.
  ///
  /// In zh, this message translates to:
  /// **'主控端流程 (Master)'**
  String get tourRecordInquiryMasterTitle;

  /// No description provided for @tourRecordInquiryMasterDesc.
  ///
  /// In zh, this message translates to:
  /// **'建立房間、全域參數配置、監控各機位狀態、跑道空間校正與一鍵同步錄影。'**
  String get tourRecordInquiryMasterDesc;

  /// No description provided for @tourRecordInquiryMasterSteps.
  ///
  /// In zh, this message translates to:
  /// **'共 14 步驟'**
  String get tourRecordInquiryMasterSteps;

  /// No description provided for @tourRecordInquirySlaveTitle.
  ///
  /// In zh, this message translates to:
  /// **'從機端流程 (Slave)'**
  String get tourRecordInquirySlaveTitle;

  /// No description provided for @tourRecordInquirySlaveDesc.
  ///
  /// In zh, this message translates to:
  /// **'輸入房號加入指定機位、確認設備就緒、跑道空間校正與隨時請求控制權。'**
  String get tourRecordInquirySlaveDesc;

  /// No description provided for @tourRecordInquirySlaveSteps.
  ///
  /// In zh, this message translates to:
  /// **'共 11 步驟'**
  String get tourRecordInquirySlaveSteps;

  /// No description provided for @tourRecordInquiryStartButton.
  ///
  /// In zh, this message translates to:
  /// **'開始導覽'**
  String get tourRecordInquiryStartButton;

  /// No description provided for @tourUploadTabsTitle.
  ///
  /// In zh, this message translates to:
  /// **'上傳模式選擇'**
  String get tourUploadTabsTitle;

  /// No description provided for @tourUploadTabsDesc.
  ///
  /// In zh, this message translates to:
  /// **'提供「一次上傳所有視角」（單人多機同步上傳）與「分批上傳」（各相機分別上傳或接續未完成紀錄）兩種工作模式。'**
  String get tourUploadTabsDesc;

  /// No description provided for @tourUploadRunnerTitle.
  ///
  /// In zh, this message translates to:
  /// **'跑者身分選取'**
  String get tourUploadRunnerTitle;

  /// No description provided for @tourUploadRunnerDesc.
  ///
  /// In zh, this message translates to:
  /// **'可切換「選擇現有跑者」從下拉清單快速選取，或切換「新增跑者」直接輸入跑者姓名建立新檔案。'**
  String get tourUploadRunnerDesc;

  /// No description provided for @tourUploadConfigTitle.
  ///
  /// In zh, this message translates to:
  /// **'拍攝參數與錄影配置'**
  String get tourUploadConfigTitle;

  /// No description provided for @tourUploadConfigDesc.
  ///
  /// In zh, this message translates to:
  /// **'設定影片拍攝日期與時間、預期機位總數 (1~5 台)、相機幀率 (FPS) 及相關備註資訊。'**
  String get tourUploadConfigDesc;

  /// No description provided for @tourUploadVideoTitle.
  ///
  /// In zh, this message translates to:
  /// **'影片檔案選取與預覽'**
  String get tourUploadVideoTitle;

  /// No description provided for @tourUploadVideoDesc.
  ///
  /// In zh, this message translates to:
  /// **'選取各機位所拍攝的影片檔案，支援 MP4、MOV、AVI、MKV、WebM、M4V 等多種主流格式並即時產生預覽縮圖。'**
  String get tourUploadVideoDesc;

  /// No description provided for @tourUploadAnchorTitle.
  ///
  /// In zh, this message translates to:
  /// **'跑道空間錨點校正'**
  String get tourUploadAnchorTitle;

  /// No description provided for @tourUploadAnchorDesc.
  ///
  /// In zh, this message translates to:
  /// **'於影片首幀依序點擊標註跑道四角點（左上、右上、右下、左下）並輸入實際公尺距離，建立精準空間坐標系（中線點自動計算產生，亦可拖曳微調）。'**
  String get tourUploadAnchorDesc;

  /// No description provided for @tourUploadAnchorDescMobile.
  ///
  /// In zh, this message translates to:
  /// **'點選下方「點 1 (左上)」至「點 6 (中下)」按鈕選定目標錨點，於影片畫面上點擊或拖曳標註跑道各點，並輸入實際公尺距離以建立空間坐標系。'**
  String get tourUploadAnchorDescMobile;

  /// No description provided for @tourUploadSubmitTitle.
  ///
  /// In zh, this message translates to:
  /// **'上傳並啟動 AI 分析'**
  String get tourUploadSubmitTitle;

  /// No description provided for @tourUploadSubmitDesc.
  ///
  /// In zh, this message translates to:
  /// **'點擊後將影片與錨點資料提交至後端，自動執行骨架追蹤、姿勢估計與運動學運算流水線。'**
  String get tourUploadSubmitDesc;

  /// No description provided for @tourUploadSepTabsTitle.
  ///
  /// In zh, this message translates to:
  /// **'分批工作模式切換'**
  String get tourUploadSepTabsTitle;

  /// No description provided for @tourUploadSepTabsDesc.
  ///
  /// In zh, this message translates to:
  /// **'分批上傳提供「新增紀錄」（建立全新場次）與「選擇紀錄」（接續未完成場次）兩種途徑。可點選下方選項切換流程，點擊「下一步」開始導覽。'**
  String get tourUploadSepTabsDesc;

  /// No description provided for @tourUploadSepNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'新增紀錄（拍攝參數設定）'**
  String get tourUploadSepNewTitle;

  /// No description provided for @tourUploadSepNewDesc.
  ///
  /// In zh, this message translates to:
  /// **'設定全新場次的錄製日期與時間、預期相機總數 (1~5 台)、FPS 與備註，從第 1 台相機開始依序上傳。'**
  String get tourUploadSepNewDesc;

  /// No description provided for @tourUploadSepSelectTitle.
  ///
  /// In zh, this message translates to:
  /// **'選擇紀錄（接續未完成場次）'**
  String get tourUploadSepSelectTitle;

  /// No description provided for @tourUploadSepSelectDesc.
  ///
  /// In zh, this message translates to:
  /// **'列出該跑者先前尚未上傳齊全的歷史場次（如已傳機位 1、尚缺機位 2 與 3），選取後即可接續補傳剩餘機位。'**
  String get tourUploadSepSelectDesc;

  /// No description provided for @tourUploadSepCameraTitle.
  ///
  /// In zh, this message translates to:
  /// **'當前相機機位選取'**
  String get tourUploadSepCameraTitle;

  /// No description provided for @tourUploadSepCameraDesc.
  ///
  /// In zh, this message translates to:
  /// **'從下拉選單切換目前欲上傳的相機編號（如相機 1 至相機 5）。'**
  String get tourUploadSepCameraDesc;

  /// No description provided for @tourUploadSepVideoTitle.
  ///
  /// In zh, this message translates to:
  /// **'單機位影片檔案選取'**
  String get tourUploadSepVideoTitle;

  /// No description provided for @tourUploadSepVideoDesc.
  ///
  /// In zh, this message translates to:
  /// **'點擊選取或拖曳該機位所對應的影片檔案，支援 MP4、MOV、AVI 等主流格式並預覽首幀縮圖。'**
  String get tourUploadSepVideoDesc;

  /// No description provided for @tourUploadSepSubmitTitle.
  ///
  /// In zh, this message translates to:
  /// **'分批提交與分析啟動'**
  String get tourUploadSepSubmitTitle;

  /// No description provided for @tourUploadSepSubmitDesc.
  ///
  /// In zh, this message translates to:
  /// **'點擊上傳目前機位影片；待所有機位影片皆上傳完畢後，系統將自動合併並啟動 AI 運動學分析。'**
  String get tourUploadSepSubmitDesc;

  /// No description provided for @tourUploadSepChoicePrompt.
  ///
  /// In zh, this message translates to:
  /// **'請選擇欲說明的流程：'**
  String get tourUploadSepChoicePrompt;

  /// No description provided for @tourUploadSepChoiceBoth.
  ///
  /// In zh, this message translates to:
  /// **'兩者皆看'**
  String get tourUploadSepChoiceBoth;

  /// No description provided for @tourUploadSepChoiceNew.
  ///
  /// In zh, this message translates to:
  /// **'僅看「新增紀錄」'**
  String get tourUploadSepChoiceNew;

  /// No description provided for @tourUploadSepChoiceSelect.
  ///
  /// In zh, this message translates to:
  /// **'僅看「選擇紀錄」'**
  String get tourUploadSepChoiceSelect;

  /// No description provided for @uncompletedRecordsPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'未分析歷史紀錄'**
  String get uncompletedRecordsPlaceholder;

  /// No description provided for @shareRoom.
  ///
  /// In zh, this message translates to:
  /// **'分享房間'**
  String get shareRoom;

  /// No description provided for @copyLink.
  ///
  /// In zh, this message translates to:
  /// **'複製連結'**
  String get copyLink;

  /// No description provided for @copyJoinLink.
  ///
  /// In zh, this message translates to:
  /// **'複製加入連結'**
  String get copyJoinLink;

  /// No description provided for @joinLinkCopied.
  ///
  /// In zh, this message translates to:
  /// **'已複製房間加入連結！'**
  String get joinLinkCopied;

  /// No description provided for @showJoinQrCode.
  ///
  /// In zh, this message translates to:
  /// **'顯示 QR Code'**
  String get showJoinQrCode;

  /// No description provided for @inviteDeviceTitle.
  ///
  /// In zh, this message translates to:
  /// **'邀請相機裝置加入'**
  String get inviteDeviceTitle;

  /// No description provided for @inviteDeviceSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用手機相機掃描下方 QR Code，或透過分享連結直接加入此房間'**
  String get inviteDeviceSubtitle;

  /// No description provided for @roomJoinUrl.
  ///
  /// In zh, this message translates to:
  /// **'加入連結'**
  String get roomJoinUrl;

  /// No description provided for @autoFilledRoomNumber.
  ///
  /// In zh, this message translates to:
  /// **'已自動帶入房間號碼'**
  String get autoFilledRoomNumber;

  /// No description provided for @deepLinkAppFallbackHint.
  ///
  /// In zh, this message translates to:
  /// **'若裝置已安裝 App 將優先自動開啟 App，若未安裝則由瀏覽器開啟網頁版。'**
  String get deepLinkAppFallbackHint;

  /// No description provided for @enterSessionCodeOrLink.
  ///
  /// In zh, this message translates to:
  /// **'輸入補傳代碼或貼上連結'**
  String get enterSessionCodeOrLink;

  /// No description provided for @sessionCodeInputHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入 Session ID 或貼上完整連結'**
  String get sessionCodeInputHint;

  /// No description provided for @loadSession.
  ///
  /// In zh, this message translates to:
  /// **'載入'**
  String get loadSession;

  /// No description provided for @loadSessionFailed.
  ///
  /// In zh, this message translates to:
  /// **'找不到此待補傳紀錄或該紀錄已分析完成'**
  String get loadSessionFailed;

  /// No description provided for @loadSessionSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已成功載入待補傳紀錄！'**
  String get loadSessionSuccess;

  /// No description provided for @copySessionCode.
  ///
  /// In zh, this message translates to:
  /// **'複製補傳代碼'**
  String get copySessionCode;

  /// No description provided for @copySessionLink.
  ///
  /// In zh, this message translates to:
  /// **'複製補傳連結'**
  String get copySessionLink;

  /// No description provided for @sessionCodeCopied.
  ///
  /// In zh, this message translates to:
  /// **'已複製補傳代碼！'**
  String get sessionCodeCopied;

  /// No description provided for @sessionLinkCopied.
  ///
  /// In zh, this message translates to:
  /// **'已複製補傳連結！'**
  String get sessionLinkCopied;

  /// No description provided for @sharedSessionBadge.
  ///
  /// In zh, this message translates to:
  /// **'外部協同補傳'**
  String get sharedSessionBadge;

  /// No description provided for @allCamerasUploadedExternalNotice.
  ///
  /// In zh, this message translates to:
  /// **'所有相機影片已全數上傳完畢！系統已自動為房主啟動 AI 運動學分析。'**
  String get allCamerasUploadedExternalNotice;

  /// No description provided for @uploadSuccessNotice.
  ///
  /// In zh, this message translates to:
  /// **'上傳完成通知'**
  String get uploadSuccessNotice;

  /// No description provided for @sessionLoadedBannerTitle.
  ///
  /// In zh, this message translates to:
  /// **'已載入外部補傳紀錄'**
  String get sessionLoadedBannerTitle;

  /// No description provided for @sessionLoadedBannerSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'選手：{runnerName} ｜ 缺機位：{missingCameras}'**
  String sessionLoadedBannerSubtitle(String runnerName, String missingCameras);

  /// No description provided for @missingCameras.
  ///
  /// In zh, this message translates to:
  /// **'缺相機 {cameras}'**
  String missingCameras(String cameras);

  /// No description provided for @selectRunnerOrEnterCodePrompt.
  ///
  /// In zh, this message translates to:
  /// **'請先選擇跑者，或於上方輸入補傳代碼/連結'**
  String get selectRunnerOrEnterCodePrompt;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
