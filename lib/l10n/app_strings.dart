import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'app_localizations_vi.dart';

AppLocalizations appStrings(BuildContext context) =>
    Localizations.of<AppLocalizations>(context, AppLocalizations) ??
    AppLocalizationsVi();
