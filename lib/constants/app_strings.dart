/// Application string constants for better maintainability and localization support
class AppStrings {
  // App Info
  static const String appName = 'GateEase';
  static const String appTagline = 'Smart Society Management';

  // Common Actions
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String close = 'Close';
  static const String dismiss = 'Dismiss';
  static const String retry = 'Retry';
  static const String refresh = 'Refresh';
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String comingSoon = 'Coming Soon!';

  // Authentication
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";

  // User Roles
  static const String admin = 'Admin';
  static const String resident = 'Resident';
  static const String guard = 'Guard';
  static const String vendor = 'Vendor';

  // Navigation
  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  static const String chat = 'Chat';
  static const String back = 'Back';

  // Features
  static const String visitorManagement = 'Visitor Management';
  static const String complaints = 'Complaints';
  static const String amenities = 'Amenities';
  static const String payments = 'Payments';
  static const String announcements = 'Announcements';
  static const String vendors = 'Vendors';
  static const String analytics = 'Analytics';
  static const String userManagement = 'User Management';
  static const String emergencyAlert = 'Emergency Alert';

  // Visitor Management
  static const String addVisitor = 'Add Visitor';
  static const String visitorName = 'Visitor Name';
  static const String visitorPhone = 'Phone Number';
  static const String visitingFlat = 'Visiting Flat';
  static const String purpose = 'Purpose';
  static const String vehicleType = 'Vehicle Type';
  static const String preApprovedVisitors = 'Pre-approved Visitors';
  static const String allVisitors = 'All Visitors';
  static const String pendingApproval = 'Pending Approval';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
  static const String checkedIn = 'Checked In';
  static const String checkedOut = 'Checked Out';

  // Complaints
  static const String raiseComplaint = 'Raise Complaint';
  static const String complaintCategory = 'Category';
  static const String complaintDescription = 'Description';
  static const String addPhoto = 'Add Photo';
  static const String photoSelected = 'Photo selected';
  static const String openComplaints = 'Open Complaints';
  static const String inProgressComplaints = 'In Progress';
  static const String resolvedComplaints = 'Resolved';
  static const String complaintSubmitted = 'Complaint submitted successfully';

  // Amenities
  static const String bookAmenity = 'Book Amenity';
  static const String amenityName = 'Amenity Name';
  static const String bookingDate = 'Booking Date';
  static const String timeSlot = 'Time Slot';
  static const String myBookings = 'My Bookings';
  static const String availableSlots = 'Available Slots';
  static const String bookedSlots = 'Booked Slots';

  // Payments
  static const String makePayment = 'Make Payment';
  static const String paymentHistory = 'Payment History';
  static const String amount = 'Amount';
  static const String paymentMethod = 'Payment Method';
  static const String transactionId = 'Transaction ID';
  static const String paymentSuccessful = 'Payment Successful';
  static const String paymentFailed = 'Payment Failed';

  // Vendor Services
  static const String services = 'Services';
  static const String createService = 'Create Service';
  static const String serviceName = 'Service Name';
  static const String serviceDescription = 'Service Description';
  static const String servicePrice = 'Price';
  static const String serviceCategory = 'Category';
  static const String contactVendor = 'Contact Vendor';
  static const String viewServices = 'View Services';

  // Ads & Campaigns
  static const String createAd = 'Create Ad';
  static const String adCampaigns = 'Ad Campaigns';
  static const String adTitle = 'Ad Title';
  static const String adDescription = 'Ad Description';
  static const String adDuration = 'Duration';
  static const String adBudget = 'Budget';
  static const String sponsoredAds = 'Sponsored Ads';

  // Communication
  static const String sendMessage = 'Send Message';
  static const String typeMessage = 'Type a message...';
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String lastSeen = 'Last seen';
  static const String messageDelivered = 'Delivered';
  static const String messageRead = 'Read';

  // Status Messages
  static const String pending = 'Pending';
  static const String active = 'Active';
  static const String inactive = 'Inactive';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';
  static const String expired = 'Expired';

  // Error Messages
  static const String errorGeneric = 'An unexpected error occurred. Please try again.';
  static const String errorNetwork = 'No internet connection. Please check your network.';
  static const String errorAuth = 'Authentication failed. Please try again.';
  static const String errorPermission = 'You don\'t have permission to perform this action.';
  static const String errorNotFound = 'Requested data not found.';
  static const String errorTimeout = 'Request timed out. Please try again.';

  // Success Messages
  static const String successGeneric = 'Operation completed successfully';
  static const String successSaved = 'Data saved successfully';
  static const String successDeleted = 'Data deleted successfully';
  static const String successUpdated = 'Data updated successfully';

  // Validation Messages
  static const String validationRequired = 'This field is required';
  static const String validationEmail = 'Please enter a valid email address';
  static const String validationPhone = 'Please enter a valid phone number';
  static const String validationPassword = 'Password must be at least 6 characters';
  static const String validationPasswordMatch = 'Passwords do not match';
  static const String validationMinLength = 'Minimum length required';
  static const String validationMaxLength = 'Maximum length exceeded';

  // Confirmation Messages
  static const String confirmDelete = 'Are you sure you want to delete this item?';
  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmCancel = 'Are you sure you want to cancel?';
  static const String confirmSubmit = 'Are you sure you want to submit?';

  // Feature Coming Soon Messages
  static const String notificationsComingSoon = 'Notifications coming soon!';
  static const String languageSupportComingSoon = 'Multi-language support coming soon!';
  static const String addUserComingSoon = 'Add user feature coming soon!';
  static const String contactVendorComingSoon = 'Contact vendor feature coming soon!';

  // Time & Date
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String tomorrow = 'Tomorrow';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String lastWeek = 'Last Week';
  static const String lastMonth = 'Last Month';

  // Units & Measurements
  static const String rupees = '₹';
  static const String perHour = 'per hour';
  static const String perDay = 'per day';
  static const String perMonth = 'per month';
  static const String minutes = 'minutes';
  static const String hours = 'hours';
  static const String days = 'days';

  // File & Media
  static const String selectImage = 'Select Image';
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String imageSelected = 'Image selected';
  static const String noImageSelected = 'No image selected';
  static const String uploadingImage = 'Uploading image...';
  static const String imageUploadFailed = 'Failed to upload image';

  // Search & Filter
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sortBy = 'Sort by';
  static const String searchHint = 'Search...';
  static const String noResults = 'No results found';
  static const String clearFilter = 'Clear Filter';

  // Emergency
  static const String emergency = 'Emergency';
  static const String sosAlert = 'SOS Alert';
  static const String emergencyContacts = 'Emergency Contacts';
  static const String callEmergency = 'Call Emergency';
  static const String emergencyAlertSent = 'Emergency alert sent successfully!';

  // Society Info
  static const String societyName = 'Society Name';
  static const String flatNumber = 'Flat Number';
  static const String blockNumber = 'Block Number';
  static const String wingNumber = 'Wing Number';
  static const String societyAddress = 'Society Address';
}
