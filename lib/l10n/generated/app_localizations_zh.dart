// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '百米分析';

  @override
  String get confirm => '確認';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';

  @override
  String get delete => '刪除';

  @override
  String get edit => '編輯';

  @override
  String get close => '關閉';

  @override
  String get actions => '操作';

  @override
  String get notes => '備註';

  @override
  String get noNotes => '無備註';

  @override
  String get language => '語言';

  @override
  String get chinese => '繁體中文';

  @override
  String get english => 'English';

  @override
  String get switchLanguage => '切換語言';

  @override
  String get navRecord => '錄影';

  @override
  String get navUpload => '上傳';

  @override
  String get navPlayback => '回放';

  @override
  String get navSupport => '支援';

  @override
  String get navPolicy => '隱私權政策';

  @override
  String get navLogout => '登出';

  @override
  String get logoutConfirmTitle => '確認登出';

  @override
  String get logoutConfirmMessage => '您確定要登出系統嗎？';

  @override
  String get login => '登入';

  @override
  String get register => '註冊';

  @override
  String get username => '使用者名稱';

  @override
  String get usernameHint => '請輸入使用者名稱';

  @override
  String get password => '密碼';

  @override
  String get passwordHint => '請輸入密碼';

  @override
  String get confirmPassword => '確認密碼';

  @override
  String get confirmPasswordHint => '請再次輸入密碼';

  @override
  String get rememberMe => '記住我';

  @override
  String get dontHaveAccount => '還沒有帳號？立即註冊';

  @override
  String get alreadyHaveAccount => '已有帳號？立即登入';

  @override
  String get passwordsDoNotMatch => '兩次輸入的密碼不一致';

  @override
  String get loginFailed => '登入失敗';

  @override
  String get registerFailed => '註冊失敗';

  @override
  String get loginSuccess => '登入成功';

  @override
  String get registerSuccess => '註冊成功';

  @override
  String get selectRunner => '選擇選手';

  @override
  String get searchRunner => '搜尋選手...';

  @override
  String get addRunner => '新增選手';

  @override
  String get runnerName => '選手姓名';

  @override
  String get enterRunnerName => '請輸入選手姓名';

  @override
  String get analysisHistory => '歷史分析紀錄';

  @override
  String get noHistoryFound => '暫無分析紀錄';

  @override
  String get cameras => '相機';

  @override
  String get statusDone => '已完成';

  @override
  String get statusProcessing => '處理中';

  @override
  String get statusFailed => '失敗';

  @override
  String get statusPending => '待處理';

  @override
  String get sessionInfo => '跑步資訊';

  @override
  String get analysisStatus => '分析狀態';

  @override
  String get dateTime => '日期時間';

  @override
  String get cameraCount => '相機數量';

  @override
  String get totalTime => '總時間';

  @override
  String get avgVelocity => '平均速度';

  @override
  String get avgAcceleration => '平均加速度';

  @override
  String get avgStepLength => '平均步幅';

  @override
  String get unitSeconds => '秒';

  @override
  String get unitMps => '公尺/秒';

  @override
  String get unitMps2 => '公尺/秒²';

  @override
  String get unitMeters => '公尺';

  @override
  String get downloadPdfReport => '下載 PDF 報告';

  @override
  String get downloadCsvData => '下載 CSV 數據';

  @override
  String get deleteSessionConfirmTitle => '刪除分析紀錄';

  @override
  String get deleteSessionConfirmMessage => '確認要刪除此筆分析紀錄嗎？此動作無法復原。';

  @override
  String get tabOverallPerformance => '運動學指標';

  @override
  String get tabJointAngles => '關節角度';

  @override
  String get tabSymmetry => '左右腳步對稱';

  @override
  String get noChartData => '暫無圖表資料';

  @override
  String get deleteRunnerConfirmTitle => '刪除選手';

  @override
  String deleteRunnerConfirmMessage(String name) {
    return '確認要刪除選手「$name」及其所有紀錄嗎？';
  }

  @override
  String get recordControl => '錄影控制';

  @override
  String get cameraSettings => '相機設定';

  @override
  String get fps => 'FPS';

  @override
  String get countdownTimer => '倒數計時';

  @override
  String get startRecording => '開始錄影';

  @override
  String get stopRecording => '停止錄影';

  @override
  String get cameraStatusReady => '就緒';

  @override
  String get cameraStatusNotReady => '尚未就緒';

  @override
  String get recaptureSnapshot => '📷 重新擷取';

  @override
  String get setAnchor => '設置錨點';

  @override
  String get confirmAnchor => '確認錨點';

  @override
  String get clearAnchor => '清除錨點';

  @override
  String get markAllPointsPrompt => '請先標註完所有 6 個錨點';

  @override
  String get distanceDialogTitle => '實際距離設定 (公尺)';

  @override
  String get distanceDialogSubtitle => '請輸入兩段跑道縱向距離與跑道寬度，以進行精確公尺換算：';

  @override
  String get distanceLeftToCenter => '左線 (1-4) 至中線 (5-6) 縱向距離 (m)';

  @override
  String get distanceCenterToRight => '中線 (5-6) 至右線 (2-3) 縱向距離 (m)';

  @override
  String get runwayWidth => '跑道寬度 (m)';

  @override
  String get distanceInvalidPrompt => '請輸入大於 0 的有效數值';

  @override
  String get applyAndSave => '確認並套用';

  @override
  String get dragToAdjust => '拖曳以調整位置';

  @override
  String get tapToMarkPoint => '點擊或滑動以標註';

  @override
  String get point1 => '點 1 (左上)';

  @override
  String get point2 => '點 2 (右上)';

  @override
  String get point3 => '點 3 (右下)';

  @override
  String get point4 => '點 4 (左下)';

  @override
  String get point5 => '點 5 (中上)';

  @override
  String get point6 => '點 6 (中下)';

  @override
  String get cameraNotAssigned => '尚未分配相機編號';

  @override
  String get orientationLandscapeRequired => '請將手機橫放以開始錄影';

  @override
  String get connectedStatus => '連線狀態';

  @override
  String get controlGranted => '已取得控制權';

  @override
  String get controlDenied => '要求控制權被拒絕';

  @override
  String connectionError(String error) {
    return '連線錯誤: $error';
  }

  @override
  String get connectionDisconnected => '連線已斷開';

  @override
  String get tabUploadAll => '一次性上傳';

  @override
  String get tabUploadSeparately => '分批上傳';

  @override
  String get tabUnanalyzedHistory => '未分析歷史';

  @override
  String get basicInfo => '基本資訊';

  @override
  String get selectRunnerRequired => '請選擇選手';

  @override
  String get selectDate => '選擇日期';

  @override
  String get uploadAndAnalyze => '上傳並分析';

  @override
  String get selectVideo => '選擇影片';

  @override
  String get videoSelected => '已選擇影片';

  @override
  String get anchorSet => '錨點已設定';

  @override
  String get anchorNotSet => '尚未設定錨點';

  @override
  String get mustSetAnchorsForAllCameras => '請先設置所有相機的錨點';

  @override
  String get selectVideoFirst => '請先上傳影片';

  @override
  String get uploading => '上傳中...';

  @override
  String get uploadSuccess => '上傳成功';

  @override
  String get uploadFailed => '上傳失敗';

  @override
  String anchorDialogTitle(int index) {
    return '設置錨點 (相機 $index)';
  }

  @override
  String get selectAnchorToMark => '選擇要標註的錨點：';

  @override
  String get leftStart => '左上';

  @override
  String get rightStart => '右上';

  @override
  String get rightEnd => '右下';

  @override
  String get leftEnd => '左下';

  @override
  String get centerStart => '中上';

  @override
  String get centerEnd => '中下';

  @override
  String get undo => '上一步';

  @override
  String get clear => '清除';

  @override
  String get magnifier => '放大鏡';

  @override
  String get guide => '標註指引';

  @override
  String get guideDescription =>
      '請依序標註跑道四角點（左上、右上、右下、左下），中線起點與終點將自動計算，亦可點擊或拖曳微調。';

  @override
  String get noUnanalyzedSessions => '暫無未分析紀錄';

  @override
  String get startAnalysis => '開始分析';

  @override
  String get deleteUnanalyzedConfirm => '確認要刪除此筆未分析紀錄嗎？';

  @override
  String get progressTranscode => '影片轉檔完成';

  @override
  String get progressTracking => '影片追蹤 (Tracking) 完成';

  @override
  String get progressPose => '姿勢估計 (Pose Estimation) 完成';

  @override
  String get progressPostProcessing => '資料後處理完成';

  @override
  String get progressSaved => '全部結束並存檔';

  @override
  String get supportTitle => '聯絡與技術支援';

  @override
  String get supportSubtitle => '如有任何系統使用問題或反饋，歡迎隨時與我們聯繫。';

  @override
  String get contactEmail => '支援信箱';

  @override
  String get systemVersion => '系統版本';

  @override
  String get policyTitle => '隱私權政策';

  @override
  String get policyLastUpdated => '最後更新日期';

  @override
  String get masterDevice => '主控裝置';

  @override
  String get masterDeviceDescription => '負責控制所有裝置的開始與結束錄影';

  @override
  String get expectedDeviceCount => '預計連線裝置數: ';

  @override
  String get createRecordingRoom => '建立錄影房間';

  @override
  String get orDivider => '或';

  @override
  String get slaveDevice => '錄影手機';

  @override
  String get enterRoomNumber => '輸入房間號碼';

  @override
  String get selectCameraPosition => '選擇相機位置';

  @override
  String get joinRecordingRoom => '加入錄影房間';

  @override
  String get roomNumber => '房間號碼';

  @override
  String get currentRole => '目前身份';

  @override
  String get roleMaster => '主控端 (Master)';

  @override
  String get roleSlave => '錄影端 (Slave)';

  @override
  String get localRecording => '本機參與錄影';

  @override
  String get changeCameraPosition => '更改相機位置:';

  @override
  String get connectedDevices => '已連線設備清單:';

  @override
  String get waitingForConnection => '等待連線中...';

  @override
  String get roomHost => '房主';

  @override
  String get recordingInProgress => '正在錄影中...';

  @override
  String get stopRecordingAndUpload => '停止錄影並上傳';

  @override
  String get startSyncRecording => '開始同步錄影';

  @override
  String get requestControl => '要求主控權';

  @override
  String get takeControl => '取得主控權';

  @override
  String get waitingForControlApproval => '等待房主審核中...';

  @override
  String get leaveRoom => '離開房間';

  @override
  String get controlTransferRequest => '主控權轉移要求';

  @override
  String controlTransferMessage(String id) {
    return '設備 $id 正在要求此房間的主控權，您同意轉移嗎？';
  }

  @override
  String get approve => '同意';

  @override
  String get reject => '拒絕';

  @override
  String get uploadSeparately => '分別上傳';

  @override
  String get uploadAll => '一起上傳';

  @override
  String get date => '日期';

  @override
  String get time => '時間';

  @override
  String get camera => '相機';

  @override
  String get clickToUpload => '點擊上傳';

  @override
  String get upload => '上傳';

  @override
  String get newRecord => '新增紀錄';

  @override
  String get selectRecord => '選擇紀錄';

  @override
  String get pleaseSelectRecordToUpload => '請選擇欲上傳的紀錄';

  @override
  String get cameraIndexNumber => '第幾個相機';

  @override
  String get pleaseSelectRunnerFirst => '請先選擇跑者';

  @override
  String get pleaseUploadAllVideos => '請上傳所有視頻';

  @override
  String get noUnanalyzedRecords => '目前沒有未分析的紀錄';

  @override
  String get switchLens => '更換鏡頭';

  @override
  String get pleaseSelectRunnerToRecord => '請先選擇選手才能開始錄影';

  @override
  String camerasNotAllConnected(int current, int total) {
    return '尚有相機未連線 (目前: $current/$total)';
  }

  @override
  String get camerasNotAllReady => '部分相機尚未橫放裝置 (未就緒)';

  @override
  String get autoUploading => '自動上傳中...';

  @override
  String get pleaseHoldDeviceHorizontally => '請橫放裝置錄製';

  @override
  String get pleaseSetAnchorFullscreen => '請進入全螢幕設定錨點';

  @override
  String get noVideoData => '無影片資料';

  @override
  String get analysisFailedTitle => '分析失敗！';

  @override
  String get analysisFailedDescription => '此次影片分析失敗，您可以在右側操作卡片中將其刪除';

  @override
  String get metricDistance => '距離';

  @override
  String get metricVelocity => '速度';

  @override
  String get metricAcceleration => '加速度';

  @override
  String get metricDistanceUnit => '距離 (m)';

  @override
  String get metricVelocityUnit => '速度 (m/s)';

  @override
  String get metricAccelerationUnit => '加速度 (m/s²)';

  @override
  String get timeWithUnit => '時間 (s)';

  @override
  String get chartKneeAngle => '膝關節角度';

  @override
  String get chartHipAngle => '髖關節角度';

  @override
  String get chartElbowFlexion => '手肘彎曲角度';

  @override
  String get chartPelvisTorsoAngle => '骨盆軀幹角度';

  @override
  String get angleUnit => '角度 (度)';

  @override
  String get legendLeft => '左側';

  @override
  String get legendRight => '右側';

  @override
  String get longJumpMode => '跳遠模式';

  @override
  String get longJumpModeDescription =>
      '使用錨點幾何與起跳前腳步校正偵測起跳、最長騰空及落地；錨點範圍須涵蓋跑道與沙坑';

  @override
  String get viewUploadedVideo => '查看影片';
}
