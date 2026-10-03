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
  String get logoutConfirmMessage =>
      'Are you sure you want to log out of the system?';

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
  String get distanceLeftToCenter =>
      'Left (1-4) to Center (5-6) Longitudinal Distance (m)';

  @override
  String get distanceCenterToRight =>
      'Center (5-6) to Right (2-3) Longitudinal Distance (m)';

  @override
  String get runwayWidth => 'Runway Width (m)';

  @override
  String get distanceInvalidPrompt =>
      'Please enter a valid number greater than 0';

  @override
  String get applyAndSave => 'Confirm & Apply';

  @override
  String get dragToAdjust => 'Drag to adjust position';

  @override
  String get tapToMarkPoint => 'Tap or drag to mark point';

  @override
  String get point1 => 'Pt 1 (Top-Left)';

  @override
  String get point2 => 'Pt 2 (Top-Right)';

  @override
  String get point3 => 'Pt 3 (Bottom-Right)';

  @override
  String get point4 => 'Pt 4 (Bottom-Left)';

  @override
  String get point5 => 'Pt 5 (Top-Middle)';

  @override
  String get point6 => 'Pt 6 (Bottom-Middle)';

  @override
  String get cameraNotAssigned => 'Camera not assigned';

  @override
  String get orientationLandscapeRequired =>
      'Please rotate device to landscape to record';

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
  String get mustSetAnchorsForAllCameras =>
      'Please set anchor points for all cameras first';

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
      'Please mark the 4 track corners in order (Top-Left, Top-Right, Bottom-Right, Bottom-Left). Center line will be auto-calculated, and can be fine-tuned by tapping or dragging.';

  @override
  String get noUnanalyzedSessions => 'No unanalyzed records';

  @override
  String get startAnalysis => 'Start Analysis';

  @override
  String get deleteUnanalyzedConfirm =>
      'Are you sure you want to delete this unanalyzed session?';

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
  String get pleaseSelectRunnerToRecord =>
      'Please select a runner before recording';

  @override
  String camerasNotAllConnected(int current, int total) {
    return 'Cameras not all connected (Current: $current/$total)';
  }

  @override
  String get camerasNotAllReady =>
      'Some cameras are not oriented horizontally (Not ready)';

  @override
  String get autoUploading => 'Auto uploading...';

  @override
  String get pleaseHoldDeviceHorizontally =>
      'Please hold device horizontally to record';

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
}
