import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:infinite_list_bloc/bloc/bloc.dart';
import 'package:infinite_list_bloc/post.dart';
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';
part 'post_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(_onPostFetched,
    transformer: throttleDroppable(throttleDuration));
  }

  Future<void> _onPostFetched(PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PostStatus.initial) {
        final posts = await _fetchPosts();
        return emit(state.copyWith(
          status: PostStatus.success,
          posts: posts,
          hasReachedMax: false,
        ));
      }
      final posts = await _fetchPosts(state.posts.length);
      emit(posts.isEmpty
      ? state.copyWith(hasReachedMax: true)
          :state.copyWith(
        status: PostStatus.success,
        posts: List.of(state.posts)..addAll(posts),
        hasReachedMax: false,
      )
      );
    } catch (_) {
      emit(state.copyWith(status: PostStatus.failure))
    }
  }

  final http.Client httpClient;
}