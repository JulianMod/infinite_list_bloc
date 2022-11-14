import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:infinite_list_bloc/bloc/bloc.dart';
import 'package:infinite_list_bloc/post.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    /// TODO: register on<PostFetched> event
  }

  final http.Client httpClient;
}