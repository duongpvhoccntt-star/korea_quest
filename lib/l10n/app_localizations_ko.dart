// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'KoreaQuest';

  @override
  String get cultureAdventure => '한국 문화 탐험';

  @override
  String get home => '홈';

  @override
  String get explore => '탐험';

  @override
  String get passport => '여권';

  @override
  String get achievements => '업적';

  @override
  String get profile => '프로필';

  @override
  String get myProfile => '내 프로필';

  @override
  String get settings => '설정';

  @override
  String get signIn => '로그인';

  @override
  String get signOut => '로그아웃';

  @override
  String get start => '시작하기';

  @override
  String get startJourney => '여정 시작하기';

  @override
  String get openNavigation => '탐색 메뉴 열기';

  @override
  String get openAccountMenu => '계정 메뉴 열기';

  @override
  String levelWithXp(int level, int xp) {
    return '레벨 $level · $xp XP';
  }

  @override
  String get language => '언어';

  @override
  String get languageDescription => '기기 언어를 자동으로 감지하고 선택을 기억합니다.';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get korean => '한국어';

  @override
  String get translationUnavailable => '아직 번역되지 않아 베트남어 내용을 표시합니다.';

  @override
  String get fallbackBadge => '베트남어 버전';

  @override
  String get loading => '불러오는 중…';

  @override
  String get retry => '다시 시도';

  @override
  String get close => '닫기';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get backHome => '홈으로';

  @override
  String get loadJourneyError => '여정 데이터를 불러오지 못했습니다.';

  @override
  String get koreaMap => '한국 지도';

  @override
  String get chooseFirstLocation => '첫 여행지를 선택해 여정을 시작하세요.';

  @override
  String get whereStart => '어디에서 시작할까요?';

  @override
  String homeHeroDescription(String name) {
    return '여행지마다 새로운 한국 문화를 만나 보세요. $name님, 여정이 기다리고 있어요!';
  }

  @override
  String get continueJourney => '여정 계속하기';

  @override
  String get recommendedForYou => '추천 여행지';

  @override
  String get viewAll => '전체 보기';

  @override
  String get explorationProgress => '탐험 진행도';

  @override
  String badgesProgress(int completed, int total) {
    return '배지 $completed/$total';
  }

  @override
  String get badgeCollection => '배지 컬렉션';

  @override
  String get completed => '완료';

  @override
  String get exploring => '탐험 중';

  @override
  String get locked => '잠김';

  @override
  String get all => '전체';

  @override
  String get done => '완료';

  @override
  String get notOpened => '잠김';

  @override
  String get stage => '단계';

  @override
  String get comingSoon => '준비 중';

  @override
  String get exploreKorea => '한국 탐험';

  @override
  String get exploreIntro => '지도에서 여행지를 선택하고 풍경, 역사, 문화, 음식과 재미있는 도전을 만나 보세요.';

  @override
  String get continueLatestJourney => '최근 여정 계속하기';

  @override
  String get searchLocationsHint => '여행지, 도시 또는 체험 검색...';

  @override
  String get locationList => '여행지 목록';

  @override
  String loadMapError(String error) {
    return '여행지 지도를 불러오지 못했습니다: $error';
  }

  @override
  String get noMatchingLocations => '일치하는 여행지가 없습니다';

  @override
  String get changeSearchOrFilter => '검색어나 필터를 바꿔 지도에서 더 많은 여행지를 찾아보세요.';

  @override
  String chooseLocation(String name) {
    return '$name 선택';
  }

  @override
  String get durationUpdating => '소요 시간 업데이트 중';

  @override
  String minutes(int count) {
    return '$count분';
  }

  @override
  String get journeyBadge => '여정 배지';

  @override
  String get saveToJourney => '여정에 저장';

  @override
  String publishedLocationsWaiting(int count) {
    return '공개된 여행지 $count곳이 여러분을 기다립니다.';
  }

  @override
  String get content => '콘텐츠';

  @override
  String get readyToExplore => '탐험 준비 완료';

  @override
  String get publishedLocations => '공개된 여행지';

  @override
  String locationCount(int count) {
    return '여행지 $count곳';
  }

  @override
  String get zoomIn => '확대';

  @override
  String get zoomOut => '축소';

  @override
  String get resetMap => '지도 초기화';

  @override
  String get collection => '컬렉션';

  @override
  String get passportTitle => '탐험 여권';

  @override
  String get passportDescription => '도장마다 직접 지나온 여행지의 이야기가 담겨 있습니다.';

  @override
  String get loadPassportError => '여권을 불러오지 못했습니다.';

  @override
  String get milestones => '이정표';

  @override
  String get yourAchievements => '나의 업적';

  @override
  String get achievementsDescription => '여정에서 달성한 이정표를 확인하세요.';

  @override
  String get loadBadgesError => '배지를 불러오지 못했습니다.';

  @override
  String get forbiddenTitle => '접근 권한이 없습니다';

  @override
  String get forbiddenMessage => '내 여정 화면으로 돌아가 주세요.';

  @override
  String get offlineTitle => '오프라인 상태입니다';

  @override
  String get offlineMessage => '연결을 확인한 뒤 네트워크가 안정되면 다시 시도하세요.';

  @override
  String get errorTitle => '문제가 발생했습니다';

  @override
  String get errorMessage => '오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get notFoundTitle => '페이지를 찾을 수 없습니다';

  @override
  String get notFoundMessage => 'KoreaQuest 지도에 없는 경로입니다.';

  @override
  String get customizeSystem => '환경 설정';

  @override
  String get settingsDescription => '계정, 보안, 알림과 탐험 데이터를 관리하세요.';

  @override
  String get accountSecurity => '계정 및 보안';

  @override
  String get administrator => '관리자';

  @override
  String get student => '학습자';

  @override
  String roleLine(String name, String role) {
    return '$name · 역할: $role';
  }

  @override
  String get accountPassword => '계정 비밀번호';

  @override
  String get changePassword => '비밀번호 변경';

  @override
  String get experienceOptions => '사용 환경';

  @override
  String get notifications => '여정 알림';

  @override
  String get notificationsDescription => '여행지, 배지와 학습 연속 기록 알림';

  @override
  String get reducedMotion => '동작 줄이기';

  @override
  String get reducedMotionDescription => '더 편안하게 이용할 수 있도록 애니메이션을 줄입니다';

  @override
  String get dataStorage => '데이터 및 저장 공간';

  @override
  String get clearCache => '캐시 지우기';

  @override
  String get clearCacheDescription => '기기에 저장된 임시 리소스를 삭제합니다';

  @override
  String get cleanUp => '정리';

  @override
  String get cacheCleaned => '데모 캐시를 정리했습니다.';

  @override
  String get resetProgress => '학습 진행도 초기화';

  @override
  String get resetProgressDescription => '레벨 1, XP 0으로 돌아가 여정을 다시 체험합니다';

  @override
  String get resetProgressQuestion => '학습 진행도를 초기화할까요?';

  @override
  String get resetProgressMessage => '레벨 1, XP 0으로 돌아가며 완료한 여행지가 다시 잠깁니다.';

  @override
  String get reset => '초기화';

  @override
  String get resetProgressSuccess => '학습 진행도를 초기화했습니다.';

  @override
  String get resetProgressError => '진행도를 초기화하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get session => '로그인 세션';

  @override
  String get sessionDescription => '여정을 마치면 이 기기에서 로그아웃하세요.';

  @override
  String get signOutAccount => '계정 로그아웃';

  @override
  String get signOutQuestion => 'KoreaQuest에서 로그아웃할까요?';

  @override
  String get signOutMessage => '현재 계정에서 로그아웃하시겠어요?';

  @override
  String get signOutSuccess => '로그아웃했습니다.';

  @override
  String get signOutError => '로그아웃하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get currentPassword => '현재 비밀번호';

  @override
  String get newPassword => '새 비밀번호 (8자 이상)';

  @override
  String get confirmNewPassword => '새 비밀번호 확인';

  @override
  String get updatePassword => '비밀번호 업데이트';

  @override
  String get fillAllFields => '모든 항목을 입력해 주세요.';

  @override
  String get passwordMin8 => '새 비밀번호는 8자 이상이어야 합니다.';

  @override
  String get passwordMismatch => '비밀번호 확인이 일치하지 않습니다.';

  @override
  String get changePasswordSuccess => '비밀번호를 변경했습니다!';

  @override
  String get genericError => '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get register => '회원가입';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get recoverPassword => '비밀번호 찾기';

  @override
  String get fullName => '이름';

  @override
  String get displayName => '표시 이름';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get signInJourney => '여정에 로그인';

  @override
  String get sendInstructions => '안내 보내기';

  @override
  String get backToSignIn => '로그인으로 돌아가기';

  @override
  String get openPassport => 'KoreaQuest 여권 만들기';

  @override
  String get registerDescription => '여행자 프로필을 만들고 여행지마다 XP, 배지와 도장을 받으세요.';

  @override
  String get loginDescription => '한국 문화 탐험 일지에 돌아오신 것을 환영합니다.';

  @override
  String get forgotDescription => '비밀번호 복구 안내를 받을 이메일을 입력하세요.';

  @override
  String get emailRequired => '이메일을 입력해 주세요.';

  @override
  String get invalidEmail => '올바른 이메일을 입력해 주세요.';

  @override
  String get passwordRequired => '비밀번호를 입력해 주세요.';

  @override
  String get fullNameRequired => '이름을 입력해 주세요.';

  @override
  String get confirmationMismatch => '비밀번호 확인이 일치하지 않습니다.';

  @override
  String get passwordAtLeast8 => '비밀번호는 8자 이상이어야 합니다.';

  @override
  String get resetEmailSent => '이메일이 존재하면 복구 안내를 전송했습니다.';

  @override
  String get accountCreatedVerify => '계정을 만들었습니다. 이메일을 확인해 인증하세요.';

  @override
  String get accountCreated => '계정을 만들었습니다!';

  @override
  String get adminSignedIn => '관리자로 로그인했습니다.';

  @override
  String get signedIn => '로그인했습니다.';

  @override
  String get adminNoAccess => '이 계정에는 관리자 권한이 없습니다.';

  @override
  String get studentQuickSignedIn => '학습자 데모로 로그인했습니다.';

  @override
  String get passwordHelp => '계정 보호를 위해 8자 이상 사용하세요.';

  @override
  String get travelTagline => '한국 여행 · 한국 탐험';

  @override
  String get continueKoreaJourney => '나만의 한국 여정을 계속하세요';

  @override
  String get travelVisualDescription =>
      '매력적인 지역을 지나온 발자취를 남기고, 여행 도장을 모으며 다채로운 문화를 발견하세요.';

  @override
  String get quickDemoAccounts => '빠른 체험 계정';

  @override
  String get quickDemoDescription => '역할을 선택해 데모를 바로 체험하세요.';

  @override
  String get adminDemoDescription => '여행지 관리 및 검토';

  @override
  String get studentDemoDescription => '문화 여정 체험';

  @override
  String get unlockedBadges => '배지 3/12개 잠금 해제';

  @override
  String get quizWaiting => '50개 이상의 문화 퀴즈가 기다립니다';

  @override
  String get featuredDestinations => '주요 여행지';

  @override
  String get cultureExperiences => '문화 체험';

  @override
  String get cuisine => '음식';

  @override
  String get opening => '시작';

  @override
  String get overview => '개요';

  @override
  String get history => '역사';

  @override
  String get destinations => '여행지';

  @override
  String get experiences => '체험';

  @override
  String get funFacts => '재미있는 사실';

  @override
  String get quiz => '퀴즈';

  @override
  String get travel => '여행 정보';

  @override
  String get backToKoreaMap => '한국 지도로 돌아가기';

  @override
  String stageProgress(int current) {
    return '$current/9 단계';
  }

  @override
  String get saveLocation => '여행지 저장';

  @override
  String stageLabel(int number, String label) {
    return '$number단계: $label';
  }

  @override
  String continueTo(String stage) {
    return '$stage(으)로 계속';
  }

  @override
  String get startExploring => '탐험 시작';

  @override
  String get journeyOpening => '여정 시작';

  @override
  String get generalInformation => '기본 정보';

  @override
  String get region => '지역';

  @override
  String get locationType => '여행지 유형';

  @override
  String get englishName => '영문 이름';

  @override
  String get historyHeritage => '역사와 유산';

  @override
  String get culturalEtiquette => '문화 예절';

  @override
  String get shouldDo => '권장 사항';

  @override
  String get shouldNotDo => '주의 사항';

  @override
  String get explorationChallenge => '탐험 도전';

  @override
  String get travelInformation => '여행 정보';

  @override
  String get checkAnswer => '정답 확인';

  @override
  String get correctAnswer => '정답입니다!';

  @override
  String get incorrectAnswer => '아쉽지만 과제는 완료되었습니다.';

  @override
  String quizScoringError(String error) {
    return '퀴즈를 채점하지 못했습니다: $error';
  }

  @override
  String get journeyOpeningDescription => '이 여행지를 탐험하는 여정을 시작하세요.';

  @override
  String get overviewDescription => '기본 정보, 설명, 지도와 주요 포인트를 확인하세요.';

  @override
  String get historyDescription => '다채로운 과거를 만든 시간의 흔적과 문화 이야기를 만나 보세요.';

  @override
  String get etiquetteDescription => '서로를 존중하기 위한 권장 사항과 주의 사항입니다.';

  @override
  String get funFactsDescription => '여정에서 수집할 수 있는 흥미로운 사실입니다.';

  @override
  String get quizDescription => '정답이 아니어도 도전을 완료하고 XP를 받으세요.';

  @override
  String get travelDescription => '변경될 수 있는 정보에는 출처와 업데이트 날짜가 표시됩니다.';

  @override
  String get travelDisclaimer => '정보는 변경될 수 있습니다. 방문 전에 공식 출처를 확인하세요.';

  @override
  String get noQuickFacts => '표시할 요약 정보가 없습니다.';

  @override
  String get historyUpdating => '역사 콘텐츠를 업데이트하고 있습니다.';

  @override
  String get noFunFacts => '표시할 재미있는 사실이 없습니다.';

  @override
  String get noQuiz => '표시할 퀴즈가 없습니다.';

  @override
  String taskRewards(int count) {
    return '과제 $count개 · 정답 +20 XP · 완료 +5 XP';
  }

  @override
  String get editProfile => '프로필 편집';

  @override
  String profileOf(String name) {
    return '$name님의 프로필';
  }

  @override
  String get backToProfile => '프로필로 돌아가기';

  @override
  String xpToNextLevel(int xp) {
    return '다음 레벨까지 $xp XP';
  }

  @override
  String get journeyOverview => '여정 개요';

  @override
  String get availableToExplore => '탐험 가능';

  @override
  String get learningStreak => '학습 연속 기록';

  @override
  String get continuing => '진행 중';

  @override
  String get noCurrentLocation => '현재 진행 중인 여행지가 없습니다.';

  @override
  String get personalInformation => '개인 정보';

  @override
  String get bio => '소개';

  @override
  String get displayInformation => '표시 정보';

  @override
  String get saveChanges => '변경 사항 저장';

  @override
  String get saving => '저장 중…';

  @override
  String get changesSaved => '변경 사항을 저장했습니다.';

  @override
  String get profileFieldsRequired => '이름과 표시 이름을 입력해 주세요.';

  @override
  String get saveFailed => '저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get bioHint => '나의 탐험 이야기…';

  @override
  String get loadProfileError => '프로필을 불러오지 못했습니다.';

  @override
  String get joined => '가입일';

  @override
  String get landingLoadError => '소개 화면의 여행지 정보를 불러오지 못했습니다.';

  @override
  String get noLocations => '여정을 시작할 여행지가 없습니다.';

  @override
  String get discoverYourWay => '나만의 방식으로 한국을 탐험하세요';

  @override
  String get heroLineOne => '여행지마다,\n';

  @override
  String get heroLineTwo => '새로운 모험이 펼쳐집니다.';

  @override
  String get heroDescription =>
      '한국의 유명 여행지에서 옛이야기를 읽고 작은 도전을 풀며 특별한 도장을 모아 보세요.';

  @override
  String get howItWorks => '이용 방법 보기';

  @override
  String get learnByExperience => '체험하며 배우기\n';

  @override
  String get rewardingNoPressure => '부담 없이, 언제나 보상과 함께';

  @override
  String get adventureMap => '모험 지도';

  @override
  String get currentJourney => '현재 여정';

  @override
  String percentComplete(int percent) {
    return '$percent% 완료';
  }

  @override
  String get journeyLearning => '여정으로 탐험하기';

  @override
  String get journeyLearningDesc => '서로 이어진 목표를 따라 배워요';

  @override
  String get earnXp => 'XP 획득 & 레벨업';

  @override
  String get earnXpDesc => '모든 답변이 다음 단계로 이끌어요';

  @override
  String get collectStamps => '도장 모으기';

  @override
  String get collectStampsDesc => '여행지마다 추억을 간직해요';

  @override
  String get threeStages => '세 단계로 탐험하기';

  @override
  String get cultureIsAGame => '문화는 읽기만 하는 것이 아닙니다.\n하나의 게임입니다.';

  @override
  String get threeStagesDesc => '각 여행지는 짧고 직관적이며 보상이 분명한 세 단계의 이야기입니다.';

  @override
  String get chooseStoryStart => '이야기를 시작할 곳을 선택하세요';

  @override
  String get featuredLocationsDesc => '현재 여정을 계속하거나 새로운 문화 이야기를 시작하세요.';

  @override
  String get inProgress => '진행 중';

  @override
  String get locations => '여행지';

  @override
  String get journey => '여정';

  @override
  String get badges => '배지';

  @override
  String get support => '지원';

  @override
  String get faq => '자주 묻는 질문';

  @override
  String get contact => '문의';

  @override
  String get legal => '법적 고지';

  @override
  String get privacy => '개인정보 보호';

  @override
  String get terms => '이용 약관';

  @override
  String get footerDescription => '도전, 이야기와 특별한 여행 도장으로 한국 문화를 탐험하세요.';

  @override
  String get footerCopyright => '© 2026 KoreaQuest · 한국 문화 탐험 프로젝트.';

  @override
  String get showPassword => '비밀번호 표시';

  @override
  String get hidePassword => '비밀번호 숨기기';

  @override
  String get searchHint => '여행지와 여정 검색…';

  @override
  String get processing => '처리 중…';

  @override
  String get confirm => '확인';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String avatarOf(String name) {
    return '$name님의 아바타';
  }

  @override
  String xpProgress(int current, int next) {
    return '$next XP 중 $current XP';
  }

  @override
  String nextLevel(int xp, int level) {
    return '$xp XP · 레벨 $level';
  }

  @override
  String get featuredDescription => '이 여행지의 주요 명소를 확인하세요.';

  @override
  String get noFeatured => '표시할 주요 여행지가 없습니다.';

  @override
  String destinationNumber(int number) {
    return '여행지 $number';
  }

  @override
  String get address => '주소';

  @override
  String get activities => '활동';

  @override
  String get categories => '카테고리';

  @override
  String get didYouKnow => '알고 계셨나요?';

  @override
  String get cultureDescription => '유래, 특징과 예절 안내입니다.';

  @override
  String get noCulture => '표시할 문화 체험이 없습니다.';

  @override
  String experienceNumber(int number) {
    return '체험 $number';
  }

  @override
  String get originMeaning => '유래와 의미';

  @override
  String get recognizableFeatures => '주요 특징';

  @override
  String get relatedExperience => '관련 체험';

  @override
  String get cuisineDescription => '음식, 재료, 맛과 체험 장소를 확인하세요.';

  @override
  String get noCuisine => '표시할 음식 콘텐츠가 없습니다.';

  @override
  String foodNumber(int number) {
    return '음식 $number';
  }

  @override
  String get specialFeature => '특별한 점';

  @override
  String get experiencePlaces => '체험 장소';

  @override
  String get exploreLocation => '탐험 여행지';

  @override
  String get relatedPeople => '관련 인물';

  @override
  String get mediaSource => '이미지/영상 출처';

  @override
  String get sourceLink => '출처 링크';

  @override
  String get viewMediaSource => '미디어 출처 보기';

  @override
  String historicalMilestone(int number) {
    return '역사 이정표 $number';
  }

  @override
  String get collapse => '접기';

  @override
  String get openStatus => '열림';

  @override
  String get viewedStatus => '확인함';

  @override
  String get unviewedStatus => '확인하지 않음';

  @override
  String get openingHours => '운영 시간';

  @override
  String get ticketPrice => '입장료';

  @override
  String get duration => '소요 시간';

  @override
  String get bestTime => '추천 시기';

  @override
  String get directions => '가는 방법';

  @override
  String get tip => '팁';

  @override
  String get travelerNotes => '여행자 유의 사항';

  @override
  String get note => '유의 사항';

  @override
  String get updating => '업데이트 중';

  @override
  String get imageUpdating => '이미지 업데이트 중';

  @override
  String get areaMap => '지역 지도';

  @override
  String get moveUp => '위로 이동';

  @override
  String get checkInStageDescription => '이미지, 영상과 주요 역사 장면을 살펴본 뒤 첫 질문에 답하세요.';

  @override
  String get cultureStageDescription => '짧은 상호작용 과제로 의례, 건축과 일상의 이야기를 이해하세요.';

  @override
  String get vocabularyStageDescription =>
      '상황에 맞는 단어를 익히고 마지막 도전을 완료해 도장을 받으세요.';

  @override
  String loadLocationContentError(String error) {
    return '여행지 콘텐츠를 불러오지 못했습니다: $error';
  }

  @override
  String get locationNotFound => '여행지를 찾을 수 없습니다';

  @override
  String get locationNotPublished => '이 여행지는 아직 공개되지 않았거나 업데이트 중입니다.';

  @override
  String get changeAvatar => '아바타 변경';

  @override
  String get avatarDescription => '한국 문화 캐릭터를 선택하거나 기기에서 이미지를 업로드하세요.';

  @override
  String get uploadFromDevice => '기기에서 이미지 업로드';

  @override
  String get configureGemini => 'Gemini AI 설정';

  @override
  String get selectedModel => '선택한 모델:';

  @override
  String get saveSettings => '설정 저장';

  @override
  String get aiVoiceCommand => 'AI 명령';

  @override
  String get apiKeySettings => 'API 키 설정';

  @override
  String get testLabel => '테스트:';

  @override
  String get openProfileNow => '프로필 바로 열기';

  @override
  String get discoverNow => '지금 탐험';

  @override
  String get profileCommandCalled => '호출됨: navigateToProfile';

  @override
  String get aiCommandHint => '명령 입력 (예: \"프로필로 이동\")...';

  @override
  String get callingGemini => 'Gemini 호출 중...';

  @override
  String get sendToAi => 'AI에 명령 보내기';

  @override
  String functionCallComplete(String calls) {
    return 'Function Calling: $calls → 페이지를 열었습니다!';
  }

  @override
  String get hideRawJson => '원본 JSON 숨기기';

  @override
  String get showRawJson => 'Gemini 원본 JSON 보기';

  @override
  String get openOnYoutube => 'YouTube에서 열기';

  @override
  String openVideoOnYoutube(String label) {
    return 'YouTube에서 $label 영상 열기';
  }

  @override
  String get invalidYoutube => '유효하지 않은 YouTube 링크입니다.';

  @override
  String get invalidYoutubeEmbed => 'YouTube 링크가 유효하지 않거나 삽입할 수 없습니다.';

  @override
  String get chooseAvatar => '또는 아바타 선택';

  @override
  String get summaryStageDescription => '여정을 돌아보고 획득한 보상을 확인하세요.';

  @override
  String get hanoiVietnam => '베트남 하노이';

  @override
  String get moveDown => '아래로 이동';

  @override
  String get demoEmailHint => '이메일 또는 admin (데모 모드)';

  @override
  String get seoulCapital => '수도 서울';

  @override
  String get busanCity => '부산';

  @override
  String levelExplorer(int level) {
    return '레벨 $level · 탐험가';
  }
}
