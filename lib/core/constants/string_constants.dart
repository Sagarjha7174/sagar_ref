class Strings {
  Strings._();

  // General
  static const String appName = 'Sagar Refrigeration Service';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String recordings = 'Recordings';
  static const String complaints = 'Complaints';
  static const String history = 'History';
  static const String settings = 'Settings';

  // Dashboard
  static const String todayEarnings = 'Today';
  static const String weeklyEarnings = 'This Week';
  static const String monthlyEarnings = 'This Month';
  static const String totalEarnings = 'Total';
  static const String pending = 'Pending';
  static const String completed = 'Completed';
  static const String rejected = 'Rejected';
  static const String monthlyTrend = 'Monthly Earnings Trend';
  static const String applianceDistribution = 'Appliance Distribution';

  // Recordings
  static const String noFolderConfigured = 'Recording folder not configured';
  static const String noFolderConfiguredSubtitle =
      'Go to Settings to set the MIUI call recording folder.\n\n'
      'Common paths:\n'
      '• /sdcard/MIUI/sound_recorder/call_rec/\n'
      '• /storage/emulated/0/MIUI/sound_recorder/call_rec/';
  static const String goToSettings = 'Go to Settings';
  static const String noRecordingsFound = 'No new incoming recordings found';
  static const String noRecordingsSubtitle = 'Tap rescan to check for new recordings';
  static const String rescan = 'Rescan';
  static const String play = 'Play';
  static const String call = 'Call';
  static const String createComplaint = 'Create Complaint';
  static const String discard = 'Discard';
  static const String discardConfirmTitle = 'Discard Recording?';
  static const String discardConfirmBody =
      'Are you sure you want to discard this recording? The file will NOT be deleted.';
  static const String recordingDiscarded = 'Recording discarded.';
  static const String scanning = 'Scanning recordings...';

  // Complaints
  static const String pendingComplaints = 'Pending Complaints';
  static const String noPendingComplaints = 'No pending complaints';
  static const String noPendingComplaintsSubtitle =
      'Create a complaint from the Recordings tab';
  static const String customerName = 'Customer Name';
  static const String phoneNumber = 'Phone Number';
  static const String applianceType = 'Appliance Type';
  static const String selectAppliance = 'Select Appliance Type';
  static const String notes = 'Notes';
  static const String optionalNotes = 'Optional notes...';
  static const String recordingPath = 'Recording Path';
  static const String createdDate = 'Created Date';
  static const String status = 'Status';
  static const String complaintCreated = 'Complaint created successfully.';
  static const String completeComplaint = 'Complete Complaint';
  static const String amountEarned = 'Amount Earned (₹)';
  static const String completionNotes = 'Completion Notes';
  static const String optionalCompletionNotes = 'Optional completion notes...';
  static const String complaintCompleted = 'Complaint completed.';
  static const String rejectComplaint = 'Reject Complaint?';
  static const String rejectConfirmBody = 'Are you sure you want to reject the complaint for';
  static const String complaintRejected = 'Complaint rejected.';
  static const String amountRequired = 'Amount is required';
  static const String amountMustBePositive = 'Amount must be greater than zero';
  static const String customerNameRequired = 'Customer name is required';
  static const String applianceRequired = 'Please select an appliance type';

  // Duplicate complaint
  static const String pendingComplaintExists = 'Pending Complaint Exists';
  static const String duplicateComplaintBody =
      'A pending complaint already exists for this customer. Please resolve the existing complaint before creating a new one.';
  static const String viewExisting = 'View Existing';
  static const String cannotReopen = 'Cannot Reopen';
  static const String cannotReopenBody =
      'A pending complaint already exists for this number. Resolve it first.';

  // History
  static const String noHistory = 'No complaint history';
  static const String noHistorySubtitle = 'Completed and rejected complaints will appear here';
  static const String searchHint = 'Search by name or phone...';
  static const String thisMonth = 'This Month';
  static const String dateRange = 'Date Range';
  static const String clear = 'Clear';
  static const String reopen = 'Reopen';
  static const String complaintReopened = 'Complaint reopened.';

  // Complaint Details
  static const String complaintDetails = 'Complaint Details';
  static const String customerInfo = 'Customer Info';
  static const String complaintInfo = 'Complaint Info';
  static const String recording = 'Recording';
  static const String playRecording = 'Play Recording';
  static const String recordingNotFound = 'Recording file not found';
  static const String completionInfo = 'Completion Info';
  static const String rejectionInfo = 'Rejection Info';
  static const String rejectedDate = 'Rejected Date';
  static const String completedDate = 'Completed Date';
  static const String callCustomer = 'Call Customer';

  // Settings
  static const String recordingFolder = 'Recording Folder';
  static const String notConfigured = 'Not configured';
  static const String folderUpdated = 'Folder updated. Rescan recordings to apply.';
  static const String exportCsv = 'Export to CSV';
  static const String exportCsvSubtitle = 'Export all complaints as CSV file';
  static const String exportSuccess = 'Exported to:';
  static const String backupDatabase = 'Backup Database';
  static const String backupSubtitle = 'Save a backup of all data';
  static const String backupSuccess = 'Backup saved to:';
  static const String restoreDatabase = 'Restore Database';
  static const String restoreSubtitle = 'Restore from a previous backup';
  static const String restoreWarning =
      'This will REPLACE all current data. This cannot be undone. Continue?';
  static const String restoreSuccess = 'Database restored. Restart the app for changes to take effect.';
  static const String appInfo = 'Version 1.0.0';

  // Permissions
  static const String permissionsDenied = 'Permissions Required';
  static const String permissionsExplanation =
      'This app needs the following permissions to function:\n\n'
      '• Storage: Read MIUI call recordings\n'
      '• Call Log: Identify incoming calls\n'
      '• Contacts: Look up caller names\n'
      '• Phone: Make calls to customers';
  static const String grantPermissions = 'Grant Permissions';

  // Audio Player
  static const String audioPlayerError = 'Unable to play recording';
  static const String stopPlayback = 'Stop';

  // General actions
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String reject = 'Reject';
  static const String complete = 'Complete';
  static const String save = 'Save';
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String error = 'Error';
  static const String unknown = 'Unknown';
}
