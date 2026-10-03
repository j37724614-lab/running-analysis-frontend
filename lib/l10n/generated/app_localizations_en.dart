// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sprint Analysis';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get actions => 'Actions';

  @override
  String get notes => 'Notes';

  @override
  String get noNotes => 'No notes';

  @override
  String get language => 'Language';

  @override
  String get chinese => '繁體中文';

  @override
  String get english => 'English';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get navRecord => 'Record';

  @override
  String get navUpload => 'Upload';

  @override
  String get navPlayback => 'Playback';

  @override
  String get navSupport => 'Support';

  @override
  String get navPolicy => 'Privacy Policy';

  @override
  String get navLogout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Confirm Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out of the system?';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'Please enter your username';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Please enter your password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Please re-enter your password';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get selectRunner => 'Select Runner';

  @override
  String get searchRunner => 'Search runner...';

  @override
  String get addRunner => 'Add Runner';

  @override
  String get runnerName => 'Runner Name';

  @override
  String get enterRunnerName => 'Please enter runner name';

  @override
  String get analysisHistory => 'Analysis History';

  @override
  String get noHistoryFound => 'No analysis records found';

  @override
  String get cameras => 'Cameras';

  @override
  String get statusDone => 'Completed';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusPending => 'Pending';

  @override
  String get sessionInfo => 'Running Info';

  @override
  String get analysisStatus => 'Analysis Status';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get cameraCount => 'Camera Count';

  @override
  String get totalTime => 'Total Time';

  @override
  String get avgVelocity => 'Average Velocity';

  @override
  String get avgAcceleration => 'Average Acceleration';

  @override
  String get avgStepLength => 'Average Step Length';

  @override
  String get unitSeconds => 's';

  @override
  String get unitMps => 'm/s';

  @override
  String get unitMps2 => 'm/s²';

  @override
  String get unitMeters => 'm';

  @override
  String get downloadPdfReport => 'Download PDF Report';

  @override
  String get downloadCsvData => 'Download CSV Data';

  @override
  String get deleteSessionConfirmTitle => 'Delete Analysis Record';

  @override
  String get deleteSessionConfirmMessage =>
      'Are you sure you want to delete this analysis record? This action cannot be undone.';

  @override
  String get tabOverallPerformance => 'Kinematic Metrics';

  @override
  String get tabJointAngles => 'Joint Angles';

  @override
  String get tabSymmetry => 'Symmetry & Footwork';

  @override
  String get noChartData => 'No chart data available';

  @override
  String get deleteRunnerConfirmTitle => 'Delete Runner';

  @override
  String deleteRunnerConfirmMessage(String name) {
    return 'Are you sure you want to delete runner \"$name\" and all associated records?';
  }

  @override
  String get recordControl => 'Recording Controls';

  @override
  String get cameraSettings => 'Camera Settings';

  @override
  String get fps => 'FPS';

  @override
  String get countdownTimer => 'Countdown Timer';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get cameraStatusReady => 'Ready';

  @override
  String get cameraStatusNotReady => 'Not Ready';

  @override
  String get recaptureSnapshot => '📷 Recapture';

  @override
  String get setAnchor => 'Set Anchors';

  @override
  String get confirmAnchor => 'Confirm Anchors';

  @override
  String get clearAnchor => 'Clear Anchors';

  @override
  String get markAllPointsPrompt => 'Please mark all 6 anchor points first';

  @override
  String get distanceDialogTitle => 'Actual Distance Setting (m)';

  @override
  String get distanceDialogSubtitle =>
      'Enter the two longitudinal runway distances and runway width for metric calibration:';

  @override
  String get distanceLeftToCenter => 'Left (1-4) to Center (5-6) Longitudinal Distance (m)';

  @override
  String get distanceCenterToRight => 'Center (5-6) to Right (2-3) Longitudinal Distance (m)';

  @override
  String get runwayWidth => 'Runway Width (m)';

  @override
  String get distanceInvalidPrompt => 'Please enter a valid number greater than 0';

  @override
  String get applyAndSave => 'Confirm & Apply';

  @override
  String get dragToAdjust => 'Drag to adjust position';

  @override
  String get tapToMarkPoint => 'Tap or drag to mark point';

  @override
  String get point1 => 'Point 1 (Top-Left)';

  @override
  String get point2 => 'Point 2 (Top-Right)';

  @override
  String get point3 => 'Point 3 (Bottom-Right)';

  @override
  String get point4 => 'Point 4 (Bottom-Left)';

  @override
  String get point5 => 'Point 5 (Top-Middle)';

  @override
  String get point6 => 'Point 6 (Bottom-Middle)';

  @override
  String get cameraNotAssigned => 'Camera not assigned';

  @override
  String get orientationLandscapeRequired => 'Please rotate device to landscape to record';

  @override
  String get connectedStatus => 'Connection Status';

  @override
  String get controlGranted => 'Control Granted';

  @override
  String get controlDenied => 'Control Request Denied';

  @override
  String connectionError(String error) {
    return 'Connection Error: $error';
  }

  @override
  String get connectionDisconnected => 'Connection Disconnected';

  @override
  String get tabUploadAll => 'Upload All';

  @override
  String get tabUploadSeparately => 'Upload Separately';

  @override
  String get tabUnanalyzedHistory => 'Unanalyzed History';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get selectRunnerRequired => 'Please select a runner';

  @override
  String get selectDate => 'Select Date';

  @override
  String get uploadAndAnalyze => 'Upload & Analyze';

  @override
  String get selectVideo => 'Select Video';

  @override
  String get videoSelected => 'Video Selected';

  @override
  String get anchorSet => 'Anchors Set';

  @override
  String get anchorNotSet => 'Anchors Not Set';

  @override
  String get mustSetAnchorsForAllCameras => 'Please set anchor points for all cameras first';

  @override
  String get selectVideoFirst => 'Please upload a video first';

  @override
  String get uploading => 'Uploading...';

  @override
  String get uploadSuccess => 'Upload Successful';

  @override
  String get uploadFailed => 'Upload Failed';

  @override
  String anchorDialogTitle(int index) {
    return 'Anchor Calibration (Camera $index)';
  }

  @override
  String get selectAnchorToMark => 'Select anchor point to mark:';

  @override
  String get leftStart => 'Top-Left';

  @override
  String get rightStart => 'Top-Right';

  @override
  String get rightEnd => 'Bottom-Right';

  @override
  String get leftEnd => 'Bottom-Left';

  @override
  String get centerStart => 'Top-Middle';

  @override
  String get centerEnd => 'Bottom-Middle';

  @override
  String get undo => 'Undo';

  @override
  String get clear => 'Clear';

  @override
  String get magnifier => 'Magnifier';

  @override
  String get guide => 'Guide';

  @override
  String get guideDescription =>
      'Click sequentially to mark the 4 runway corners (TL, TR, BR, BL). Center points are auto-calculated. Drag markers on the canvas to fine-tune.';

  @override
  String get guideDescriptionMobile =>
      'Select a target point (Point 1–Point 6) below, then tap or drag on the image to position it. Center points are auto-calculated and adjustable.';

  @override
  String get noUnanalyzedSessions => 'No unanalyzed records';

  @override
  String get startAnalysis => 'Start Analysis';

  @override
  String get deleteUnanalyzedConfirm => 'Are you sure you want to delete this unanalyzed session?';

  @override
  String get progressTranscode => 'Video Transcoding Completed';

  @override
  String get progressTracking => 'Video Tracking Completed';

  @override
  String get progressPose => 'Pose Estimation Completed';

  @override
  String get progressPostProcessing => 'Data Post-processing Completed';

  @override
  String get progressSaved => 'Completed and Saved';

  @override
  String get supportTitle => 'Technical Support & Contact';

  @override
  String get supportSubtitle =>
      'If you have any feedback or encounter issues, feel free to contact us.';

  @override
  String get contactEmail => 'Support Email';

  @override
  String get systemVersion => 'System Version';

  @override
  String get policyTitle => 'Privacy Policy';

  @override
  String get policyLastUpdated => 'Last Updated';

  @override
  String get masterDevice => 'Master Device';

  @override
  String get masterDeviceDescription =>
      'Controls recording start and stop for all connected devices';

  @override
  String get expectedDeviceCount => 'Expected Devices: ';

  @override
  String get createRecordingRoom => 'Create Recording Room';

  @override
  String get orDivider => 'OR';

  @override
  String get slaveDevice => 'Recording Device (Slave)';

  @override
  String get enterRoomNumber => 'Enter Room Number';

  @override
  String get selectCameraPosition => 'Select Camera Position';

  @override
  String get joinRecordingRoom => 'Join Recording Room';

  @override
  String get roomNumber => 'Room Number';

  @override
  String get currentRole => 'Current Role';

  @override
  String get roleMaster => 'Master';

  @override
  String get roleSlave => 'Slave';

  @override
  String get localRecording => 'Local Device Records';

  @override
  String get changeCameraPosition => 'Change Camera Position:';

  @override
  String get connectedDevices => 'Connected Devices:';

  @override
  String get waitingForConnection => 'Waiting for connection...';

  @override
  String get roomHost => 'Host';

  @override
  String get recordingInProgress => 'Recording in progress...';

  @override
  String get stopRecordingAndUpload => 'Stop Recording & Upload';

  @override
  String get startSyncRecording => 'Start Synchronized Recording';

  @override
  String get requestControl => 'Request Master Control';

  @override
  String get takeControl => 'Take Master Control';

  @override
  String get waitingForControlApproval => 'Waiting for Host Approval...';

  @override
  String get leaveRoom => 'Leave Room';

  @override
  String get controlTransferRequest => 'Master Control Request';

  @override
  String controlTransferMessage(String id) {
    return 'Device $id is requesting master control of this room. Do you agree?';
  }

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get uploadSeparately => 'Upload Separately';

  @override
  String get uploadAll => 'Upload All';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get camera => 'Camera';

  @override
  String get clickToUpload => 'Click to upload';

  @override
  String get upload => 'Upload';

  @override
  String get newRecord => 'New Session';

  @override
  String get selectRecord => 'Select Session';

  @override
  String get pleaseSelectRecordToUpload => 'Please select a session to upload';

  @override
  String get cameraIndexNumber => 'Camera Number';

  @override
  String get pleaseSelectRunnerFirst => 'Please select a runner first';

  @override
  String get pleaseUploadAllVideos => 'Please upload all videos';

  @override
  String get noUnanalyzedRecords => 'No unanalyzed records found';

  @override
  String get switchLens => 'Switch Lens';

  @override
  String get pleaseSelectRunnerToRecord => 'Please select a runner before recording';

  @override
  String camerasNotAllConnected(int current, int total) {
    return 'Cameras not all connected (Current: $current/$total)';
  }

  @override
  String get camerasNotAllReady => 'Some cameras are not oriented horizontally (Not ready)';

  @override
  String get autoUploading => 'Auto uploading...';

  @override
  String get pleaseHoldDeviceHorizontally => 'Please hold device horizontally to record';

  @override
  String get pleaseSetAnchorFullscreen => 'Tap to set anchors in fullscreen';

  @override
  String get noVideoData => 'No Video Data';

  @override
  String get analysisFailedTitle => 'Analysis Failed!';

  @override
  String get analysisFailedDescription =>
      'This video analysis failed. You can delete it from the actions card on the right.';

  @override
  String get metricDistance => 'Distance';

  @override
  String get metricVelocity => 'Velocity';

  @override
  String get metricAcceleration => 'Acceleration';

  @override
  String get metricDistanceUnit => 'Distance (m)';

  @override
  String get metricVelocityUnit => 'Velocity (m/s)';

  @override
  String get metricAccelerationUnit => 'Acceleration (m/s²)';

  @override
  String get timeWithUnit => 'Time (s)';

  @override
  String get chartKneeAngle => 'Knee Angle';

  @override
  String get chartHipAngle => 'Hip Angle';

  @override
  String get chartElbowFlexion => 'Elbow Flexion Angle';

  @override
  String get chartPelvisTorsoAngle => 'Pelvis-Torso Angle';

  @override
  String get angleUnit => 'Angle (deg)';

  @override
  String get legendLeft => 'Left';

  @override
  String get legendRight => 'Right';

  @override
  String get longJumpMode => 'Long-jump mode';

  @override
  String get longJumpModeDescription =>
      'Detect takeoff, the longest flight, and landing using anchor geometry and pre-takeoff footsteps; anchors must cover the runway and sand pit';

  @override
  String get viewUploadedVideo => 'View video';

  @override
  String tourStep(int current, int total) {
    return 'Step $current / $total';
  }

  @override
  String get tourPrevious => 'Previous';

  @override
  String get tourNext => 'Next';

  @override
  String get tourSkip => 'Skip Tour';

  @override
  String get tourFinish => 'Finish';

  @override
  String get tourHelp => 'Tour Guide';

  @override
  String get tourReplay => 'Replay Tutorial';

  @override
  String get tourNavSidebarTitle => 'Navigation Sidebar';

  @override
  String get tourNavSidebarDesc =>
      'Quickly switch between Playback, Upload, and Synchronized Recording modules.';

  @override
  String get tourNavLangTitle => 'Language Switcher';

  @override
  String get tourNavLangDesc =>
      'Switch seamlessly between Traditional Chinese and English with automatic system language detection.';

  @override
  String get tourNavHelpTitle => 'On-demand Help Guide';

  @override
  String get tourNavHelpDesc =>
      'Click the \'❓\' button at any time on any page to restart the step-by-step walkthrough.';

  @override
  String get tourPlaybackRunnerTitle => 'Runner Selector';

  @override
  String get tourPlaybackRunnerDesc =>
      'Select a runner from the dropdown to load all historical running analysis sessions.';

  @override
  String get tourPlaybackSidebarToggleTitle => 'Sidebar Collapse & Expand';

  @override
  String get tourPlaybackSidebarToggleDesc =>
      'Click this toggle button to collapse or expand the left history panel, maximizing workspace for videos and charts.';

  @override
  String get tourPlaybackHistoryTitle => 'Session History List';

  @override
  String get tourPlaybackHistoryDesc =>
      'Displays all recorded sessions for the selected runner. Click any session to switch records.';

  @override
  String get tourPlaybackMobileRecordTitle => 'Open Session History';

  @override
  String get tourPlaybackMobileRecordDesc =>
      'Tap this card to open the runner\'s session history list and switch between recorded sessions.';

  @override
  String get tourPlaybackPlayerTitle => 'Continuous Video Player';

  @override
  String get tourPlaybackPlayerDesc =>
      'Sequentially plays continuous running footage across all camera views. Dragging the timeline synchronizes real-time analysis with kinematic charts.';

  @override
  String get tourPlaybackInfoTitle => 'Session & Biomechanical Metrics';

  @override
  String get tourPlaybackInfoDesc =>
      'View cadence, step length, average velocity, total time, and processing status.';

  @override
  String get tourPlaybackChartsTitle => 'Kinematic & Joint Angle Charts';

  @override
  String get tourPlaybackChartsDesc =>
      'Interactive time-series curves for distance, velocity, acceleration, and knee/hip/elbow/torso joint angles.';

  @override
  String get tourPlaybackActionsTitle => 'Actions & Report Export';

  @override
  String get tourPlaybackActionsDesc =>
      'Download comprehensive PDF analysis reports, export raw kinematic CSV data, or delete the current analysis session.';

  @override
  String get tourRecordMasterTitle => 'Master: Create Room';

  @override
  String get tourRecordMasterDesc =>
      'The Master controller creates a recording room with the expected camera count (1-5 devices).';

  @override
  String get tourRecordSlaveTitle => 'Slave: Join Room & Camera Slot';

  @override
  String get tourRecordSlaveDesc =>
      'Slave devices enter the room number and select their assigned camera slot (e.g., Camera 2) to join.';

  @override
  String get tourRecordConfigTitle => 'Master: Session Config & Runner';

  @override
  String get tourRecordConfigDesc =>
      'The Master configures the runner, expected camera count, FPS, and session notes.';

  @override
  String get tourRecordLocalTitle => 'Master: Local Camera Recording';

  @override
  String get tourRecordLocalDesc =>
      'The Master device can also act as one of the recording cameras. Enable this toggle to assign its camera index.';

  @override
  String get tourRecordDevicesTitle => 'Connected Devices & Readiness';

  @override
  String get tourRecordDevicesDesc =>
      'Monitor all Master and Slave connections. Devices turn green when held horizontally and calibrated.';

  @override
  String get tourRecordCameraTitle => 'Camera Live Preview & Fullscreen';

  @override
  String get tourRecordCameraDesc =>
      'Live camera preview with lens switching and zoom controls. Tap the top-right fullscreen button to enter fullscreen.';

  @override
  String get tourRecordAnchorToggleTitle => 'Fullscreen Camera & Start Calibration';

  @override
  String get tourRecordAnchorToggleDesc =>
      'In fullscreen camera view, tap the top-left \'Set Anchor\' button to capture the current frame and enter calibration mode.';

  @override
  String get tourRecordAnchorPointsTitle => 'Track 6-Point Spatial Calibration';

  @override
  String get tourRecordAnchorPointsDesc =>
      'Click sequentially to mark the 4 corner points and 2 midpoints on the frozen frame, or drag existing anchors to fine-tune, then tap \'Confirm Anchors\'.';

  @override
  String get tourRecordAnchorPointsDescMobile =>
      'Tap the anchor buttons (\'Point 1\' to \'Point 6\') below to select a target point, then tap or drag on the fullscreen snapshot to position it, and tap \'Confirm Anchors\'.';

  @override
  String get tourRecordDistanceDialogTitle => 'Input Track Physical Distances';

  @override
  String get tourRecordDistanceDialogDesc =>
      'Enter the actual physical distances in meters for the track (Left-to-Center and Center-to-Right), then tap \'Apply & Save\'.';

  @override
  String get tourRecordFullscreenRecordTitle => 'Master: Fullscreen Synchronized Recording';

  @override
  String get tourRecordFullscreenRecordDesc =>
      'In fullscreen camera mode, the Master can directly click the bottom-right red recording button to start synchronized recording on all devices without returning to the main room screen.';

  @override
  String get tourRecordAnchorDoneTitle => 'Calibration Done & Return to Room';

  @override
  String get tourRecordAnchorDoneDesc =>
      'Live preview resumes cleanly with the green \'Anchor Set\' badge on the top-left. Tap the top-right button to exit fullscreen and return to the room.';

  @override
  String get tourRecordButtonTitle => 'Slave Control & Synchronized Recording';

  @override
  String get tourRecordButtonDesc =>
      'Slaves can request control transfer. Once all devices are ready, the Master triggers synchronized recording with parallel automated uploading.';

  @override
  String get tourRecordMasterButtonTitle => 'Master: Sync Recording & Upload';

  @override
  String get tourRecordMasterButtonDesc =>
      'Once all camera devices are calibrated and ready (green indicator), the Master host clicks \'Start Recording\' to trigger synchronous recording on all cameras simultaneously, with automatic parallel uploads when finished!';

  @override
  String get tourRecordSlaveButtonTitle => 'Slave: Awaiting Commands & Control';

  @override
  String get tourRecordSlaveButtonDesc =>
      'The slave device waits for sync recording commands from the Master host. If needed, a slave device can also tap \'Request Host Control\' to become the Master host!';

  @override
  String get tourRecordSlaveCameraPosTitle => 'Slave: Change Camera Position';

  @override
  String get tourRecordSlaveCameraPosDesc =>
      'After joining the room, if you need to reassign your camera angle (e.g. switch to Camera 3), select from this dropdown to update your assigned camera position instantly.';

  @override
  String get tourRecordRequestControlTitle => 'Slave: Request Host Control';

  @override
  String get tourRecordRequestControlDesc =>
      'Once calibrated and ready, the Slave device waits for recording commands; if control needs to be transferred, click this button to \'Request Control\'. Once approved by the Master, this device becomes the Master host.';

  @override
  String get tourRecordLeaveRoomTitle => 'Leave Room';

  @override
  String get tourRecordLeaveRoomDesc =>
      'Click this button to disconnect from the current room and return to the Record home screen. If the Master leaves, the entire room session will end; if a Slave leaves, only this device disconnects.';

  @override
  String get tourRecordChoicePrompt => 'Choose workflow to explore:';

  @override
  String get tourRecordChoiceBoth => 'Explore Both';

  @override
  String get tourRecordChoiceMaster => 'Master Host Only';

  @override
  String get tourRecordChoiceSlave => 'Slave Device Only';

  @override
  String get tourRecordRoomInfoTitle => 'Room Number & Active Role';

  @override
  String get tourRecordRoomInfoDesc =>
      'Displays the unique Room ID (for other camera devices to join) and your active role badge (Master Host or Slave Device).';

  @override
  String get tourRecordMasterRoomInfoDesc =>
      'Generates a unique Room ID and assigns the Master Host role. Other devices enter this Room ID to connect.';

  @override
  String get tourRecordSlaveRoomInfoDesc =>
      'Displays the connected Room ID and Slave Device badge, confirming successful connection to the host recording room.';

  @override
  String get tourRecordShareTitle => 'Invite Cameras (QR Code & Link)';

  @override
  String get tourRecordShareDesc =>
      'The Host can tap \'Share Room\' to generate a dedicated QR Code for other devices to scan, or tap \'Copy Link\' to share the join URL. Other devices opening the link will automatically enter this room for synchronized recording.';

  @override
  String get tourRecordInquiryTitle => 'Choose Recording Workflow Tour';

  @override
  String get tourRecordInquirySubtitle =>
      'Master Host and Slave Device have different initial setups. Please choose a role to explore:';

  @override
  String get tourRecordInquiryBothTitle => 'Explore Both (Full Tour)';

  @override
  String get tourRecordInquiryBothDesc =>
      'Learn all setup, calibration, and recording steps for both Master and Slave devices.';

  @override
  String get tourRecordInquiryBothSteps => '17 Steps';

  @override
  String get tourRecordInquiryMasterTitle => 'Master Host Workflow';

  @override
  String get tourRecordInquiryMasterDesc =>
      'Create room, configure parameters, monitor device readiness, calibrate track, and trigger sync recording.';

  @override
  String get tourRecordInquiryMasterSteps => '14 Steps';

  @override
  String get tourRecordInquirySlaveTitle => 'Slave Device Workflow';

  @override
  String get tourRecordInquirySlaveDesc =>
      'Join room by room code, assign camera angle, verify readiness, calibrate track, and request host control.';

  @override
  String get tourRecordInquirySlaveSteps => '11 Steps';

  @override
  String get tourRecordInquiryStartButton => 'Start Tour';

  @override
  String get tourUploadTabsTitle => 'Upload Mode Selection';

  @override
  String get tourUploadTabsDesc =>
      'Provides two workflows: \'Upload All\' (multi-camera synchronized upload) and \'Upload Separately\' (upload by individual camera or continue incomplete sessions).';

  @override
  String get tourUploadRunnerTitle => 'Runner Identity';

  @override
  String get tourUploadRunnerDesc =>
      'Switch to \'Select Runner\' to choose from existing runners or \'Add Runner\' to register a new runner name.';

  @override
  String get tourUploadConfigTitle => 'Session Parameters & Setup';

  @override
  String get tourUploadConfigDesc =>
      'Configure recording date/time, expected camera count (1-5), video frame rate (FPS), and session notes.';

  @override
  String get tourUploadVideoTitle => 'Video Selection & Preview';

  @override
  String get tourUploadVideoDesc =>
      'Select video files for each camera angle, supporting MP4, MOV, AVI, MKV, WebM, M4V and other major formats with instant thumbnail preview.';

  @override
  String get tourUploadAnchorTitle => 'Spatial Anchor Calibration';

  @override
  String get tourUploadAnchorDesc =>
      'Calibrate the 4 track corner points (TL, TR, BR, BL) sequentially on the first frame and input actual meter distances to establish a precise coordinate system.';

  @override
  String get tourUploadAnchorDescMobile =>
      'Tap anchor buttons (\'Point 1\' to \'Point 6\') below to select a target point, tap or drag on the video frame to place it, and input real physical distances.';

  @override
  String get tourUploadSubmitTitle => 'Upload & Start Analysis';

  @override
  String get tourUploadSubmitDesc =>
      'Submit videos and calibration data to the backend AI pipeline for tracking, pose estimation, and kinematics calculation.';

  @override
  String get tourUploadSepTabsTitle => 'Batch Workflow Switch';

  @override
  String get tourUploadSepTabsDesc =>
      'Batch Upload offers \'New Record\' and \'Select Record\' paths. Select an option below and click \'Next\' to start.';

  @override
  String get tourUploadSepNewTitle => 'New Record (Camera Setup)';

  @override
  String get tourUploadSepNewDesc =>
      'Set recording date/time, expected cameras (1-5), FPS, and notes for a new session, uploading from camera 1 sequentially.';

  @override
  String get tourUploadSepSelectTitle => 'Select Record (Resume Session)';

  @override
  String get tourUploadSepSelectDesc =>
      'Lists incomplete past sessions (e.g. cam 1 uploaded, cam 2 & 3 pending) to resume uploading remaining camera angles.';

  @override
  String get tourUploadSepCameraTitle => 'Camera Angle Selection';

  @override
  String get tourUploadSepCameraDesc =>
      'Switch the target camera number from the dropdown (e.g. Camera 1 through 5).';

  @override
  String get tourUploadSepVideoTitle => 'Single Camera Video Selection';

  @override
  String get tourUploadSepVideoDesc =>
      'Select or drag the video file for this camera angle, supporting MP4, MOV, AVI, and generating instant preview.';

  @override
  String get tourUploadSepSubmitTitle => 'Batch Submit & Analysis Trigger';

  @override
  String get tourUploadSepSubmitDesc =>
      'Upload the current camera video. Once all expected cameras are uploaded, the system automatically begins multi-camera AI analysis.';

  @override
  String get tourUploadSepChoicePrompt => 'Choose workflow to explore:';

  @override
  String get tourUploadSepChoiceBoth => 'Explore Both';

  @override
  String get tourUploadSepChoiceNew => 'New Record Only';

  @override
  String get tourUploadSepChoiceSelect => 'Select Record Only';

  @override
  String get uncompletedRecordsPlaceholder => 'Unanalyzed Sessions';

  @override
  String get shareRoom => 'Share Room';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get copyJoinLink => 'Copy Join Link';

  @override
  String get joinLinkCopied => 'Room join link copied to clipboard!';

  @override
  String get showJoinQrCode => 'Show QR Code';

  @override
  String get inviteDeviceTitle => 'Invite Camera Devices';

  @override
  String get inviteDeviceSubtitle =>
      'Scan the QR Code with your phone camera or use the link to join this room directly';

  @override
  String get roomJoinUrl => 'Join Link';

  @override
  String get autoFilledRoomNumber => 'Room number auto-filled';

  @override
  String get deepLinkAppFallbackHint =>
      'Will automatically open the App if installed, or fallback to the Web version in your browser.';

  @override
  String get enterSessionCodeOrLink => 'Enter session code or paste link';

  @override
  String get sessionCodeInputHint => 'Enter Session ID or paste full link';

  @override
  String get loadSession => 'Load';

  @override
  String get loadSessionFailed => 'Unanalyzed session not found or already completed';

  @override
  String get loadSessionSuccess => 'Unanalyzed session loaded successfully!';

  @override
  String get copySessionCode => 'Copy Session Code';

  @override
  String get copySessionLink => 'Copy Session Link';

  @override
  String get sessionCodeCopied => 'Session code copied to clipboard!';

  @override
  String get sessionLinkCopied => 'Session link copied to clipboard!';

  @override
  String get sharedSessionBadge => 'Shared Session';

  @override
  String get allCamerasUploadedExternalNotice =>
      'All camera videos have been uploaded! AI kinematic analysis has started for the session owner.';

  @override
  String get uploadSuccessNotice => 'Upload Complete Notice';

  @override
  String get sessionLoadedBannerTitle => 'Loaded Shared Session';

  @override
  String sessionLoadedBannerSubtitle(String runnerName, String missingCameras) {
    return 'Runner: $runnerName | Missing: $missingCameras';
  }

  @override
  String missingCameras(String cameras) {
    return 'Missing Cameras $cameras';
  }

  @override
  String get selectRunnerOrEnterCodePrompt =>
      'Please select a runner first, or enter session code/link above';
}
