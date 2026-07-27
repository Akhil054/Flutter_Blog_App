import 'dart:io';
import 'package:blog_app/core/common/Widgets/loader.dart';
import 'package:blog_app/core/common/Widgets/show_snakbar.dart';
import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/constants/constant.dart';
import 'package:blog_app/core/utils/pick_image.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_editor.dart';
import 'package:blog_app/core/theme/pallete.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlog extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const AddNewBlog());
  const AddNewBlog({super.key});

  @override
  State<AddNewBlog> createState() => _AddNewBlogState();
}

class _AddNewBlogState extends State<AddNewBlog> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedToppics = [];

  /// Made an variable to store the image file and displaying on screen
  File? image;

  /// Made an function to pick image from gallery and return the file, if the user has picked an image, otherwise returns null
  Future<void> selectImage() async {
    final pickedImage = await pickImage();

    /// check for null and set the state to display the image on screen
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  /// Created an function for uploading blog
  void UploadBlog(){
      /// Added validation for blog text and info also the topic selection
      if(
      formKey.currentState!.validate()
          && selectedToppics.isNotEmpty
          && image != null) {
        /// passing the data after validation
        /// state is taken from user logged in
        final posterId = (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
        context.read<BlogBloc>().add(
          BlogUpload(
              posterId: posterId,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              image: image!,
              topics: selectedToppics),
        );
      };
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              /// called the function which consists of function..
              UploadBlog();
            },
            icon: const Icon(Icons.done_rounded),
          ),
        ],
      ),
      /// wrapped in SingleChildScrollView to avoid overflow error when keyboard is open
      /// wrapped with BlocConsumer as user can know wheather its success of failure
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if(state is BlogFailure){
            showSnackBar(context, state.error);
          }
          else if(state is BlogUploadSuccess){
            /// creating an new route in blog page
            Navigator.pushAndRemoveUntil(
                context,
                BlogPage.route(),
                (route) => false,
            );
          }
        },
        builder: (context, state) {
          /// if state is in loader return const loader
          if(state is BlogLoading) {
            return const Loader();
          }

          return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          selectImage();
                        },
                        child: DottedBorder(
                          options: const RectDottedBorderOptions(
                            color: AppPalette.borderColor,
                            dashPattern: const [10, 4],
                          ),
                          child: SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: kIsWeb
                                        ? Image.network(
                                            image!.path,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            image!,
                                            fit: BoxFit.cover,
                                          ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.folder_open_rounded, size: 50),
                                      SizedBox(height: 12),
                                      Text(
                                        'Select Image',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                  
                      /// Businsess, Tech, Pro options
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          /// accessing the topics from constant core folder and displaying them in chip format
                          children: Constants.topics
                          /// Passing children to row i.e making it Iterable
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  /// GestureDetector to detect tap on chip and add it to selectedToppics list
                                  child: GestureDetector(
                                    onTap: () {
                                      /// if the chip is already selected, remove it from the list
                                      if (selectedToppics.contains(e)) {
                                        selectedToppics.remove(e);
                                        setState(() {});
                                      } else {
                                        selectedToppics.add(e);
                                        setState(() {});
                                      }
                                    },
                                    child: Chip(
                                      label: Text(e),
                                      color: selectedToppics.contains(e)
                                          ? const MaterialStatePropertyAll(
                                              AppPalette.gradient1,
                                            )
                                          : null,
                                      side: selectedToppics.contains(e) 
                                        ? null 
                                        : const BorderSide(
                                        color: AppPalette.borderColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      BlogEditor(
                          controller: titleController,
                          hintText: 'Blog Title'
                      ),
                      const SizedBox(height: 15),
                  
                      BlogEditor(
                        controller: contentController,
                        hintText: 'Blog Content',
                      ),
                    ],
                  ),
                ),
              ),
            );
        },
      ),
    );
  }
}
