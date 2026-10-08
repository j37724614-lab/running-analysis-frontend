// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '跳遠分析';

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
  String get guideDescription => '依序點擊畫面標記跑道四角點（左上、右上、右下、左下），中線點將自動計算產生，完成後可直接拖曳微調。';

  @override
  String get guideDescriptionMobile =>
      '點選下方「點 1 (左上)」至「點 6 (中下)」按鈕選定目標點，再點擊或拖曳畫面標註位置；中線點將自動計算，亦可手動微調。';

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
  String get longJumpModeDescription => '使用錨點幾何與起跳前腳步校正偵測起跳、最長騰空及落地；錨點範圍須涵蓋跑道與沙坑';

  @override
  String get viewUploadedVideo => '查看影片';

  @override
  String tourStep(int current, int total) {
    return '步驟 $current / $total';
  }

  @override
  String get tourPrevious => '上一步';

  @override
  String get tourNext => '下一步';

  @override
  String get tourSkip => '跳過導覽';

  @override
  String get tourFinish => '完成導覽';

  @override
  String get tourHelp => '操作指引';

  @override
  String get tourReplay => '重新觀看教學';

  @override
  String get tourNavSidebarTitle => '主選單導覽列';

  @override
  String get tourNavSidebarDesc => '可在此快速切換「跑步分析」、「影片上傳」與「同步錄影」三大功能模組。';

  @override
  String get tourNavLangTitle => '多國語系切換';

  @override
  String get tourNavLangDesc => '支援繁體中文與 English 即時切換，系統也會自動辨識瀏覽器預設語系。';

  @override
  String get tourNavHelpTitle => '隨時開啟操作指引';

  @override
  String get tourNavHelpDesc => '在任何畫面點擊「❓」即可重新啟動該頁面的步驟式操作說明。';

  @override
  String get tourPlaybackRunnerTitle => '跑者選擇與切換';

  @override
  String get tourPlaybackRunnerDesc => '點擊此處可下拉選擇欲查看的跑者，並載入該跑者的所有歷史分析紀錄。';

  @override
  String get tourPlaybackSidebarToggleTitle => '側邊欄收摺與展開';

  @override
  String get tourPlaybackSidebarToggleDesc => '點擊此圖示按鈕可快速收摺或展開左側的歷史分析紀錄面板，釋放更多空間以檢視影像與圖表。';

  @override
  String get tourPlaybackHistoryTitle => '歷史紀錄列表';

  @override
  String get tourPlaybackHistoryDesc => '列出該跑者的所有跑步分析場次，點擊可切換至不同紀錄。';

  @override
  String get tourPlaybackMobileRecordTitle => '開啟歷史紀錄選單';

  @override
  String get tourPlaybackMobileRecordDesc => '點擊此卡片可開啟該跑者的歷史分析紀錄列表，切換至不同紀錄場次。';

  @override
  String get tourPlaybackPlayerTitle => '連續跑步影像播放器';

  @override
  String get tourPlaybackPlayerDesc => '依序串接各相機機位的連續跑步動態影像，拖曳時間軸可與運動學圖表即時連動同步分析。';

  @override
  String get tourPlaybackInfoTitle => '動作與統計資訊';

  @override
  String get tourPlaybackInfoDesc => '呈現步頻、步幅、平均速度、總時間等關鍵數據與分析狀態。';

  @override
  String get tourPlaybackChartsTitle => '運動學指標與關節角度圖表';

  @override
  String get tourPlaybackChartsDesc => '包含距離、速度、加速度與各關節（膝/髖/手肘/軀幹）隨時間變化的波形曲線，支援點擊展開收摺與懸浮數值查看。';

  @override
  String get tourPlaybackActionsTitle => '操作功能與報表匯出';

  @override
  String get tourPlaybackActionsDesc => '提供下載 PDF 跑步分析綜合報告、匯出 CSV 關節運動學原始數據，以及刪除此筆分析場次的功能。';

  @override
  String get tourRecordMasterTitle => '主控端：建立房間';

  @override
  String get tourRecordMasterDesc => '欲作為總控制端的裝置，在此設定預期參與的相機總數 (1~5 台)，點擊「建立錄影房間」生成專屬房號。';

  @override
  String get tourRecordSlaveTitle => '從機端：加入房間與機位';

  @override
  String get tourRecordSlaveDesc => '作為各視角相機的從機裝置，在此輸入主控端生成的房號並選擇負責的相機機位（如相機 2）後加入房間。';

  @override
  String get tourRecordConfigTitle => '主控端：參數配置與跑者設定';

  @override
  String get tourRecordConfigDesc => '主控端可指定跑者、預期相機總數 (1~5 台)、幀率 (FPS) 與備註資訊。';

  @override
  String get tourRecordLocalTitle => '主控端：本機鏡頭錄影';

  @override
  String get tourRecordLocalDesc => '主控端亦可作為其中一台相機機位參與錄影，開啟開關後可指派主控端鏡頭所負責的相機機位編號。';

  @override
  String get tourRecordDevicesTitle => '連線設備清單與機位就緒';

  @override
  String get tourRecordDevicesDesc => '即時監控主控端與所有從機連線狀態。各相機裝置將手機水平橫放並完成跑道校正後，即會亮起綠燈代表已就緒。';

  @override
  String get tourRecordCameraTitle => '相機即時預覽與進入全螢幕';

  @override
  String get tourRecordCameraDesc => '呈現即時相機畫面，支援鏡頭切換與變焦拉桿。點擊右上角全螢幕按鈕即可放大進入全螢幕畫面。';

  @override
  String get tourRecordAnchorToggleTitle => '全螢幕相機與啟動錨點設定';

  @override
  String get tourRecordAnchorToggleDesc => '進入全螢幕相機後，點擊左上角「設定錨點」按鈕，系統將自動擷取即時畫面並進入跑道空間校正模式。';

  @override
  String get tourRecordAnchorPointsTitle => '跑道六點空間校正';

  @override
  String get tourRecordAnchorPointsDesc =>
      '在凍結畫面上依序點擊標記跑道四角點與中線點（或直接拖曳既有錨點進行微調），確認 6 點標註完成後點擊「確認錨點」。';

  @override
  String get tourRecordAnchorPointsDescMobile =>
      '點選下方「點 1 (左上)」至「點 6 (中下)」錨點按鈕切換目標，在全螢幕畫面上點擊或拖曳以精確標註跑道 6 個錨點，完成後點擊「確認錨點」。';

  @override
  String get tourRecordDistanceDialogTitle => '設定跑道實際物理長度';

  @override
  String get tourRecordDistanceDialogDesc => '在此對話框中輸入跑道頂部（左至中）與底部（中至右）的真實公尺距離，點擊「套用並儲存」建立精確空間坐標系。';

  @override
  String get tourRecordFullscreenRecordTitle => '主控端：全螢幕同步錄影';

  @override
  String get tourRecordFullscreenRecordDesc => '主控端在全螢幕相機畫面下，亦可直接點擊右下角的紅色錄影按鈕啟動所有相機同步錄影，無需返回房間主畫面。';

  @override
  String get tourRecordAnchorDoneTitle => '校正完成與返回房間';

  @override
  String get tourRecordAnchorDoneDesc => '儲存後畫面回復即時相機預覽，左上角顯示綠色「錨點已設定」標籤。點擊右上角按鈕即可離開全螢幕返回房間。';

  @override
  String get tourRecordButtonTitle => '從機控制權與一鍵同步錄影';

  @override
  String get tourRecordButtonDesc => '從機可隨時點擊「請求控制權」升級為主控端。全員就緒後由主控端一鍵發送同步錄影指令，錄影結束後所有相機並行自動上傳！';

  @override
  String get tourRecordMasterButtonTitle => '主控端：一鍵同步錄影與並行上傳';

  @override
  String get tourRecordMasterButtonDesc =>
      '待所有機位設備皆完成校正並就緒（綠燈），由主控端點擊紅色「開始錄影」按鈕即可同步啟動所有相機，錄影結束後全機位自動並行上傳！';

  @override
  String get tourRecordSlaveButtonTitle => '從機端：等待指令與請求控制權';

  @override
  String get tourRecordSlaveButtonDesc => '從機端將等待主控端發送同步錄影指令；若現場有需求，從機亦可點擊「請求控制權」升級為主控端接管全場控制！';

  @override
  String get tourRecordSlaveCameraPosTitle => '從機端：更改相機機位';

  @override
  String get tourRecordSlaveCameraPosDesc =>
      '從機加入房間後，若需切換負責的相機視角（例如改為相機 3），可在此下拉選單隨時切換，系統將即時同步更新機位配置。';

  @override
  String get tourRecordRequestControlTitle => '從機端：請求主控權';

  @override
  String get tourRecordRequestControlDesc =>
      '從機端完成空間校正並確認就緒後，將等待主控端發送錄影指令；若現場需要變更操作者，可點擊此按鈕向主控端「請求控制權」，經主控端確認同意後即可接管房間轉為主控端身份。';

  @override
  String get tourRecordLeaveRoomTitle => '離開房間';

  @override
  String get tourRecordLeaveRoomDesc => '點擊此按鈕可中斷目前房間連線並返回錄影首頁。若為主控端離開將會結束該房間連線，從機端離開則僅退出本機連線。';

  @override
  String get tourRecordChoicePrompt => '請選擇欲說明的流程：';

  @override
  String get tourRecordChoiceBoth => '兩者皆看';

  @override
  String get tourRecordChoiceMaster => '僅看「主控端」';

  @override
  String get tourRecordChoiceSlave => '僅看「從機端 (Slave)」';

  @override
  String get tourRecordRoomInfoTitle => '房間號碼與目前身分';

  @override
  String get tourRecordRoomInfoDesc =>
      '進入房間後，頂部清楚標示當前專屬「房間號碼」（提供其他相機裝置輸入加入）以及本機在此房間中的「目前身分」（主控端或從機端）。';

  @override
  String get tourRecordMasterRoomInfoDesc => '建立房間後生成專屬「房間號碼」，並標記為「主控端」身分。其他相機裝置輸入此房號即可加入此連線房間。';

  @override
  String get tourRecordSlaveRoomInfoDesc => '成功加入房間後，頂部顯示當前連線之「房間號碼」與「從機端」身分標籤，確認已正確連入主控端所建立之錄影房間。';

  @override
  String get tourRecordShareTitle => '邀請相機加入（QR Code 與連結）';

  @override
  String get tourRecordShareDesc =>
      '主控端可點擊「分享房間」產生專屬 QR Code 供其他手機掃描，或點擊「複製連結」發送加入房間網址，其他裝置開啟後將自動進入此房間進行同步錄影。';

  @override
  String get tourRecordInquiryTitle => '請選擇欲導覽的錄影流程';

  @override
  String get tourRecordInquirySubtitle => '主控端與從機端 (Slave) 的初始操作流程不同，請選擇您欲了解的角色模式：';

  @override
  String get tourRecordInquiryBothTitle => '兩者皆看 (完整流程)';

  @override
  String get tourRecordInquiryBothDesc => '完整檢視主控端與從機端雙方的所有操作步驟與協作流程。';

  @override
  String get tourRecordInquiryBothSteps => '共 17 步驟';

  @override
  String get tourRecordInquiryMasterTitle => '主控端流程 (Master)';

  @override
  String get tourRecordInquiryMasterDesc => '建立房間、全域參數配置、監控各機位狀態、跑道空間校正與一鍵同步錄影。';

  @override
  String get tourRecordInquiryMasterSteps => '共 14 步驟';

  @override
  String get tourRecordInquirySlaveTitle => '從機端流程 (Slave)';

  @override
  String get tourRecordInquirySlaveDesc => '輸入房號加入指定機位、確認設備就緒、跑道空間校正與隨時請求控制權。';

  @override
  String get tourRecordInquirySlaveSteps => '共 11 步驟';

  @override
  String get tourRecordInquiryStartButton => '開始導覽';

  @override
  String get tourUploadTabsTitle => '上傳模式選擇';

  @override
  String get tourUploadTabsDesc => '提供「一次上傳所有視角」（單人多機同步上傳）與「分批上傳」（各相機分別上傳或接續未完成紀錄）兩種工作模式。';

  @override
  String get tourUploadRunnerTitle => '跑者身分選取';

  @override
  String get tourUploadRunnerDesc => '可切換「選擇現有跑者」從下拉清單快速選取，或切換「新增跑者」直接輸入跑者姓名建立新檔案。';

  @override
  String get tourUploadConfigTitle => '拍攝參數與錄影配置';

  @override
  String get tourUploadConfigDesc => '設定影片拍攝日期與時間、預期機位總數 (1~5 台)、相機幀率 (FPS) 及相關備註資訊。';

  @override
  String get tourUploadVideoTitle => '影片檔案選取與預覽';

  @override
  String get tourUploadVideoDesc => '選取各機位所拍攝的影片檔案，支援 MP4、MOV、AVI、MKV、WebM、M4V 等多種主流格式並即時產生預覽縮圖。';

  @override
  String get tourUploadAnchorTitle => '跑道空間錨點校正';

  @override
  String get tourUploadAnchorDesc =>
      '於影片首幀依序點擊標註跑道四角點（左上、右上、右下、左下）並輸入實際公尺距離，建立精準空間坐標系（中線點自動計算產生，亦可拖曳微調）。';

  @override
  String get tourUploadAnchorDescMobile =>
      '點選下方「點 1 (左上)」至「點 6 (中下)」按鈕選定目標錨點，於影片畫面上點擊或拖曳標註跑道各點，並輸入實際公尺距離以建立空間坐標系。';

  @override
  String get tourUploadSubmitTitle => '上傳並啟動 AI 分析';

  @override
  String get tourUploadSubmitDesc => '點擊後將影片與錨點資料提交至後端，自動執行骨架追蹤、姿勢估計與運動學運算流水線。';

  @override
  String get tourUploadSepTabsTitle => '分批工作模式切換';

  @override
  String get tourUploadSepTabsDesc =>
      '分批上傳提供「新增紀錄」（建立全新場次）與「選擇紀錄」（接續未完成場次）兩種途徑。可點選下方選項切換流程，點擊「下一步」開始導覽。';

  @override
  String get tourUploadSepNewTitle => '新增紀錄（拍攝參數設定）';

  @override
  String get tourUploadSepNewDesc => '設定全新場次的錄製日期與時間、預期相機總數 (1~5 台)、FPS 與備註，從第 1 台相機開始依序上傳。';

  @override
  String get tourUploadSepSelectTitle => '選擇紀錄（接續未完成場次）';

  @override
  String get tourUploadSepSelectDesc => '列出該跑者先前尚未上傳齊全的歷史場次（如已傳機位 1、尚缺機位 2 與 3），選取後即可接續補傳剩餘機位。';

  @override
  String get tourUploadSepCameraTitle => '當前相機機位選取';

  @override
  String get tourUploadSepCameraDesc => '從下拉選單切換目前欲上傳的相機編號（如相機 1 至相機 5）。';

  @override
  String get tourUploadSepVideoTitle => '單機位影片檔案選取';

  @override
  String get tourUploadSepVideoDesc => '點擊選取或拖曳該機位所對應的影片檔案，支援 MP4、MOV、AVI 等主流格式並預覽首幀縮圖。';

  @override
  String get tourUploadSepSubmitTitle => '分批提交與分析啟動';

  @override
  String get tourUploadSepSubmitDesc => '點擊上傳目前機位影片；待所有機位影片皆上傳完畢後，系統將自動合併並啟動 AI 運動學分析。';

  @override
  String get tourUploadSepChoicePrompt => '請選擇欲說明的流程：';

  @override
  String get tourUploadSepChoiceBoth => '兩者皆看';

  @override
  String get tourUploadSepChoiceNew => '僅看「新增紀錄」';

  @override
  String get tourUploadSepChoiceSelect => '僅看「選擇紀錄」';

  @override
  String get uncompletedRecordsPlaceholder => '未分析歷史紀錄';

  @override
  String get shareRoom => '分享房間';

  @override
  String get copyLink => '複製連結';

  @override
  String get copyJoinLink => '複製加入連結';

  @override
  String get joinLinkCopied => '已複製房間加入連結！';

  @override
  String get showJoinQrCode => '顯示 QR Code';

  @override
  String get inviteDeviceTitle => '邀請相機裝置加入';

  @override
  String get inviteDeviceSubtitle => '使用手機相機掃描下方 QR Code，或透過分享連結直接加入此房間';

  @override
  String get roomJoinUrl => '加入連結';

  @override
  String get autoFilledRoomNumber => '已自動帶入房間號碼';

  @override
  String get deepLinkAppFallbackHint => '若裝置已安裝 App 將優先自動開啟 App，若未安裝則由瀏覽器開啟網頁版。';

  @override
  String get enterSessionCodeOrLink => '輸入補傳代碼或貼上連結';

  @override
  String get sessionCodeInputHint => '輸入 Session ID 或貼上完整連結';

  @override
  String get loadSession => '載入';

  @override
  String get loadSessionFailed => '找不到此待補傳紀錄或該紀錄已分析完成';

  @override
  String get loadSessionSuccess => '已成功載入待補傳紀錄！';

  @override
  String get copySessionCode => '複製補傳代碼';

  @override
  String get copySessionLink => '複製補傳連結';

  @override
  String get sessionCodeCopied => '已複製補傳代碼！';

  @override
  String get sessionLinkCopied => '已複製補傳連結！';

  @override
  String get sharedSessionBadge => '外部協同補傳';

  @override
  String get allCamerasUploadedExternalNotice => '所有相機影片已全數上傳完畢！系統已自動為房主啟動 AI 運動學分析。';

  @override
  String get uploadSuccessNotice => '上傳完成通知';

  @override
  String get sessionLoadedBannerTitle => '已載入外部補傳紀錄';

  @override
  String sessionLoadedBannerSubtitle(String runnerName, String missingCameras) {
    return '選手：$runnerName ｜ 缺機位：$missingCameras';
  }

  @override
  String missingCameras(String cameras) {
    return '缺相機 $cameras';
  }

  @override
  String get selectRunnerOrEnterCodePrompt => '請先選擇跑者，或於上方輸入補傳代碼/連結';
}
