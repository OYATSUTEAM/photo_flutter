import 'app_state.dart';
import 'actions.dart';

AppState updateDrinksReducer(AppState state, dynamic action) {
  if (action is UpdateDrinkAction) {
    return AppState(
        drinks: state.drinks
            .map((drink) => drink.name == action.updatedDrink.name
                ? action.updatedDrink
                : drink)
            .toList());
  }
  return state;
}
