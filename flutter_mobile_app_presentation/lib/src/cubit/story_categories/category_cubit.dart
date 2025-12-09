import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:get_it/get_it.dart';
import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'category_cubit.sealed.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(const CategoryState.initial());

  Future<void> getCategories() async {
    emit(const CategoryState.loading());
    final result = await GetIt.I.get<VibeApiNew>().getCategories().sealed();
    if (result.isSuccessful) {
      emit(CategoryState.categories(categories: result.data));
    } else {
      emit(CategoryState.failure(error: result.error));
    }
  }
}

@Sealed()
abstract class _CategoryState {
  void initial();

  void loading();

  void categories(List<Category> categories);

  void failure(@WithType('VibeError') error);
}
