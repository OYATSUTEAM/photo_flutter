import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_sharing_app/bloc/theme_event.dart';
import 'package:photo_sharing_app/bloc/theme_state.dart';
import 'package:photo_sharing_app/theme/dark_mode.dart';
import 'package:photo_sharing_app/theme/light_mode.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitState(ThemeManager.themeapply(ThemeManager.readTheme()))) {
    on<ThemeDarkedMode>(
      (event, emit) {
        if (ThemeManager.readTheme() == true) {
          emit(ThemeInitState(darkMode));
        } else {
          emit(ThemeInitState(lightMode));
        }
      },
    );
  }
}
