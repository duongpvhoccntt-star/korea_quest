import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ko'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'KoreaQuest'**
  String get appTitle;

  /// No description provided for @cultureAdventure.
  ///
  /// In vi, this message translates to:
  /// **'HÀNH TRÌNH VĂN HÓA'**
  String get cultureAdventure;

  /// No description provided for @home.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get explore;

  /// No description provided for @passport.
  ///
  /// In vi, this message translates to:
  /// **'Hộ chiếu'**
  String get passport;

  /// No description provided for @achievements.
  ///
  /// In vi, this message translates to:
  /// **'Thành tích'**
  String get achievements;

  /// No description provided for @profile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profile;

  /// No description provided for @myProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ của tôi'**
  String get myProfile;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @signIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get signOut;

  /// No description provided for @start.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get start;

  /// No description provided for @startJourney.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu hành trình'**
  String get startJourney;

  /// No description provided for @openNavigation.
  ///
  /// In vi, this message translates to:
  /// **'Mở điều hướng'**
  String get openNavigation;

  /// No description provided for @openAccountMenu.
  ///
  /// In vi, this message translates to:
  /// **'Mở menu tài khoản'**
  String get openAccountMenu;

  /// No description provided for @levelWithXp.
  ///
  /// In vi, this message translates to:
  /// **'Cấp {level} · {xp} XP'**
  String levelWithXp(int level, int xp);

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng tự nhận ngôn ngữ thiết bị và ghi nhớ lựa chọn của bạn.'**
  String get languageDescription;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @korean.
  ///
  /// In vi, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @translationUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung này chưa có bản dịch; đang hiển thị tiếng Việt.'**
  String get translationUnavailable;

  /// No description provided for @fallbackBadge.
  ///
  /// In vi, this message translates to:
  /// **'Bản tiếng Việt'**
  String get fallbackBadge;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @backHome.
  ///
  /// In vi, this message translates to:
  /// **'Về trang chủ'**
  String get backHome;

  /// No description provided for @loadJourneyError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể đọc dữ liệu hành trình.'**
  String get loadJourneyError;

  /// No description provided for @koreaMap.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ Hàn Quốc'**
  String get koreaMap;

  /// No description provided for @chooseFirstLocation.
  ///
  /// In vi, this message translates to:
  /// **'Chọn địa điểm đầu tiên để bắt đầu hành trình.'**
  String get chooseFirstLocation;

  /// No description provided for @whereStart.
  ///
  /// In vi, this message translates to:
  /// **'Bạn muốn bắt đầu từ đâu?'**
  String get whereStart;

  /// No description provided for @homeHeroDescription.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá văn hóa Hàn Quốc qua từng địa danh. {name}, hành trình của bạn đang chờ đón!'**
  String homeHeroDescription(String name);

  /// No description provided for @continueJourney.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục hành trình'**
  String get continueJourney;

  /// No description provided for @recommendedForYou.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý cho bạn'**
  String get recommendedForYou;

  /// No description provided for @viewAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get viewAll;

  /// No description provided for @explorationProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ khám phá'**
  String get explorationProgress;

  /// No description provided for @badgesProgress.
  ///
  /// In vi, this message translates to:
  /// **'{completed}/{total} Huy hiệu'**
  String badgesProgress(int completed, int total);

  /// No description provided for @badgeCollection.
  ///
  /// In vi, this message translates to:
  /// **'Bộ sưu tập huy hiệu'**
  String get badgeCollection;

  /// No description provided for @completed.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành'**
  String get completed;

  /// No description provided for @exploring.
  ///
  /// In vi, this message translates to:
  /// **'Đang khám phá'**
  String get exploring;

  /// No description provided for @all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// No description provided for @done.
  ///
  /// In vi, this message translates to:
  /// **'Đã xong'**
  String get done;

  /// No description provided for @stage.
  ///
  /// In vi, this message translates to:
  /// **'Chặng'**
  String get stage;

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp ra mắt'**
  String get comingSoon;

  /// No description provided for @exploreKorea.
  ///
  /// In vi, this message translates to:
  /// **'KHÁM PHÁ HÀN QUỐC'**
  String get exploreKorea;

  /// No description provided for @exploreIntro.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một điểm trên bản đồ để mở hành trình khám phá hình ảnh, lịch sử, văn hóa, ẩm thực và những thử thách thú vị.'**
  String get exploreIntro;

  /// No description provided for @continueLatestJourney.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục hành trình gần nhất'**
  String get continueLatestJourney;

  /// No description provided for @searchLocationsHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm địa điểm, thành phố hoặc trải nghiệm...'**
  String get searchLocationsHint;

  /// No description provided for @locationList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách địa điểm'**
  String get locationList;

  /// No description provided for @loadMapError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải bản đồ địa điểm: {error}'**
  String loadMapError(String error);

  /// No description provided for @noMatchingLocations.
  ///
  /// In vi, this message translates to:
  /// **'Không có địa điểm phù hợp'**
  String get noMatchingLocations;

  /// No description provided for @changeSearchOrFilter.
  ///
  /// In vi, this message translates to:
  /// **'Thử đổi từ khóa tìm kiếm hoặc bộ lọc để xem thêm địa điểm trên bản đồ.'**
  String get changeSearchOrFilter;

  /// No description provided for @chooseLocation.
  ///
  /// In vi, this message translates to:
  /// **'Chọn {name}'**
  String chooseLocation(String name);

  /// No description provided for @durationUpdating.
  ///
  /// In vi, this message translates to:
  /// **'Đang cập nhật thời lượng'**
  String get durationUpdating;

  /// No description provided for @minutes.
  ///
  /// In vi, this message translates to:
  /// **'{count} phút'**
  String minutes(int count);

  /// No description provided for @journeyBadge.
  ///
  /// In vi, this message translates to:
  /// **'Huy hiệu hành trình'**
  String get journeyBadge;

  /// No description provided for @saveToJourney.
  ///
  /// In vi, this message translates to:
  /// **'Lưu vào hành trình'**
  String get saveToJourney;

  /// No description provided for @publishedLocationsWaiting.
  ///
  /// In vi, this message translates to:
  /// **'{count} địa điểm đã xuất bản đang chờ bạn khám phá.'**
  String publishedLocationsWaiting(int count);

  /// No description provided for @content.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung'**
  String get content;

  /// No description provided for @readyToExplore.
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng để khám phá'**
  String get readyToExplore;

  /// No description provided for @publishedLocations.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm đã xuất bản'**
  String get publishedLocations;

  /// No description provided for @locationCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} địa điểm'**
  String locationCount(int count);

  /// No description provided for @zoomIn.
  ///
  /// In vi, this message translates to:
  /// **'Phóng to'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhỏ'**
  String get zoomOut;

  /// No description provided for @resetMap.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại bản đồ'**
  String get resetMap;

  /// No description provided for @collection.
  ///
  /// In vi, this message translates to:
  /// **'Bộ sưu tập'**
  String get collection;

  /// No description provided for @passportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hộ chiếu khám phá'**
  String get passportTitle;

  /// No description provided for @passportDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi dấu mộc là một câu chuyện bạn đã thực sự đi qua.'**
  String get passportDescription;

  /// No description provided for @loadPassportError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải hộ chiếu.'**
  String get loadPassportError;

  /// No description provided for @milestones.
  ///
  /// In vi, this message translates to:
  /// **'Cột mốc'**
  String get milestones;

  /// No description provided for @yourAchievements.
  ///
  /// In vi, this message translates to:
  /// **'Thành tích của bạn'**
  String get yourAchievements;

  /// No description provided for @achievementsDescription.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi những cột mốc bạn đã chinh phục trên hành trình.'**
  String get achievementsDescription;

  /// No description provided for @loadBadgesError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải huy hiệu.'**
  String get loadBadgesError;

  /// No description provided for @forbiddenTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có quyền truy cập'**
  String get forbiddenTitle;

  /// No description provided for @forbiddenMessage.
  ///
  /// In vi, this message translates to:
  /// **'Hãy quay lại khu vực hành trình của bạn.'**
  String get forbiddenMessage;

  /// No description provided for @offlineTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang ngoại tuyến'**
  String get offlineTitle;

  /// No description provided for @offlineMessage.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra kết nối và thử lại khi mạng ổn định.'**
  String get offlineMessage;

  /// No description provided for @errorTitle.
  ///
  /// In vi, this message translates to:
  /// **'Có điều gì đó chưa đúng'**
  String get errorTitle;

  /// No description provided for @errorMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi. Vui lòng thử lại.'**
  String get errorMessage;

  /// No description provided for @notFoundTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy trang'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đường dẫn này không thuộc bản đồ KoreaQuest.'**
  String get notFoundMessage;

  /// No description provided for @customizeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Tùy chỉnh hệ thống'**
  String get customizeSystem;

  /// No description provided for @settingsDescription.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý tài khoản, bảo mật, thông báo và dữ liệu khám phá của bạn.'**
  String get settingsDescription;

  /// No description provided for @accountSecurity.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản & Bảo mật'**
  String get accountSecurity;

  /// No description provided for @administrator.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị viên'**
  String get administrator;

  /// No description provided for @student.
  ///
  /// In vi, this message translates to:
  /// **'Học viên'**
  String get student;

  /// No description provided for @roleLine.
  ///
  /// In vi, this message translates to:
  /// **'{name} · Vai trò: {role}'**
  String roleLine(String name, String role);

  /// No description provided for @accountPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu tài khoản'**
  String get accountPassword;

  /// No description provided for @changePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get changePassword;

  /// No description provided for @experienceOptions.
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn trải nghiệm'**
  String get experienceOptions;

  /// No description provided for @notifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo hành trình'**
  String get notifications;

  /// No description provided for @notificationsDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở về địa điểm, huy hiệu và chuỗi ngày học'**
  String get notificationsDescription;

  /// No description provided for @reducedMotion.
  ///
  /// In vi, this message translates to:
  /// **'Giảm chuyển động'**
  String get reducedMotion;

  /// No description provided for @reducedMotionDescription.
  ///
  /// In vi, this message translates to:
  /// **'Hạn chế hiệu ứng để trải nghiệm thoải mái hơn'**
  String get reducedMotionDescription;

  /// No description provided for @dataStorage.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý dữ liệu & Lưu trữ'**
  String get dataStorage;

  /// No description provided for @clearCache.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ nhớ đệm'**
  String get clearCache;

  /// No description provided for @clearCacheDescription.
  ///
  /// In vi, this message translates to:
  /// **'Giải phóng các tài nguyên tạm thời được lưu cục bộ'**
  String get clearCacheDescription;

  /// No description provided for @cleanUp.
  ///
  /// In vi, this message translates to:
  /// **'Dọn dẹp'**
  String get cleanUp;

  /// No description provided for @cacheCleaned.
  ///
  /// In vi, this message translates to:
  /// **'Đã dọn dẹp bộ nhớ đệm mô phỏng.'**
  String get cacheCleaned;

  /// No description provided for @resetProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại tiến trình học tập'**
  String get resetProgress;

  /// No description provided for @resetProgressDescription.
  ///
  /// In vi, this message translates to:
  /// **'Đưa cấp độ về 1, 0 XP để trải nghiệm lại hành trình'**
  String get resetProgressDescription;

  /// No description provided for @resetProgressQuestion.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại tiến trình học tập?'**
  String get resetProgressQuestion;

  /// No description provided for @resetProgressMessage.
  ///
  /// In vi, this message translates to:
  /// **'Hành động này sẽ đưa cấp độ về 1, 0 XP và khóa lại các địa điểm đã hoàn thành.'**
  String get resetProgressMessage;

  /// No description provided for @reset.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại'**
  String get reset;

  /// No description provided for @resetProgressSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã đặt lại tiến trình học tập về ban đầu.'**
  String get resetProgressSuccess;

  /// No description provided for @resetProgressError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể đặt lại tiến trình. Vui lòng thử lại.'**
  String get resetProgressError;

  /// No description provided for @session.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập'**
  String get session;

  /// No description provided for @sessionDescription.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất khỏi thiết bị này khi bạn hoàn tất hành trình.'**
  String get sessionDescription;

  /// No description provided for @signOutAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất tài khoản'**
  String get signOutAccount;

  /// No description provided for @signOutQuestion.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất khỏi KoreaQuest?'**
  String get signOutQuestion;

  /// No description provided for @signOutMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất tài khoản hiện tại?'**
  String get signOutMessage;

  /// No description provided for @signOutSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng xuất thành công.'**
  String get signOutSuccess;

  /// No description provided for @signOutError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể đăng xuất. Vui lòng thử lại.'**
  String get signOutError;

  /// No description provided for @currentPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu hiện tại'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới (tối thiểu 8 ký tự)'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu mới'**
  String get confirmNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật mật khẩu'**
  String get updatePassword;

  /// No description provided for @fillAllFields.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng điền đầy đủ các thông tin.'**
  String get fillAllFields;

  /// No description provided for @passwordMin8.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới phải có ít nhất 8 ký tự.'**
  String get passwordMin8;

  /// No description provided for @passwordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp.'**
  String get passwordMismatch;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu thành công!'**
  String get changePasswordSuccess;

  /// No description provided for @genericError.
  ///
  /// In vi, this message translates to:
  /// **'Đã có lỗi xảy ra. Vui lòng thử lại sau.'**
  String get genericError;

  /// No description provided for @register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPassword;

  /// No description provided for @recoverPassword.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục mật khẩu'**
  String get recoverPassword;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @displayName.
  ///
  /// In vi, this message translates to:
  /// **'Tên hiển thị'**
  String get displayName;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get createAccount;

  /// No description provided for @signInJourney.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập vào hành trình'**
  String get signInJourney;

  /// No description provided for @sendInstructions.
  ///
  /// In vi, this message translates to:
  /// **'Gửi hướng dẫn'**
  String get sendInstructions;

  /// No description provided for @backToSignIn.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại đăng nhập'**
  String get backToSignIn;

  /// No description provided for @openPassport.
  ///
  /// In vi, this message translates to:
  /// **'Mở hộ chiếu KoreaQuest'**
  String get openPassport;

  /// No description provided for @registerDescription.
  ///
  /// In vi, this message translates to:
  /// **'Tạo hồ sơ du hành để nhận XP, huy hiệu và dấu mộc sau mỗi địa điểm.'**
  String get registerDescription;

  /// No description provided for @loginDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng bạn quay lại với cuốn nhật ký khám phá văn hóa Hàn Quốc.'**
  String get loginDescription;

  /// No description provided for @forgotDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email của bạn để nhận hướng dẫn khôi phục mật khẩu.'**
  String get forgotDescription;

  /// No description provided for @emailRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email.'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email không đúng định dạng.'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu.'**
  String get passwordRequired;

  /// No description provided for @fullNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ và tên.'**
  String get fullNameRequired;

  /// No description provided for @confirmationMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp.'**
  String get confirmationMismatch;

  /// No description provided for @passwordAtLeast8.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 8 ký tự.'**
  String get passwordAtLeast8;

  /// No description provided for @resetEmailSent.
  ///
  /// In vi, this message translates to:
  /// **'Nếu email tồn tại, hướng dẫn khôi phục đã được gửi.'**
  String get resetEmailSent;

  /// No description provided for @accountCreatedVerify.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản đã được tạo. Hãy kiểm tra email để xác minh.'**
  String get accountCreatedVerify;

  /// No description provided for @accountCreated.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản thành công!'**
  String get accountCreated;

  /// No description provided for @adminSignedIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập Quản trị viên thành công.'**
  String get adminSignedIn;

  /// No description provided for @signedIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thành công.'**
  String get signedIn;

  /// No description provided for @adminNoAccess.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản này không có quyền quản trị.'**
  String get adminNoAccess;

  /// No description provided for @studentQuickSignedIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập nhanh Học viên thành công.'**
  String get studentQuickSignedIn;

  /// No description provided for @passwordHelp.
  ///
  /// In vi, this message translates to:
  /// **'Dùng ít nhất 8 ký tự để bảo vệ tài khoản của bạn.'**
  String get passwordHelp;

  /// No description provided for @travelTagline.
  ///
  /// In vi, this message translates to:
  /// **'한국 여행 · Khám phá xứ Kim Chi'**
  String get travelTagline;

  /// No description provided for @continueKoreaJourney.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục hành trình Hàn Quốc của bạn'**
  String get continueKoreaJourney;

  /// No description provided for @travelVisualDescription.
  ///
  /// In vi, this message translates to:
  /// **'Lưu từng bước chân qua các vùng đất kỳ thú, tích lũy tem du hành và chinh phục kho tàng văn hóa rực rỡ.'**
  String get travelVisualDescription;

  /// No description provided for @quickDemoAccounts.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản thử nghiệm nhanh'**
  String get quickDemoAccounts;

  /// No description provided for @quickDemoDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một vai trò để vào nhanh bản demo.'**
  String get quickDemoDescription;

  /// No description provided for @adminDemoDescription.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị và duyệt địa điểm'**
  String get adminDemoDescription;

  /// No description provided for @studentDemoDescription.
  ///
  /// In vi, this message translates to:
  /// **'Trải nghiệm hành trình văn hóa'**
  String get studentDemoDescription;

  /// No description provided for @earnedBadgesMessage.
  ///
  /// In vi, this message translates to:
  /// **'Huy hiệu đã nhận sẽ được lưu vào bộ sưu tập'**
  String get earnedBadgesMessage;

  /// No description provided for @quizWaiting.
  ///
  /// In vi, this message translates to:
  /// **'50+ câu đố văn hóa đang chờ bạn'**
  String get quizWaiting;

  /// No description provided for @featuredDestinations.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đến nổi bật'**
  String get featuredDestinations;

  /// No description provided for @cultureExperiences.
  ///
  /// In vi, this message translates to:
  /// **'Trải nghiệm văn hóa'**
  String get cultureExperiences;

  /// No description provided for @cuisine.
  ///
  /// In vi, this message translates to:
  /// **'Ẩm thực'**
  String get cuisine;

  /// No description provided for @opening.
  ///
  /// In vi, this message translates to:
  /// **'Mở đầu'**
  String get opening;

  /// No description provided for @overview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get overview;

  /// No description provided for @history.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get history;

  /// No description provided for @destinations.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đến'**
  String get destinations;

  /// No description provided for @experiences.
  ///
  /// In vi, this message translates to:
  /// **'Trải nghiệm'**
  String get experiences;

  /// No description provided for @funFacts.
  ///
  /// In vi, this message translates to:
  /// **'Fun Facts'**
  String get funFacts;

  /// No description provided for @quiz.
  ///
  /// In vi, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @travel.
  ///
  /// In vi, this message translates to:
  /// **'Du lịch'**
  String get travel;

  /// No description provided for @backToKoreaMap.
  ///
  /// In vi, this message translates to:
  /// **'Trở về bản đồ Hàn Quốc'**
  String get backToKoreaMap;

  /// No description provided for @stageProgress.
  ///
  /// In vi, this message translates to:
  /// **'Chặng {current}/9'**
  String stageProgress(int current);

  /// No description provided for @saveLocation.
  ///
  /// In vi, this message translates to:
  /// **'Lưu địa điểm'**
  String get saveLocation;

  /// No description provided for @stageLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chặng {number}: {label}'**
  String stageLabel(int number, String label);

  /// No description provided for @continueTo.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục đến {stage}'**
  String continueTo(String stage);

  /// No description provided for @startExploring.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu khám phá'**
  String get startExploring;

  /// No description provided for @journeyOpening.
  ///
  /// In vi, this message translates to:
  /// **'Mở đầu hành trình'**
  String get journeyOpening;

  /// No description provided for @generalInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin chung'**
  String get generalInformation;

  /// No description provided for @region.
  ///
  /// In vi, this message translates to:
  /// **'Khu vực'**
  String get region;

  /// No description provided for @locationType.
  ///
  /// In vi, this message translates to:
  /// **'Loại địa điểm'**
  String get locationType;

  /// No description provided for @englishName.
  ///
  /// In vi, this message translates to:
  /// **'Tên tiếng Anh'**
  String get englishName;

  /// No description provided for @historyHeritage.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử & Di sản'**
  String get historyHeritage;

  /// No description provided for @culturalEtiquette.
  ///
  /// In vi, this message translates to:
  /// **'Ứng xử văn hóa'**
  String get culturalEtiquette;

  /// No description provided for @shouldDo.
  ///
  /// In vi, this message translates to:
  /// **'Nên làm'**
  String get shouldDo;

  /// No description provided for @shouldNotDo.
  ///
  /// In vi, this message translates to:
  /// **'Không nên làm'**
  String get shouldNotDo;

  /// No description provided for @explorationChallenge.
  ///
  /// In vi, this message translates to:
  /// **'Thử thách khám phá'**
  String get explorationChallenge;

  /// No description provided for @travelInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin du lịch'**
  String get travelInformation;

  /// No description provided for @checkAnswer.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra đáp án'**
  String get checkAnswer;

  /// No description provided for @correctAnswer.
  ///
  /// In vi, this message translates to:
  /// **'Chính xác!'**
  String get correctAnswer;

  /// No description provided for @incorrectAnswer.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chính xác, nhưng nhiệm vụ vẫn được hoàn thành.'**
  String get incorrectAnswer;

  /// No description provided for @quizScoringError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể chấm quiz: {error}'**
  String quizScoringError(String error);

  /// No description provided for @journeyOpeningDescription.
  ///
  /// In vi, this message translates to:
  /// **'Khởi đầu hành trình khám phá địa điểm này.'**
  String get journeyOpeningDescription;

  /// No description provided for @overviewDescription.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin nhận diện, mô tả, bản đồ và những điểm đáng chú ý.'**
  String get overviewDescription;

  /// No description provided for @historyDescription.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá những dấu ấn thời gian và câu chuyện văn hóa tạo nên bức tranh đa sắc của quá khứ.'**
  String get historyDescription;

  /// No description provided for @etiquetteDescription.
  ///
  /// In vi, this message translates to:
  /// **'Những điều nên làm và không nên làm để ứng xử phù hợp.'**
  String get etiquetteDescription;

  /// No description provided for @funFactsDescription.
  ///
  /// In vi, this message translates to:
  /// **'Những sự thật thú vị để bạn sưu tầm trên hành trình.'**
  String get funFactsDescription;

  /// No description provided for @quizDescription.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành thử thách để nhận XP, kể cả khi câu trả lời chưa đúng.'**
  String get quizDescription;

  /// No description provided for @travelDescription.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin có thể thay đổi luôn đi kèm nguồn và ngày cập nhật.'**
  String get travelDescription;

  /// No description provided for @travelDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin có thể thay đổi. Hãy kiểm tra nguồn chính thức trước khi đi.'**
  String get travelDisclaimer;

  /// No description provided for @noQuickFacts.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thông tin nhanh để hiển thị.'**
  String get noQuickFacts;

  /// No description provided for @historyUpdating.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung lịch sử đang được cập nhật.'**
  String get historyUpdating;

  /// No description provided for @noFunFacts.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có fun fact để hiển thị.'**
  String get noFunFacts;

  /// No description provided for @noQuiz.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có câu hỏi quiz để hiển thị.'**
  String get noQuiz;

  /// No description provided for @taskRewards.
  ///
  /// In vi, this message translates to:
  /// **'{count} nhiệm vụ · +20 XP khi chính xác · +5 XP khi hoàn thành'**
  String taskRewards(int count);

  /// No description provided for @editProfile.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get editProfile;

  /// No description provided for @profileOf.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ của {name}'**
  String profileOf(String name);

  /// No description provided for @backToProfile.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại hồ sơ'**
  String get backToProfile;

  /// No description provided for @xpToNextLevel.
  ///
  /// In vi, this message translates to:
  /// **'Còn {xp} XP để lên cấp tiếp theo'**
  String xpToNextLevel(int xp);

  /// No description provided for @journeyOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan hành trình'**
  String get journeyOverview;

  /// No description provided for @availableToExplore.
  ///
  /// In vi, this message translates to:
  /// **'Có thể khám phá'**
  String get availableToExplore;

  /// No description provided for @learningStreak.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi ngày học'**
  String get learningStreak;

  /// No description provided for @continuing.
  ///
  /// In vi, this message translates to:
  /// **'Đang tiếp tục'**
  String get continuing;

  /// No description provided for @noCurrentLocation.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có địa điểm đang thực hiện.'**
  String get noCurrentLocation;

  /// No description provided for @personalInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get personalInformation;

  /// No description provided for @bio.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get bio;

  /// No description provided for @displayInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin hiển thị'**
  String get displayInformation;

  /// No description provided for @saveChanges.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get saveChanges;

  /// No description provided for @saving.
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu…'**
  String get saving;

  /// No description provided for @changesSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu thay đổi.'**
  String get changesSaved;

  /// No description provided for @profileFieldsRequired.
  ///
  /// In vi, this message translates to:
  /// **'Họ tên và tên hiển thị không được để trống.'**
  String get profileFieldsRequired;

  /// No description provided for @saveFailed.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thất bại, thử lại sau.'**
  String get saveFailed;

  /// No description provided for @bioHint.
  ///
  /// In vi, this message translates to:
  /// **'Câu chuyện khám phá của bạn…'**
  String get bioHint;

  /// No description provided for @loadProfileError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải hồ sơ.'**
  String get loadProfileError;

  /// No description provided for @joined.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia'**
  String get joined;

  /// No description provided for @landingLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải dữ liệu địa điểm cho trang giới thiệu.'**
  String get landingLoadError;

  /// No description provided for @noLocations.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có địa điểm để bắt đầu hành trình.'**
  String get noLocations;

  /// No description provided for @discoverYourWay.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá Hàn Quốc theo cách của bạn'**
  String get discoverYourWay;

  /// No description provided for @heroLineOne.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi điểm đến,\n'**
  String get heroLineOne;

  /// No description provided for @heroLineTwo.
  ///
  /// In vi, this message translates to:
  /// **'một chương phiêu lưu.'**
  String get heroLineTwo;

  /// No description provided for @heroDescription.
  ///
  /// In vi, this message translates to:
  /// **'Đọc chuyện xưa, giải thử thách nhỏ và sưu tầm dấu mộc độc đáo qua từng địa danh nổi tiếng của Hàn Quốc.'**
  String get heroDescription;

  /// No description provided for @howItWorks.
  ///
  /// In vi, this message translates to:
  /// **'Xem cách hoạt động'**
  String get howItWorks;

  /// No description provided for @learnByExperience.
  ///
  /// In vi, this message translates to:
  /// **'Học qua trải nghiệm\n'**
  String get learnByExperience;

  /// No description provided for @rewardingNoPressure.
  ///
  /// In vi, this message translates to:
  /// **'Không áp lực, luôn có phần thưởng'**
  String get rewardingNoPressure;

  /// No description provided for @adventureMap.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ phiêu lưu'**
  String get adventureMap;

  /// No description provided for @currentJourney.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình hiện tại'**
  String get currentJourney;

  /// No description provided for @percentComplete.
  ///
  /// In vi, this message translates to:
  /// **'{percent}% hoàn thành'**
  String percentComplete(int percent);

  /// No description provided for @journeyLearning.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá theo hành trình'**
  String get journeyLearning;

  /// No description provided for @journeyLearningDesc.
  ///
  /// In vi, this message translates to:
  /// **'Không học rời rạc, luôn có mục tiêu tiếp theo'**
  String get journeyLearningDesc;

  /// No description provided for @earnXp.
  ///
  /// In vi, this message translates to:
  /// **'Tích XP & lên cấp'**
  String get earnXp;

  /// No description provided for @earnXpDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi câu trả lời đều giúp bạn tiến lên'**
  String get earnXpDesc;

  /// No description provided for @collectStamps.
  ///
  /// In vi, this message translates to:
  /// **'Sưu tầm dấu mộc'**
  String get collectStamps;

  /// No description provided for @collectStampsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Lưu giữ ký ức tại từng điểm đến'**
  String get collectStampsDesc;

  /// No description provided for @threeStages.
  ///
  /// In vi, this message translates to:
  /// **'Ba chặng khám phá'**
  String get threeStages;

  /// No description provided for @cultureIsAGame.
  ///
  /// In vi, this message translates to:
  /// **'Văn hóa không chỉ để đọc.\nNó là một cuộc chơi.'**
  String get cultureIsAGame;

  /// No description provided for @threeStagesDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi địa điểm là một câu chuyện gồm ba chặng ngắn, trực quan và có phần thưởng rõ ràng.'**
  String get threeStagesDesc;

  /// No description provided for @chooseStoryStart.
  ///
  /// In vi, this message translates to:
  /// **'Chọn nơi câu chuyện bắt đầu'**
  String get chooseStoryStart;

  /// No description provided for @featuredLocationsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục hành trình hiện tại hoặc mở một câu chuyện văn hóa mới.'**
  String get featuredLocationsDesc;

  /// No description provided for @inProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đang thực hiện'**
  String get inProgress;

  /// No description provided for @locations.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm'**
  String get locations;

  /// No description provided for @journey.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình'**
  String get journey;

  /// No description provided for @badges.
  ///
  /// In vi, this message translates to:
  /// **'Huy hiệu'**
  String get badges;

  /// No description provided for @support.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ'**
  String get support;

  /// No description provided for @faq.
  ///
  /// In vi, this message translates to:
  /// **'Câu hỏi thường gặp'**
  String get faq;

  /// No description provided for @contact.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get contact;

  /// No description provided for @legal.
  ///
  /// In vi, this message translates to:
  /// **'Pháp lý'**
  String get legal;

  /// No description provided for @privacy.
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản'**
  String get terms;

  /// No description provided for @footerDescription.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình khám phá văn hóa Hàn Quốc qua thử thách, câu chuyện và những dấu mộc đáng nhớ.'**
  String get footerDescription;

  /// No description provided for @footerCopyright.
  ///
  /// In vi, this message translates to:
  /// **'© 2026 KoreaQuest · Dự án khám phá văn hóa Hàn Quốc.'**
  String get footerCopyright;

  /// No description provided for @showPassword.
  ///
  /// In vi, this message translates to:
  /// **'Hiện mật khẩu'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn mật khẩu'**
  String get hidePassword;

  /// No description provided for @searchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm địa điểm, hành trình…'**
  String get searchHint;

  /// No description provided for @processing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý…'**
  String get processing;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @errorOccurred.
  ///
  /// In vi, this message translates to:
  /// **'Đã có lỗi xảy ra'**
  String get errorOccurred;

  /// No description provided for @avatarOf.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh đại diện của {name}'**
  String avatarOf(String name);

  /// No description provided for @xpProgress.
  ///
  /// In vi, this message translates to:
  /// **'{current} trên {next} XP'**
  String xpProgress(int current, int next);

  /// No description provided for @nextLevel.
  ///
  /// In vi, this message translates to:
  /// **'{xp} XP · Cấp {level}'**
  String nextLevel(int xp, int level);

  /// No description provided for @featuredDescription.
  ///
  /// In vi, this message translates to:
  /// **'Những điểm đáng chú ý tại địa điểm đang xem.'**
  String get featuredDescription;

  /// No description provided for @noFeatured.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có điểm đến nổi bật để hiển thị.'**
  String get noFeatured;

  /// No description provided for @destinationNumber.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đến {number}'**
  String destinationNumber(int number);

  /// No description provided for @address.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ'**
  String get address;

  /// No description provided for @activities.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động'**
  String get activities;

  /// No description provided for @categories.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get categories;

  /// No description provided for @didYouKnow.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có biết?'**
  String get didYouKnow;

  /// No description provided for @cultureDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn gốc, dấu hiệu nhận biết và gợi ý ứng xử.'**
  String get cultureDescription;

  /// No description provided for @noCulture.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có trải nghiệm văn hóa để hiển thị.'**
  String get noCulture;

  /// No description provided for @experienceNumber.
  ///
  /// In vi, this message translates to:
  /// **'Trải nghiệm {number}'**
  String experienceNumber(int number);

  /// No description provided for @originMeaning.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn gốc & ý nghĩa'**
  String get originMeaning;

  /// No description provided for @recognizableFeatures.
  ///
  /// In vi, this message translates to:
  /// **'Dấu hiệu nhận biết'**
  String get recognizableFeatures;

  /// No description provided for @relatedExperience.
  ///
  /// In vi, this message translates to:
  /// **'Trải nghiệm liên quan'**
  String get relatedExperience;

  /// No description provided for @cuisineDescription.
  ///
  /// In vi, this message translates to:
  /// **'Món ăn, nguyên liệu, hương vị và nơi trải nghiệm.'**
  String get cuisineDescription;

  /// No description provided for @noCuisine.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nội dung ẩm thực để hiển thị.'**
  String get noCuisine;

  /// No description provided for @foodNumber.
  ///
  /// In vi, this message translates to:
  /// **'Món ăn {number}'**
  String foodNumber(int number);

  /// No description provided for @specialFeature.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đặc biệt'**
  String get specialFeature;

  /// No description provided for @experiencePlaces.
  ///
  /// In vi, this message translates to:
  /// **'Nơi trải nghiệm'**
  String get experiencePlaces;

  /// No description provided for @exploreLocation.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm khám phá'**
  String get exploreLocation;

  /// No description provided for @relatedPeople.
  ///
  /// In vi, this message translates to:
  /// **'Nhân vật liên quan'**
  String get relatedPeople;

  /// No description provided for @mediaSource.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn ảnh/video'**
  String get mediaSource;

  /// No description provided for @sourceLink.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết nguồn'**
  String get sourceLink;

  /// No description provided for @viewMediaSource.
  ///
  /// In vi, this message translates to:
  /// **'Xem nguồn media'**
  String get viewMediaSource;

  /// No description provided for @historicalMilestone.
  ///
  /// In vi, this message translates to:
  /// **'Mốc lịch sử {number}'**
  String historicalMilestone(int number);

  /// No description provided for @collapse.
  ///
  /// In vi, this message translates to:
  /// **'Thu gọn'**
  String get collapse;

  /// No description provided for @openStatus.
  ///
  /// In vi, this message translates to:
  /// **'đang mở'**
  String get openStatus;

  /// No description provided for @viewedStatus.
  ///
  /// In vi, this message translates to:
  /// **'đã xem'**
  String get viewedStatus;

  /// No description provided for @unviewedStatus.
  ///
  /// In vi, this message translates to:
  /// **'chưa xem'**
  String get unviewedStatus;

  /// No description provided for @openingHours.
  ///
  /// In vi, this message translates to:
  /// **'Giờ mở cửa'**
  String get openingHours;

  /// No description provided for @ticketPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá vé'**
  String get ticketPrice;

  /// No description provided for @duration.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng'**
  String get duration;

  /// No description provided for @bestTime.
  ///
  /// In vi, this message translates to:
  /// **'Thời điểm đẹp'**
  String get bestTime;

  /// No description provided for @directions.
  ///
  /// In vi, this message translates to:
  /// **'Cách di chuyển'**
  String get directions;

  /// No description provided for @tip.
  ///
  /// In vi, this message translates to:
  /// **'Mẹo'**
  String get tip;

  /// No description provided for @travelerNotes.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ý cho du khách'**
  String get travelerNotes;

  /// No description provided for @note.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ý'**
  String get note;

  /// No description provided for @updating.
  ///
  /// In vi, this message translates to:
  /// **'Đang cập nhật'**
  String get updating;

  /// No description provided for @imageUpdating.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh đang được cập nhật'**
  String get imageUpdating;

  /// No description provided for @previousImage.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh trước'**
  String get previousImage;

  /// No description provided for @nextImage.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh tiếp theo'**
  String get nextImage;

  /// No description provided for @imagePosition.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh {current} trên {total}'**
  String imagePosition(int current, int total);

  /// No description provided for @areaMap.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ khu vực'**
  String get areaMap;

  /// No description provided for @moveUp.
  ///
  /// In vi, this message translates to:
  /// **'Đưa lên'**
  String get moveUp;

  /// No description provided for @checkInStageDescription.
  ///
  /// In vi, this message translates to:
  /// **'Xem hình ảnh, video và những lát cắt lịch sử quan trọng trước khi trả lời câu hỏi mở màn.'**
  String get checkInStageDescription;

  /// No description provided for @cultureStageDescription.
  ///
  /// In vi, this message translates to:
  /// **'Hiểu nghi lễ, kiến trúc và câu chuyện đời sống qua nhiệm vụ tương tác ngắn.'**
  String get cultureStageDescription;

  /// No description provided for @vocabularyStageDescription.
  ///
  /// In vi, this message translates to:
  /// **'Ghi nhớ từ mới theo đúng bối cảnh và hoàn tất thử thách cuối để nhận dấu mộc.'**
  String get vocabularyStageDescription;

  /// No description provided for @loadLocationContentError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải nội dung địa điểm: {error}'**
  String loadLocationContentError(String error);

  /// No description provided for @locationNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy địa điểm'**
  String get locationNotFound;

  /// No description provided for @locationNotPublished.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm này chưa được xuất bản hoặc đang được cập nhật.'**
  String get locationNotPublished;

  /// No description provided for @changeAvatar.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh đại diện'**
  String get changeAvatar;

  /// No description provided for @avatarDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chọn từ nhân vật văn hóa Hàn Quốc hoặc tải ảnh từ máy tính.'**
  String get avatarDescription;

  /// No description provided for @uploadFromDevice.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh từ máy tính'**
  String get uploadFromDevice;

  /// No description provided for @configureGemini.
  ///
  /// In vi, this message translates to:
  /// **'Cấu hình Gemini AI'**
  String get configureGemini;

  /// No description provided for @selectedModel.
  ///
  /// In vi, this message translates to:
  /// **'Model đang chọn:'**
  String get selectedModel;

  /// No description provided for @saveSettings.
  ///
  /// In vi, this message translates to:
  /// **'Lưu cài đặt'**
  String get saveSettings;

  /// No description provided for @aiVoiceCommand.
  ///
  /// In vi, this message translates to:
  /// **'AI Lệnh thoại'**
  String get aiVoiceCommand;

  /// No description provided for @apiKeySettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt API Key'**
  String get apiKeySettings;

  /// No description provided for @testLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thử nghiệm:'**
  String get testLabel;

  /// No description provided for @openProfileNow.
  ///
  /// In vi, this message translates to:
  /// **'Mở Hồ sơ ngay'**
  String get openProfileNow;

  /// No description provided for @discoverNow.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá ngay'**
  String get discoverNow;

  /// No description provided for @profileCommandCalled.
  ///
  /// In vi, this message translates to:
  /// **'Đã gọi: navigateToProfile'**
  String get profileCommandCalled;

  /// No description provided for @aiCommandHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lệnh (vd: \"Chuyển sang trang hồ sơ\")...'**
  String get aiCommandHint;

  /// No description provided for @callingGemini.
  ///
  /// In vi, this message translates to:
  /// **'Đang gọi Gemini...'**
  String get callingGemini;

  /// No description provided for @sendToAi.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lệnh tới AI'**
  String get sendToAi;

  /// No description provided for @functionCallComplete.
  ///
  /// In vi, this message translates to:
  /// **'Function Calling: {calls} → Đã chuyển trang!'**
  String functionCallComplete(String calls);

  /// No description provided for @hideRawJson.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn JSON thô'**
  String get hideRawJson;

  /// No description provided for @showRawJson.
  ///
  /// In vi, this message translates to:
  /// **'Xem JSON thô từ Gemini'**
  String get showRawJson;

  /// No description provided for @openOnYoutube.
  ///
  /// In vi, this message translates to:
  /// **'Mở trên YouTube'**
  String get openOnYoutube;

  /// No description provided for @openVideoOnYoutube.
  ///
  /// In vi, this message translates to:
  /// **'Mở video {label} trên YouTube'**
  String openVideoOnYoutube(String label);

  /// No description provided for @invalidYoutube.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết YouTube không hợp lệ.'**
  String get invalidYoutube;

  /// No description provided for @invalidYoutubeEmbed.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết YouTube không hợp lệ hoặc không thể nhúng.'**
  String get invalidYoutubeEmbed;

  /// No description provided for @chooseAvatar.
  ///
  /// In vi, this message translates to:
  /// **'HOẶC CHỌN NHÂN VẬT ĐẠI DIỆN'**
  String get chooseAvatar;

  /// No description provided for @summaryStageDescription.
  ///
  /// In vi, this message translates to:
  /// **'Tổng kết hành trình và ghi nhận những phần thưởng bạn đã chinh phục.'**
  String get summaryStageDescription;

  /// No description provided for @hanoiVietnam.
  ///
  /// In vi, this message translates to:
  /// **'Hà Nội, Việt Nam'**
  String get hanoiVietnam;

  /// No description provided for @moveDown.
  ///
  /// In vi, this message translates to:
  /// **'Đưa xuống'**
  String get moveDown;

  /// No description provided for @demoEmailHint.
  ///
  /// In vi, this message translates to:
  /// **'Email hoặc admin (chế độ demo)'**
  String get demoEmailHint;

  /// No description provided for @seoulCapital.
  ///
  /// In vi, this message translates to:
  /// **'Thủ đô Seoul'**
  String get seoulCapital;

  /// No description provided for @busanCity.
  ///
  /// In vi, this message translates to:
  /// **'Thành phố Busan'**
  String get busanCity;

  /// No description provided for @levelExplorer.
  ///
  /// In vi, this message translates to:
  /// **'LEVEL {level} · NHÀ THÁM HIỂM'**
  String levelExplorer(int level);
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
      <String>['en', 'ko', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
