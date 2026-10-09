// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'KoreaQuest';

  @override
  String get cultureAdventure => 'HÀNH TRÌNH VĂN HÓA';

  @override
  String get home => 'Trang chủ';

  @override
  String get explore => 'Khám phá';

  @override
  String get passport => 'Hộ chiếu';

  @override
  String get achievements => 'Thành tích';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get myProfile => 'Hồ sơ của tôi';

  @override
  String get settings => 'Cài đặt';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get start => 'Bắt đầu';

  @override
  String get startJourney => 'Bắt đầu hành trình';

  @override
  String get openNavigation => 'Mở điều hướng';

  @override
  String get openAccountMenu => 'Mở menu tài khoản';

  @override
  String levelWithXp(int level, int xp) {
    return 'Cấp $level · $xp XP';
  }

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageDescription =>
      'Ứng dụng tự nhận ngôn ngữ thiết bị và ghi nhớ lựa chọn của bạn.';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get korean => '한국어';

  @override
  String get translationUnavailable =>
      'Nội dung này chưa có bản dịch; đang hiển thị tiếng Việt.';

  @override
  String get fallbackBadge => 'Bản tiếng Việt';

  @override
  String get loading => 'Đang tải…';

  @override
  String get retry => 'Thử lại';

  @override
  String get close => 'Đóng';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get backHome => 'Về trang chủ';

  @override
  String get loadJourneyError => 'Không thể đọc dữ liệu hành trình.';

  @override
  String get koreaMap => 'Bản đồ Hàn Quốc';

  @override
  String get chooseFirstLocation =>
      'Chọn địa điểm đầu tiên để bắt đầu hành trình.';

  @override
  String get whereStart => 'Bạn muốn bắt đầu từ đâu?';

  @override
  String homeHeroDescription(String name) {
    return 'Khám phá văn hóa Hàn Quốc qua từng địa danh. $name, hành trình của bạn đang chờ đón!';
  }

  @override
  String get continueJourney => 'Tiếp tục hành trình';

  @override
  String get recommendedForYou => 'Gợi ý cho bạn';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get explorationProgress => 'Tiến độ khám phá';

  @override
  String badgesProgress(int completed, int total) {
    return '$completed/$total Huy hiệu';
  }

  @override
  String get badgeCollection => 'Bộ sưu tập huy hiệu';

  @override
  String get completed => 'Đã hoàn thành';

  @override
  String get exploring => 'Đang khám phá';

  @override
  String get all => 'Tất cả';

  @override
  String get done => 'Đã xong';

  @override
  String get stage => 'Chặng';

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String get exploreKorea => 'KHÁM PHÁ HÀN QUỐC';

  @override
  String get exploreIntro =>
      'Chọn một điểm trên bản đồ để mở hành trình khám phá hình ảnh, lịch sử, văn hóa, ẩm thực và những thử thách thú vị.';

  @override
  String get continueLatestJourney => 'Tiếp tục hành trình gần nhất';

  @override
  String get searchLocationsHint =>
      'Tìm địa điểm, thành phố hoặc trải nghiệm...';

  @override
  String get locationList => 'Danh sách địa điểm';

  @override
  String loadMapError(String error) {
    return 'Không thể tải bản đồ địa điểm: $error';
  }

  @override
  String get noMatchingLocations => 'Không có địa điểm phù hợp';

  @override
  String get changeSearchOrFilter =>
      'Thử đổi từ khóa tìm kiếm hoặc bộ lọc để xem thêm địa điểm trên bản đồ.';

  @override
  String chooseLocation(String name) {
    return 'Chọn $name';
  }

  @override
  String get durationUpdating => 'Đang cập nhật thời lượng';

  @override
  String minutes(int count) {
    return '$count phút';
  }

  @override
  String get journeyBadge => 'Huy hiệu hành trình';

  @override
  String get saveToJourney => 'Lưu vào hành trình';

  @override
  String publishedLocationsWaiting(int count) {
    return '$count địa điểm đã xuất bản đang chờ bạn khám phá.';
  }

  @override
  String get content => 'Nội dung';

  @override
  String get readyToExplore => 'Sẵn sàng để khám phá';

  @override
  String get publishedLocations => 'Địa điểm đã xuất bản';

  @override
  String locationCount(int count) {
    return '$count địa điểm';
  }

  @override
  String get zoomIn => 'Phóng to';

  @override
  String get zoomOut => 'Thu nhỏ';

  @override
  String get resetMap => 'Đặt lại bản đồ';

  @override
  String get collection => 'Bộ sưu tập';

  @override
  String get passportTitle => 'Hộ chiếu khám phá';

  @override
  String get passportDescription =>
      'Mỗi dấu mộc là một câu chuyện bạn đã thực sự đi qua.';

  @override
  String get loadPassportError => 'Không thể tải hộ chiếu.';

  @override
  String get milestones => 'Cột mốc';

  @override
  String get yourAchievements => 'Thành tích của bạn';

  @override
  String get achievementsDescription =>
      'Theo dõi những cột mốc bạn đã chinh phục trên hành trình.';

  @override
  String get loadBadgesError => 'Không thể tải huy hiệu.';

  @override
  String get forbiddenTitle => 'Bạn chưa có quyền truy cập';

  @override
  String get forbiddenMessage => 'Hãy quay lại khu vực hành trình của bạn.';

  @override
  String get offlineTitle => 'Bạn đang ngoại tuyến';

  @override
  String get offlineMessage => 'Kiểm tra kết nối và thử lại khi mạng ổn định.';

  @override
  String get errorTitle => 'Có điều gì đó chưa đúng';

  @override
  String get errorMessage => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get notFoundTitle => 'Không tìm thấy trang';

  @override
  String get notFoundMessage => 'Đường dẫn này không thuộc bản đồ KoreaQuest.';

  @override
  String get customizeSystem => 'Tùy chỉnh hệ thống';

  @override
  String get settingsDescription =>
      'Quản lý tài khoản, bảo mật, thông báo và dữ liệu khám phá của bạn.';

  @override
  String get accountSecurity => 'Tài khoản & Bảo mật';

  @override
  String get administrator => 'Quản trị viên';

  @override
  String get student => 'Học viên';

  @override
  String roleLine(String name, String role) {
    return '$name · Vai trò: $role';
  }

  @override
  String get accountPassword => 'Mật khẩu tài khoản';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get experienceOptions => 'Tùy chọn trải nghiệm';

  @override
  String get notifications => 'Thông báo hành trình';

  @override
  String get notificationsDescription =>
      'Nhắc nhở về địa điểm, huy hiệu và chuỗi ngày học';

  @override
  String get reducedMotion => 'Giảm chuyển động';

  @override
  String get reducedMotionDescription =>
      'Hạn chế hiệu ứng để trải nghiệm thoải mái hơn';

  @override
  String get dataStorage => 'Quản lý dữ liệu & Lưu trữ';

  @override
  String get clearCache => 'Xóa bộ nhớ đệm';

  @override
  String get clearCacheDescription =>
      'Giải phóng các tài nguyên tạm thời được lưu cục bộ';

  @override
  String get cleanUp => 'Dọn dẹp';

  @override
  String get cacheCleaned => 'Đã dọn dẹp bộ nhớ đệm mô phỏng.';

  @override
  String get resetProgress => 'Đặt lại tiến trình học tập';

  @override
  String get resetProgressDescription =>
      'Đưa cấp độ về 1, 0 XP để trải nghiệm lại hành trình';

  @override
  String get resetProgressQuestion => 'Đặt lại tiến trình học tập?';

  @override
  String get resetProgressMessage =>
      'Hành động này sẽ đưa cấp độ về 1, 0 XP và khóa lại các địa điểm đã hoàn thành.';

  @override
  String get reset => 'Đặt lại';

  @override
  String get resetProgressSuccess =>
      'Đã đặt lại tiến trình học tập về ban đầu.';

  @override
  String get resetProgressError =>
      'Không thể đặt lại tiến trình. Vui lòng thử lại.';

  @override
  String get session => 'Phiên đăng nhập';

  @override
  String get sessionDescription =>
      'Đăng xuất khỏi thiết bị này khi bạn hoàn tất hành trình.';

  @override
  String get signOutAccount => 'Đăng xuất tài khoản';

  @override
  String get signOutQuestion => 'Đăng xuất khỏi KoreaQuest?';

  @override
  String get signOutMessage =>
      'Bạn có chắc chắn muốn đăng xuất tài khoản hiện tại?';

  @override
  String get signOutSuccess => 'Đã đăng xuất thành công.';

  @override
  String get signOutError => 'Không thể đăng xuất. Vui lòng thử lại.';

  @override
  String get currentPassword => 'Mật khẩu hiện tại';

  @override
  String get newPassword => 'Mật khẩu mới (tối thiểu 8 ký tự)';

  @override
  String get confirmNewPassword => 'Xác nhận mật khẩu mới';

  @override
  String get updatePassword => 'Cập nhật mật khẩu';

  @override
  String get fillAllFields => 'Vui lòng điền đầy đủ các thông tin.';

  @override
  String get passwordMin8 => 'Mật khẩu mới phải có ít nhất 8 ký tự.';

  @override
  String get passwordMismatch => 'Mật khẩu xác nhận không khớp.';

  @override
  String get changePasswordSuccess => 'Đổi mật khẩu thành công!';

  @override
  String get genericError => 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';

  @override
  String get register => 'Đăng ký';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get recoverPassword => 'Khôi phục mật khẩu';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get displayName => 'Tên hiển thị';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get signInJourney => 'Đăng nhập vào hành trình';

  @override
  String get sendInstructions => 'Gửi hướng dẫn';

  @override
  String get backToSignIn => 'Quay lại đăng nhập';

  @override
  String get openPassport => 'Mở hộ chiếu KoreaQuest';

  @override
  String get registerDescription =>
      'Tạo hồ sơ du hành để nhận XP, huy hiệu và dấu mộc sau mỗi địa điểm.';

  @override
  String get loginDescription =>
      'Chào mừng bạn quay lại với cuốn nhật ký khám phá văn hóa Hàn Quốc.';

  @override
  String get forgotDescription =>
      'Nhập email của bạn để nhận hướng dẫn khôi phục mật khẩu.';

  @override
  String get emailRequired => 'Vui lòng nhập email.';

  @override
  String get invalidEmail => 'Email không đúng định dạng.';

  @override
  String get passwordRequired => 'Vui lòng nhập mật khẩu.';

  @override
  String get fullNameRequired => 'Vui lòng nhập họ và tên.';

  @override
  String get confirmationMismatch => 'Mật khẩu xác nhận không khớp.';

  @override
  String get passwordAtLeast8 => 'Mật khẩu phải có ít nhất 8 ký tự.';

  @override
  String get resetEmailSent =>
      'Nếu email tồn tại, hướng dẫn khôi phục đã được gửi.';

  @override
  String get accountCreatedVerify =>
      'Tài khoản đã được tạo. Hãy kiểm tra email để xác minh.';

  @override
  String get accountCreated => 'Tạo tài khoản thành công!';

  @override
  String get adminSignedIn => 'Đăng nhập Quản trị viên thành công.';

  @override
  String get signedIn => 'Đăng nhập thành công.';

  @override
  String get adminNoAccess => 'Tài khoản này không có quyền quản trị.';

  @override
  String get studentQuickSignedIn => 'Đăng nhập nhanh Học viên thành công.';

  @override
  String get passwordHelp =>
      'Dùng ít nhất 8 ký tự để bảo vệ tài khoản của bạn.';

  @override
  String get travelTagline => '한국 여행 · Khám phá xứ Kim Chi';

  @override
  String get continueKoreaJourney => 'Tiếp tục hành trình Hàn Quốc của bạn';

  @override
  String get travelVisualDescription =>
      'Lưu từng bước chân qua các vùng đất kỳ thú, tích lũy tem du hành và chinh phục kho tàng văn hóa rực rỡ.';

  @override
  String get quickDemoAccounts => 'Tài khoản thử nghiệm nhanh';

  @override
  String get quickDemoDescription => 'Chọn một vai trò để vào nhanh bản demo.';

  @override
  String get adminDemoDescription => 'Quản trị và duyệt địa điểm';

  @override
  String get studentDemoDescription => 'Trải nghiệm hành trình văn hóa';

  @override
  String get earnedBadgesMessage =>
      'Huy hiệu đã nhận sẽ được lưu vào bộ sưu tập';

  @override
  String get quizWaiting => '50+ câu đố văn hóa đang chờ bạn';

  @override
  String get featuredDestinations => 'Điểm đến nổi bật';

  @override
  String get cultureExperiences => 'Trải nghiệm văn hóa';

  @override
  String get cuisine => 'Ẩm thực';

  @override
  String get opening => 'Mở đầu';

  @override
  String get overview => 'Tổng quan';

  @override
  String get history => 'Lịch sử';

  @override
  String get destinations => 'Điểm đến';

  @override
  String get experiences => 'Trải nghiệm';

  @override
  String get funFacts => 'Fun Facts';

  @override
  String get quiz => 'Quiz';

  @override
  String get travel => 'Du lịch';

  @override
  String get backToKoreaMap => 'Trở về bản đồ Hàn Quốc';

  @override
  String stageProgress(int current) {
    return 'Chặng $current/9';
  }

  @override
  String get saveLocation => 'Lưu địa điểm';

  @override
  String stageLabel(int number, String label) {
    return 'Chặng $number: $label';
  }

  @override
  String continueTo(String stage) {
    return 'Tiếp tục đến $stage';
  }

  @override
  String get startExploring => 'Bắt đầu khám phá';

  @override
  String get journeyOpening => 'Mở đầu hành trình';

  @override
  String get generalInformation => 'Thông tin chung';

  @override
  String get region => 'Khu vực';

  @override
  String get locationType => 'Loại địa điểm';

  @override
  String get englishName => 'Tên tiếng Anh';

  @override
  String get historyHeritage => 'Lịch sử & Di sản';

  @override
  String get culturalEtiquette => 'Ứng xử văn hóa';

  @override
  String get shouldDo => 'Nên làm';

  @override
  String get shouldNotDo => 'Không nên làm';

  @override
  String get explorationChallenge => 'Thử thách khám phá';

  @override
  String get travelInformation => 'Thông tin du lịch';

  @override
  String get checkAnswer => 'Kiểm tra đáp án';

  @override
  String get correctAnswer => 'Chính xác!';

  @override
  String get incorrectAnswer =>
      'Chưa chính xác, nhưng nhiệm vụ vẫn được hoàn thành.';

  @override
  String quizScoringError(String error) {
    return 'Không thể chấm quiz: $error';
  }

  @override
  String get journeyOpeningDescription =>
      'Khởi đầu hành trình khám phá địa điểm này.';

  @override
  String get overviewDescription =>
      'Thông tin nhận diện, mô tả, bản đồ và những điểm đáng chú ý.';

  @override
  String get historyDescription =>
      'Khám phá những dấu ấn thời gian và câu chuyện văn hóa tạo nên bức tranh đa sắc của quá khứ.';

  @override
  String get etiquetteDescription =>
      'Những điều nên làm và không nên làm để ứng xử phù hợp.';

  @override
  String get funFactsDescription =>
      'Những sự thật thú vị để bạn sưu tầm trên hành trình.';

  @override
  String get quizDescription =>
      'Hoàn thành thử thách để nhận XP, kể cả khi câu trả lời chưa đúng.';

  @override
  String get travelDescription =>
      'Thông tin có thể thay đổi luôn đi kèm nguồn và ngày cập nhật.';

  @override
  String get travelDisclaimer =>
      'Thông tin có thể thay đổi. Hãy kiểm tra nguồn chính thức trước khi đi.';

  @override
  String get noQuickFacts => 'Chưa có thông tin nhanh để hiển thị.';

  @override
  String get historyUpdating => 'Nội dung lịch sử đang được cập nhật.';

  @override
  String get noFunFacts => 'Chưa có fun fact để hiển thị.';

  @override
  String get noQuiz => 'Chưa có câu hỏi quiz để hiển thị.';

  @override
  String taskRewards(int count) {
    return '$count nhiệm vụ · +20 XP khi chính xác · +5 XP khi hoàn thành';
  }

  @override
  String get editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String profileOf(String name) {
    return 'Hồ sơ của $name';
  }

  @override
  String get backToProfile => 'Quay lại hồ sơ';

  @override
  String xpToNextLevel(int xp) {
    return 'Còn $xp XP để lên cấp tiếp theo';
  }

  @override
  String get journeyOverview => 'Tổng quan hành trình';

  @override
  String get availableToExplore => 'Có thể khám phá';

  @override
  String get learningStreak => 'Chuỗi ngày học';

  @override
  String get continuing => 'Đang tiếp tục';

  @override
  String get noCurrentLocation => 'Chưa có địa điểm đang thực hiện.';

  @override
  String get personalInformation => 'Thông tin cá nhân';

  @override
  String get bio => 'Giới thiệu';

  @override
  String get displayInformation => 'Thông tin hiển thị';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get saving => 'Đang lưu…';

  @override
  String get changesSaved => 'Đã lưu thay đổi.';

  @override
  String get profileFieldsRequired =>
      'Họ tên và tên hiển thị không được để trống.';

  @override
  String get saveFailed => 'Lưu thất bại, thử lại sau.';

  @override
  String get bioHint => 'Câu chuyện khám phá của bạn…';

  @override
  String get loadProfileError => 'Không thể tải hồ sơ.';

  @override
  String get joined => 'Tham gia';

  @override
  String get landingLoadError =>
      'Không thể tải dữ liệu địa điểm cho trang giới thiệu.';

  @override
  String get noLocations => 'Chưa có địa điểm để bắt đầu hành trình.';

  @override
  String get discoverYourWay => 'Khám phá Hàn Quốc theo cách của bạn';

  @override
  String get heroLineOne => 'Mỗi điểm đến,\n';

  @override
  String get heroLineTwo => 'một chương phiêu lưu.';

  @override
  String get heroDescription =>
      'Đọc chuyện xưa, giải thử thách nhỏ và sưu tầm dấu mộc độc đáo qua từng địa danh nổi tiếng của Hàn Quốc.';

  @override
  String get howItWorks => 'Xem cách hoạt động';

  @override
  String get learnByExperience => 'Học qua trải nghiệm\n';

  @override
  String get rewardingNoPressure => 'Không áp lực, luôn có phần thưởng';

  @override
  String get adventureMap => 'Bản đồ phiêu lưu';

  @override
  String get currentJourney => 'Hành trình hiện tại';

  @override
  String percentComplete(int percent) {
    return '$percent% hoàn thành';
  }

  @override
  String get journeyLearning => 'Khám phá theo hành trình';

  @override
  String get journeyLearningDesc =>
      'Không học rời rạc, luôn có mục tiêu tiếp theo';

  @override
  String get earnXp => 'Tích XP & lên cấp';

  @override
  String get earnXpDesc => 'Mỗi câu trả lời đều giúp bạn tiến lên';

  @override
  String get collectStamps => 'Sưu tầm dấu mộc';

  @override
  String get collectStampsDesc => 'Lưu giữ ký ức tại từng điểm đến';

  @override
  String get threeStages => 'Ba chặng khám phá';

  @override
  String get cultureIsAGame =>
      'Văn hóa không chỉ để đọc.\nNó là một cuộc chơi.';

  @override
  String get threeStagesDesc =>
      'Mỗi địa điểm là một câu chuyện gồm ba chặng ngắn, trực quan và có phần thưởng rõ ràng.';

  @override
  String get chooseStoryStart => 'Chọn nơi câu chuyện bắt đầu';

  @override
  String get featuredLocationsDesc =>
      'Tiếp tục hành trình hiện tại hoặc mở một câu chuyện văn hóa mới.';

  @override
  String get inProgress => 'Đang thực hiện';

  @override
  String get locations => 'Địa điểm';

  @override
  String get journey => 'Hành trình';

  @override
  String get badges => 'Huy hiệu';

  @override
  String get support => 'Hỗ trợ';

  @override
  String get faq => 'Câu hỏi thường gặp';

  @override
  String get contact => 'Liên hệ';

  @override
  String get legal => 'Pháp lý';

  @override
  String get privacy => 'Quyền riêng tư';

  @override
  String get terms => 'Điều khoản';

  @override
  String get footerDescription =>
      'Hành trình khám phá văn hóa Hàn Quốc qua thử thách, câu chuyện và những dấu mộc đáng nhớ.';

  @override
  String get footerCopyright =>
      '© 2026 KoreaQuest · Dự án khám phá văn hóa Hàn Quốc.';

  @override
  String get showPassword => 'Hiện mật khẩu';

  @override
  String get hidePassword => 'Ẩn mật khẩu';

  @override
  String get searchHint => 'Tìm địa điểm, hành trình…';

  @override
  String get processing => 'Đang xử lý…';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get errorOccurred => 'Đã có lỗi xảy ra';

  @override
  String avatarOf(String name) {
    return 'Ảnh đại diện của $name';
  }

  @override
  String xpProgress(int current, int next) {
    return '$current trên $next XP';
  }

  @override
  String nextLevel(int xp, int level) {
    return '$xp XP · Cấp $level';
  }

  @override
  String get featuredDescription =>
      'Những điểm đáng chú ý tại địa điểm đang xem.';

  @override
  String get noFeatured => 'Chưa có điểm đến nổi bật để hiển thị.';

  @override
  String destinationNumber(int number) {
    return 'Điểm đến $number';
  }

  @override
  String get address => 'Địa chỉ';

  @override
  String get activities => 'Hoạt động';

  @override
  String get categories => 'Danh mục';

  @override
  String get didYouKnow => 'Bạn có biết?';

  @override
  String get cultureDescription =>
      'Nguồn gốc, dấu hiệu nhận biết và gợi ý ứng xử.';

  @override
  String get noCulture => 'Chưa có trải nghiệm văn hóa để hiển thị.';

  @override
  String experienceNumber(int number) {
    return 'Trải nghiệm $number';
  }

  @override
  String get originMeaning => 'Nguồn gốc & ý nghĩa';

  @override
  String get recognizableFeatures => 'Dấu hiệu nhận biết';

  @override
  String get relatedExperience => 'Trải nghiệm liên quan';

  @override
  String get cuisineDescription =>
      'Món ăn, nguyên liệu, hương vị và nơi trải nghiệm.';

  @override
  String get noCuisine => 'Chưa có nội dung ẩm thực để hiển thị.';

  @override
  String foodNumber(int number) {
    return 'Món ăn $number';
  }

  @override
  String get specialFeature => 'Điểm đặc biệt';

  @override
  String get experiencePlaces => 'Nơi trải nghiệm';

  @override
  String get exploreLocation => 'Địa điểm khám phá';

  @override
  String get relatedPeople => 'Nhân vật liên quan';

  @override
  String get mediaSource => 'Nguồn ảnh/video';

  @override
  String get sourceLink => 'Liên kết nguồn';

  @override
  String get viewMediaSource => 'Xem nguồn media';

  @override
  String historicalMilestone(int number) {
    return 'Mốc lịch sử $number';
  }

  @override
  String get collapse => 'Thu gọn';

  @override
  String get openStatus => 'đang mở';

  @override
  String get viewedStatus => 'đã xem';

  @override
  String get unviewedStatus => 'chưa xem';

  @override
  String get openingHours => 'Giờ mở cửa';

  @override
  String get ticketPrice => 'Giá vé';

  @override
  String get duration => 'Thời lượng';

  @override
  String get bestTime => 'Thời điểm đẹp';

  @override
  String get directions => 'Cách di chuyển';

  @override
  String get tip => 'Mẹo';

  @override
  String get travelerNotes => 'Lưu ý cho du khách';

  @override
  String get note => 'Lưu ý';

  @override
  String get updating => 'Đang cập nhật';

  @override
  String get imageUpdating => 'Ảnh đang được cập nhật';

  @override
  String get previousImage => 'Ảnh trước';

  @override
  String get nextImage => 'Ảnh tiếp theo';

  @override
  String imagePosition(int current, int total) {
    return 'Ảnh $current trên $total';
  }

  @override
  String get areaMap => 'Bản đồ khu vực';

  @override
  String get moveUp => 'Đưa lên';

  @override
  String get checkInStageDescription =>
      'Xem hình ảnh, video và những lát cắt lịch sử quan trọng trước khi trả lời câu hỏi mở màn.';

  @override
  String get cultureStageDescription =>
      'Hiểu nghi lễ, kiến trúc và câu chuyện đời sống qua nhiệm vụ tương tác ngắn.';

  @override
  String get vocabularyStageDescription =>
      'Ghi nhớ từ mới theo đúng bối cảnh và hoàn tất thử thách cuối để nhận dấu mộc.';

  @override
  String loadLocationContentError(String error) {
    return 'Không thể tải nội dung địa điểm: $error';
  }

  @override
  String get locationNotFound => 'Không tìm thấy địa điểm';

  @override
  String get locationNotPublished =>
      'Địa điểm này chưa được xuất bản hoặc đang được cập nhật.';

  @override
  String get changeAvatar => 'Đổi ảnh đại diện';

  @override
  String get avatarDescription =>
      'Chọn từ nhân vật văn hóa Hàn Quốc hoặc tải ảnh từ máy tính.';

  @override
  String get uploadFromDevice => 'Tải ảnh từ máy tính';

  @override
  String get configureGemini => 'Cấu hình Gemini AI';

  @override
  String get selectedModel => 'Model đang chọn:';

  @override
  String get saveSettings => 'Lưu cài đặt';

  @override
  String get aiVoiceCommand => 'AI Lệnh thoại';

  @override
  String get apiKeySettings => 'Cài đặt API Key';

  @override
  String get testLabel => 'Thử nghiệm:';

  @override
  String get openProfileNow => 'Mở Hồ sơ ngay';

  @override
  String get discoverNow => 'Khám phá ngay';

  @override
  String get profileCommandCalled => 'Đã gọi: navigateToProfile';

  @override
  String get aiCommandHint => 'Nhập lệnh (vd: \"Chuyển sang trang hồ sơ\")...';

  @override
  String get callingGemini => 'Đang gọi Gemini...';

  @override
  String get sendToAi => 'Gửi lệnh tới AI';

  @override
  String functionCallComplete(String calls) {
    return 'Function Calling: $calls → Đã chuyển trang!';
  }

  @override
  String get hideRawJson => 'Ẩn JSON thô';

  @override
  String get showRawJson => 'Xem JSON thô từ Gemini';

  @override
  String get openOnYoutube => 'Mở trên YouTube';

  @override
  String openVideoOnYoutube(String label) {
    return 'Mở video $label trên YouTube';
  }

  @override
  String get invalidYoutube => 'Liên kết YouTube không hợp lệ.';

  @override
  String get invalidYoutubeEmbed =>
      'Liên kết YouTube không hợp lệ hoặc không thể nhúng.';

  @override
  String get chooseAvatar => 'HOẶC CHỌN NHÂN VẬT ĐẠI DIỆN';

  @override
  String get summaryStageDescription =>
      'Tổng kết hành trình và ghi nhận những phần thưởng bạn đã chinh phục.';

  @override
  String get hanoiVietnam => 'Hà Nội, Việt Nam';

  @override
  String get moveDown => 'Đưa xuống';

  @override
  String get demoEmailHint => 'Email hoặc admin (chế độ demo)';

  @override
  String get seoulCapital => 'Thủ đô Seoul';

  @override
  String get busanCity => 'Thành phố Busan';

  @override
  String levelExplorer(int level) {
    return 'LEVEL $level · NHÀ THÁM HIỂM';
  }
}
