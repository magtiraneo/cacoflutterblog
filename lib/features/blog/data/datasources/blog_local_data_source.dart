/*
import 'package:caco_flutter_blog/features/blog/data/models/blog_model.dart';


abstract interface class BlogLocalDataSource {
  void uploadLocalBlogs({required List<BlogModel> blogs});
  List<BlogModel> loadBlogs();
}

class BlogLocalDataSourceImpl implements BlogLocalDataSource {
  final Box box;
  BlogLocalDataSourceImpl(this.box);

  @override
  List<BlogModel> loadBlogs() {
    // TODO: implement loadBlogs
    throw UnimplementedError();
  }

  @override
  void uploadLocalBlogs({required List<BlogModel> blogs}) {
    box.write();
  }

}
*/