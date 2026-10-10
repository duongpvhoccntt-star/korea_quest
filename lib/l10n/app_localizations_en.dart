// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KoreaQuest';

  @override
  String get cultureAdventure => 'CULTURE ADVENTURE';

  @override
  String get explore => 'Explore';

  @override
  String get passport => 'Passport';

  @override
  String get achievements => 'Achievements';

  @override
  String get profile => 'Profile';

  @override
  String get myProfile => 'My profile';

  @override
  String get settings => 'Settings';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get start => 'Get started';

  @override
  String get startJourney => 'Start the journey';

  @override
  String get openNavigation => 'Open navigation';

  @override
  String get openAccountMenu => 'Open account menu';

  @override
  String levelWithXp(int level, int xp) {
    return 'Level $level · $xp XP';
  }

  @override
  String get language => 'Language';

  @override
  String get languageDescription =>
      'The app detects your device language and remembers your choice.';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get korean => '한국어';

  @override
  String get translationUnavailable =>
      'This content is not translated yet; the Vietnamese version is shown.';

  @override
  String get fallbackBadge => 'Vietnamese version';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Try again';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get backExplore => 'Back to Explore';

  @override
  String get loadJourneyError => 'Could not load journey data.';

  @override
  String get koreaMap => 'Map of Korea';

  @override
  String get chooseFirstLocation =>
      'Choose your first destination to begin the journey.';

  @override
  String get whereStart => 'Where would you like to start?';

  @override
  String exploreHeroDescription(String name) {
    return 'Explore Korean culture one destination at a time. $name, your journey is waiting!';
  }

  @override
  String get continueJourney => 'Continue journey';

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String get viewAll => 'View all';

  @override
  String get explorationProgress => 'Exploration progress';

  @override
  String completedLocationsProgress(int completed, int total) {
    return '$completed/$total destinations';
  }

  @override
  String get badgeCollection => 'Badge collection';

  @override
  String get completed => 'Completed';

  @override
  String get exploring => 'Exploring';

  @override
  String get all => 'All';

  @override
  String get done => 'Done';

  @override
  String get stage => 'Stage';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get exploreKorea => 'EXPLORE KOREA';

  @override
  String get exploreIntro =>
      'Choose a point on the map to discover its scenery, history, culture, food, and fun challenges.';

  @override
  String get continueLatestJourney => 'Continue latest journey';

  @override
  String get searchLocationsHint =>
      'Search destinations, cities, or experiences...';

  @override
  String get locationList => 'Destination list';

  @override
  String loadMapError(String error) {
    return 'Could not load the destination map: $error';
  }

  @override
  String get noMatchingLocations => 'No matching destinations';

  @override
  String get changeSearchOrFilter =>
      'Try another search term or filter to see more places on the map.';

  @override
  String chooseLocation(String name) {
    return 'Choose $name';
  }

  @override
  String get durationUpdating => 'Duration being updated';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get journeyBadge => 'Journey badge';

  @override
  String get saveToJourney => 'Save to journey';

  @override
  String publishedLocationsWaiting(int count) {
    return '$count published destinations are waiting to be explored.';
  }

  @override
  String get content => 'Content';

  @override
  String get readyToExplore => 'Ready to explore';

  @override
  String get publishedLocations => 'Published destinations';

  @override
  String locationCount(int count) {
    return '$count destinations';
  }

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get resetMap => 'Reset map';

  @override
  String get collection => 'Collection';

  @override
  String get passportTitle => 'Explorer passport';

  @override
  String get passportDescription =>
      'Every stamp tells the story of a place you have truly explored.';

  @override
  String get loadPassportError => 'Could not load your passport.';

  @override
  String get milestones => 'Milestones';

  @override
  String get yourAchievements => 'Your achievements';

  @override
  String get achievementsDescription =>
      'Track the milestones you have conquered along the journey.';

  @override
  String get loadBadgesError => 'Could not load badges.';

  @override
  String get forbiddenTitle => 'You do not have access';

  @override
  String get forbiddenMessage => 'Return to your journey area.';

  @override
  String get offlineTitle => 'You are offline';

  @override
  String get offlineMessage =>
      'Check your connection and try again when the network is stable.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorMessage => 'An error occurred. Please try again.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundMessage => 'This route is not on the KoreaQuest map.';

  @override
  String get customizeSystem => 'System preferences';

  @override
  String get settingsDescription =>
      'Manage your account, security, notifications, and exploration data.';

  @override
  String get accountSecurity => 'Account & security';

  @override
  String get administrator => 'Administrator';

  @override
  String get student => 'Learner';

  @override
  String roleLine(String name, String role) {
    return '$name · Role: $role';
  }

  @override
  String get accountPassword => 'Account password';

  @override
  String get changePassword => 'Change password';

  @override
  String get experienceOptions => 'Experience options';

  @override
  String get notifications => 'Journey notifications';

  @override
  String get notificationsDescription =>
      'Reminders about destinations, badges, and learning streaks';

  @override
  String get reducedMotion => 'Reduce motion';

  @override
  String get reducedMotionDescription =>
      'Limit animations for a more comfortable experience';

  @override
  String get dataStorage => 'Data & storage';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearCacheDescription =>
      'Remove temporary resources stored on this device';

  @override
  String get cleanUp => 'Clean up';

  @override
  String get cacheCleaned => 'The demo cache has been cleared.';

  @override
  String get resetProgress => 'Reset learning progress';

  @override
  String get resetProgressDescription =>
      'Return to level 1 and 0 XP to experience the journey again';

  @override
  String get resetProgressQuestion => 'Reset learning progress?';

  @override
  String get resetProgressMessage =>
      'This will return you to level 1 and 0 XP, and lock completed destinations again.';

  @override
  String get reset => 'Reset';

  @override
  String get resetProgressSuccess => 'Learning progress has been reset.';

  @override
  String get resetProgressError =>
      'Could not reset progress. Please try again.';

  @override
  String get session => 'Signed-in session';

  @override
  String get sessionDescription =>
      'Sign out of this device when you finish your journey.';

  @override
  String get signOutAccount => 'Sign out';

  @override
  String get signOutQuestion => 'Sign out of KoreaQuest?';

  @override
  String get signOutMessage =>
      'Are you sure you want to sign out of the current account?';

  @override
  String get signOutSuccess => 'Signed out successfully.';

  @override
  String get signOutError => 'Could not sign out. Please try again.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password (at least 8 characters)';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get fillAllFields => 'Please complete all fields.';

  @override
  String get passwordMin8 =>
      'The new password must contain at least 8 characters.';

  @override
  String get passwordMismatch => 'The password confirmation does not match.';

  @override
  String get changePasswordSuccess => 'Password changed successfully!';

  @override
  String get genericError => 'Something went wrong. Please try again later.';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get recoverPassword => 'Recover password';

  @override
  String get fullName => 'Full name';

  @override
  String get displayName => 'Display name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get createAccount => 'Create account';

  @override
  String get signInJourney => 'Sign in to your journey';

  @override
  String get sendInstructions => 'Send instructions';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get openPassport => 'Open your KoreaQuest passport';

  @override
  String get registerDescription =>
      'Create a traveler profile to earn XP, badges, and stamps at every destination.';

  @override
  String get loginDescription =>
      'Welcome back to your Korean culture travel journal.';

  @override
  String get forgotDescription =>
      'Enter your email to receive password recovery instructions.';

  @override
  String get emailRequired => 'Please enter your email.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get passwordRequired => 'Please enter your password.';

  @override
  String get fullNameRequired => 'Please enter your full name.';

  @override
  String get confirmationMismatch =>
      'The password confirmation does not match.';

  @override
  String get passwordAtLeast8 =>
      'The password must contain at least 8 characters.';

  @override
  String get resetEmailSent =>
      'If the email exists, recovery instructions have been sent.';

  @override
  String get accountCreatedVerify =>
      'Your account was created. Check your email to verify it.';

  @override
  String get accountCreated => 'Account created successfully!';

  @override
  String get adminSignedIn => 'Administrator signed in successfully.';

  @override
  String get signedIn => 'Signed in successfully.';

  @override
  String get adminNoAccess =>
      'This account does not have administrator access.';

  @override
  String get studentQuickSignedIn => 'Learner demo signed in successfully.';

  @override
  String get passwordHelp =>
      'Use at least 8 characters to protect your account.';

  @override
  String get travelTagline => '한국 여행 · Explore Korea';

  @override
  String get continueKoreaJourney => 'Continue your journey through Korea';

  @override
  String get travelVisualDescription =>
      'Remember every step through fascinating places, collect travel stamps, and discover a vibrant cultural treasury.';

  @override
  String get quickDemoAccounts => 'Quick demo accounts';

  @override
  String get quickDemoDescription => 'Choose a role to enter the demo.';

  @override
  String get adminDemoDescription => 'Manage and review destinations';

  @override
  String get studentDemoDescription => 'Experience the cultural journey';

  @override
  String get earnedBadgesMessage =>
      'Earned badges are saved to your collection';

  @override
  String get quizWaiting => '50+ culture quizzes are waiting for you';

  @override
  String get featuredDestinations => 'Featured destinations';

  @override
  String get cultureExperiences => 'Cultural experiences';

  @override
  String get cuisine => 'Cuisine';

  @override
  String get opening => 'Introduction';

  @override
  String get overview => 'Overview';

  @override
  String get history => 'History';

  @override
  String get destinations => 'Destinations';

  @override
  String get experiences => 'Experiences';

  @override
  String get funFacts => 'Fun facts';

  @override
  String get quiz => 'Quiz';

  @override
  String get travel => 'Travel';

  @override
  String get backToKoreaMap => 'Back to the Korea map';

  @override
  String stageProgress(int current) {
    return 'Stage $current/9';
  }

  @override
  String get saveLocation => 'Save destination';

  @override
  String stageLabel(int number, String label) {
    return 'Stage $number: $label';
  }

  @override
  String continueTo(String stage) {
    return 'Continue to $stage';
  }

  @override
  String get startExploring => 'Start exploring';

  @override
  String get journeyOpening => 'Journey introduction';

  @override
  String get generalInformation => 'General information';

  @override
  String get region => 'Region';

  @override
  String get locationType => 'Destination type';

  @override
  String get englishName => 'English name';

  @override
  String get historyHeritage => 'History & heritage';

  @override
  String get culturalEtiquette => 'Cultural etiquette';

  @override
  String get shouldDo => 'Do';

  @override
  String get shouldNotDo => 'Do not';

  @override
  String get explorationChallenge => 'Exploration challenge';

  @override
  String get travelInformation => 'Travel information';

  @override
  String get checkAnswer => 'Check answer';

  @override
  String get listenRead => 'Listen';

  @override
  String get pauseReading => 'Pause';

  @override
  String get resumeReading => 'Resume';

  @override
  String get stopReading => 'Stop reading';

  @override
  String get correctAnswer => 'Correct!';

  @override
  String get incorrectAnswer => 'Not quite, but the task is still complete.';

  @override
  String quizScoringError(String error) {
    return 'Could not score the quiz: $error';
  }

  @override
  String get journeyOpeningDescription =>
      'Begin your journey through this destination.';

  @override
  String get overviewDescription =>
      'Identity, description, map, and notable highlights.';

  @override
  String get historyDescription =>
      'Discover the events and cultural stories that shaped its colorful past.';

  @override
  String get etiquetteDescription =>
      'Helpful do and do-not guidance for respectful interactions.';

  @override
  String get funFactsDescription =>
      'Interesting facts to collect along your journey.';

  @override
  String get quizDescription =>
      'Complete the challenge to earn XP, even when an answer is not correct.';

  @override
  String get travelDescription =>
      'Time-sensitive information includes its source and update date.';

  @override
  String get travelDisclaimer =>
      'Information may change. Check official sources before your visit.';

  @override
  String get noQuickFacts => 'No quick facts are available yet.';

  @override
  String get historyUpdating => 'History content is being updated.';

  @override
  String get noFunFacts => 'No fun facts are available yet.';

  @override
  String get noQuiz => 'No quiz questions are available yet.';

  @override
  String taskRewards(int count) {
    return '$count tasks · +20 XP for a correct answer · +5 XP on completion';
  }

  @override
  String get editProfile => 'Edit profile';

  @override
  String profileOf(String name) {
    return '$name’s profile';
  }

  @override
  String get backToProfile => 'Back to profile';

  @override
  String xpToNextLevel(int xp) {
    return '$xp XP to the next level';
  }

  @override
  String get journeyOverview => 'Journey overview';

  @override
  String get availableToExplore => 'Available to explore';

  @override
  String get learningStreak => 'Learning streak';

  @override
  String get continuing => 'In progress';

  @override
  String get noCurrentLocation => 'No destination is currently in progress.';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get bio => 'Bio';

  @override
  String get displayInformation => 'Display information';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saving => 'Saving…';

  @override
  String get changesSaved => 'Changes saved.';

  @override
  String get profileFieldsRequired =>
      'Full name and display name cannot be empty.';

  @override
  String get saveFailed => 'Could not save. Please try again.';

  @override
  String get bioHint => 'Your exploration story…';

  @override
  String get loadProfileError => 'Could not load the profile.';

  @override
  String get joined => 'Joined';

  @override
  String get landingLoadError =>
      'Could not load destinations for the introduction page.';

  @override
  String get noLocations => 'There are no destinations to begin the journey.';

  @override
  String get discoverYourWay => 'Discover Korea your way';

  @override
  String get heroLineOne => 'Every destination,\n';

  @override
  String get heroLineTwo => 'a new chapter of adventure.';

  @override
  String get heroDescription =>
      'Read stories, solve small challenges, and collect unique stamps across Korea’s famous destinations.';

  @override
  String get howItWorks => 'See how it works';

  @override
  String get learnByExperience => 'Learn by experience\n';

  @override
  String get rewardingNoPressure => 'No pressure, always rewarding';

  @override
  String get adventureMap => 'Adventure map';

  @override
  String get currentJourney => 'Current journey';

  @override
  String percentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get journeyLearning => 'Journey-based discovery';

  @override
  String get journeyLearningDesc => 'A connected path with a clear next goal';

  @override
  String get earnXp => 'Earn XP & level up';

  @override
  String get earnXpDesc => 'Every answer moves you forward';

  @override
  String get collectStamps => 'Collect stamps';

  @override
  String get collectStampsDesc => 'Keep a memory from every destination';

  @override
  String get threeStages => 'Three discovery stages';

  @override
  String get cultureIsAGame =>
      'Culture is not just for reading.\nIt is a game.';

  @override
  String get threeStagesDesc =>
      'Each destination is a story told through three short, visual, and rewarding stages.';

  @override
  String get chooseStoryStart => 'Choose where your story begins';

  @override
  String get featuredLocationsDesc =>
      'Continue your current journey or open a new cultural story.';

  @override
  String get inProgress => 'In progress';

  @override
  String get locations => 'Destinations';

  @override
  String get journey => 'Journey';

  @override
  String get badges => 'Badges';

  @override
  String get support => 'Support';

  @override
  String get faq => 'Frequently asked questions';

  @override
  String get contact => 'Contact';

  @override
  String get legal => 'Legal';

  @override
  String get privacy => 'Privacy';

  @override
  String get terms => 'Terms';

  @override
  String get footerDescription =>
      'Explore Korean culture through challenges, stories, and memorable travel stamps.';

  @override
  String get footerCopyright =>
      '© 2026 KoreaQuest · A Korean culture discovery project.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get searchHint => 'Search destinations and journeys…';

  @override
  String get processing => 'Processing…';

  @override
  String get confirm => 'Confirm';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String avatarOf(String name) {
    return '$name’s avatar';
  }

  @override
  String xpProgress(int current, int next) {
    return '$current of $next XP';
  }

  @override
  String nextLevel(int xp, int level) {
    return '$xp XP · Level $level';
  }

  @override
  String get featuredDescription => 'Notable highlights at this destination.';

  @override
  String get noFeatured => 'No featured destinations are available yet.';

  @override
  String destinationNumber(int number) {
    return 'Destination $number';
  }

  @override
  String get address => 'Address';

  @override
  String get activities => 'Activities';

  @override
  String get categories => 'Categories';

  @override
  String get didYouKnow => 'Did you know?';

  @override
  String get cultureDescription =>
      'Origins, recognizable features, and etiquette tips.';

  @override
  String get noCulture => 'No cultural experiences are available yet.';

  @override
  String experienceNumber(int number) {
    return 'Experience $number';
  }

  @override
  String get originMeaning => 'Origin & meaning';

  @override
  String get recognizableFeatures => 'Recognizable features';

  @override
  String get relatedExperience => 'Related experience';

  @override
  String get cuisineDescription =>
      'Food, ingredients, flavors, and places to try it.';

  @override
  String get noCuisine => 'No cuisine content is available yet.';

  @override
  String foodNumber(int number) {
    return 'Dish $number';
  }

  @override
  String get specialFeature => 'Special feature';

  @override
  String get experiencePlaces => 'Where to try it';

  @override
  String get exploreLocation => 'Destination';

  @override
  String get relatedPeople => 'Related people';

  @override
  String get mediaSource => 'Image/video source';

  @override
  String get sourceLink => 'Source link';

  @override
  String get viewMediaSource => 'View media source';

  @override
  String historicalMilestone(int number) {
    return 'Historical milestone $number';
  }

  @override
  String get collapse => 'Collapse';

  @override
  String get openStatus => 'open';

  @override
  String get viewedStatus => 'viewed';

  @override
  String get unviewedStatus => 'not viewed';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get ticketPrice => 'Ticket price';

  @override
  String get duration => 'Duration';

  @override
  String get bestTime => 'Best time';

  @override
  String get directions => 'Directions';

  @override
  String get tip => 'Tip';

  @override
  String get travelerNotes => 'Traveler notes';

  @override
  String get note => 'Note';

  @override
  String get updating => 'Updating';

  @override
  String get imageUpdating => 'Image being updated';

  @override
  String get previousImage => 'Previous image';

  @override
  String get nextImage => 'Next image';

  @override
  String imagePosition(int current, int total) {
    return 'Image $current of $total';
  }

  @override
  String get areaMap => 'Area map';

  @override
  String get moveUp => 'Move up';

  @override
  String get checkInStageDescription =>
      'View images, videos, and key moments in history before answering the opening question.';

  @override
  String get cultureStageDescription =>
      'Understand rituals, architecture, and everyday stories through short interactive tasks.';

  @override
  String get vocabularyStageDescription =>
      'Learn words in context and complete the final challenge to earn a stamp.';

  @override
  String loadLocationContentError(String error) {
    return 'Could not load destination content: $error';
  }

  @override
  String get locationNotFound => 'Destination not found';

  @override
  String get locationNotPublished =>
      'This destination is not published yet or is being updated.';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get avatarDescription =>
      'Choose a Korean culture character or upload an image from your device.';

  @override
  String get uploadFromDevice => 'Upload from device';

  @override
  String get configureGemini => 'Configure Gemini AI';

  @override
  String get selectedModel => 'Selected model:';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get aiVoiceCommand => 'AI commands';

  @override
  String get apiKeySettings => 'API key settings';

  @override
  String get testLabel => 'Test:';

  @override
  String get openProfileNow => 'Open profile now';

  @override
  String get discoverNow => 'Discover now';

  @override
  String get profileCommandCalled => 'Called: navigateToProfile';

  @override
  String get aiCommandHint => 'Enter a command (e.g. \"Go to my profile\")...';

  @override
  String get callingGemini => 'Calling Gemini...';

  @override
  String get sendToAi => 'Send command to AI';

  @override
  String functionCallComplete(String calls) {
    return 'Function Calling: $calls → Page opened!';
  }

  @override
  String get hideRawJson => 'Hide raw JSON';

  @override
  String get showRawJson => 'View raw JSON from Gemini';

  @override
  String get openOnYoutube => 'Open on YouTube';

  @override
  String openVideoOnYoutube(String label) {
    return 'Open $label on YouTube';
  }

  @override
  String get invalidYoutube => 'The YouTube link is invalid.';

  @override
  String get invalidYoutubeEmbed =>
      'The YouTube link is invalid or cannot be embedded.';

  @override
  String get chooseAvatar => 'OR CHOOSE AN AVATAR';

  @override
  String get summaryStageDescription =>
      'Review the journey and celebrate the rewards you have earned.';

  @override
  String get hanoiVietnam => 'Hanoi, Vietnam';

  @override
  String get moveDown => 'Move down';

  @override
  String get demoEmailHint => 'Email or admin (demo mode)';

  @override
  String get seoulCapital => 'Seoul capital';

  @override
  String get busanCity => 'Busan';

  @override
  String levelExplorer(int level) {
    return 'LEVEL $level · EXPLORER';
  }
}
