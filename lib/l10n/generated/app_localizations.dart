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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

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
  /// **'點 1 (左起)'**
  String get point1;

  /// No description provided for @point2.
  ///
  /// In zh, this message translates to:
  /// **'點 2 (右起)'**
  String get point2;

  /// No description provided for @point3.
  ///
  /// In zh, this message translates to:
  /// **'點 3 (右終)'**
  String get point3;

  /// No description provided for @point4.
  ///
  /// In zh, this message translates to:
  /// **'點 4 (左終)'**
  String get point4;

  /// No description provided for @point5.
  ///
  /// In zh, this message translates to:
  /// **'點 5 (中起)'**
  String get point5;

  /// No description provided for @point6.
  ///
  /// In zh, this message translates to:
  /// **'點 6 (中終)'**
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
  /// **'左起點'**
  String get leftStart;

  /// No description provided for @rightStart.
  ///
  /// In zh, this message translates to:
  /// **'右起點'**
  String get rightStart;

  /// No description provided for @rightEnd.
  ///
  /// In zh, this message translates to:
  /// **'右終點'**
  String get rightEnd;

  /// No description provided for @leftEnd.
  ///
  /// In zh, this message translates to:
  /// **'左終點'**
  String get leftEnd;

  /// No description provided for @centerStart.
  ///
  /// In zh, this message translates to:
  /// **'中起點'**
  String get centerStart;

  /// No description provided for @centerEnd.
  ///
  /// In zh, this message translates to:
  /// **'中終點'**
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
  /// **'請依序標註跑道四角點（左起、右起、右終、左終），中線起點與終點將自動計算，亦可點擊或拖曳微調。'**
  String get guideDescription;

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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

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
