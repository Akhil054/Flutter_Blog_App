import 'dart:io';
import 'package:blog_app/core/common/Widgets/loader.dart';
import 'package:blog_app/core/common/Widgets/show_snakbar.dart';
import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/utils/pick_image.dart';
import 'package:blog_app/features/ai/presentation/cubit/ai_assist_cubit.dart';
import 'package:blog_app/features/blog/domain/entites/blog.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_editor.dart';
import 'package:blog_app/theme/pallete.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlog extends StatefulWidget {
  /// Pass `blog` to open this page in edit mode, pre-filled with its
  /// content - omit it for the normal "create a new blog" flow.
  static route({Blog? blog}) =>
      MaterialPageRoute(builder: (context) => AddNewBlog(existingBlog: blog));

  final Blog? existingBlog;

  const AddNewBlog({super.key, this.existingBlog});

  @override
  State<AddNewBlog> createState() => _AddNewBlogState();
}

class _AddNewBlogState extends State<AddNewBlog> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedToppics = [];

  final topics = const [
    'Technology',
    'Business',
    'Programming',
    'Entertainment',
    'Sports',
    'Food',
    'Travel',
    'Anonymous',
  ];

  /// A newly picked replacement image, if any - null means "keep whatever
  /// image the blog already has" while editing.
  File? image;

  /// The AI-generated summary for this blog, if the user has requested one -
  /// carried along to be persisted alongside the blog on submit.
  String? aiSummary;

  bool get isEditing => widget.existingBlog != null;

  @override
  void initState() {
    super.initState();
    /// AiAssistCubit is a single shared instance across the app (also used
    /// by BlogDetailpage) - reset it so a leftover state from wherever this
    /// page was navigated from doesn't flash a stale summary/suggestion
    /// card here.
    context.read<AiAssistCubit>().reset();
    final existing = widget.existingBlog;
    if (existing != null) {
      titleController.text = existing.title;
      contentController.text = existing.content;
      selectedToppics = List.of(existing.topics);
    }
  }

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

  /// Created an function for uploading/updating the blog
  void submit(){
      /// Added validation for blog text and info also the topic selection.
      /// A picked image is only required when creating - editing can keep
      /// the blog's existing image if the user didn't pick a new one.
      final hasImage = image != null || isEditing;
      if(
      formKey.currentState!.validate()
          && selectedToppics.isNotEmpty
          && hasImage) {
        final title = titleController.text.trim();
        final content = contentController.text.trim();

        if (isEditing) {
          context.read<BlogBloc>().add(
            BlogUpdate(
                blogId: widget.existingBlog!.id,
                title: title,
                content: content,
                topics: selectedToppics,
                newImage: image),
          );
        } else {
          /// passing the data after validation
          /// state is taken from user logged in
          final posterId = (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
          context.read<BlogBloc>().add(
            BlogUpload(
                posterId: posterId,
                title: title,
                content: content,
                image: image!,
                topics: selectedToppics,
                summary: aiSummary),
          );
        }
      };
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Blog' : 'Add New Blog'),
        actions: [
          IconButton(
            onPressed: () {
              /// called the function which consists of function..
              submit();
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
          else if(state is BlogSuccess){
            /// creating an new route in blog page
            Navigator.pushAndRemoveUntil(
                context,
                BlogPage.route(),
                (route) => false,
            );
          }
          else if(state is BlogUpdateSuccess){
            /// hand the updated blog back to whoever pushed this page
            /// (BlogDetailpage) so it can refresh without a re-fetch
            Navigator.pop(context, state.blog);
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
                                : (isEditing && widget.existingBlog!.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          widget.existingBlog!.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Center(child: Text('Tap to replace image')),
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
                                      )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Businsess, Tech, Pro options
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: topics
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
                                          ? const WidgetStatePropertyAll(
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

                      BlocConsumer<AiAssistCubit, AiAssistState>(
                        listener: (context, aiState) {
                          if (aiState is AiAssistFailure) {
                            showSnackBar(context, aiState.error);
                          } else if (aiState is AiSummaryReady) {
                            setState(() {
                              aiSummary = aiState.summary;
                            });
                          } else if (aiState is AiSuggestionReady) {
                            setState(() {
                              aiSummary = aiState.suggestion.summary;
                              if (aiState.suggestion.suggestedTitle.isNotEmpty) {
                                titleController.text = aiState.suggestion.suggestedTitle;
                              }
                              for (final topic in aiState.suggestion.suggestedTopics) {
                                if (topics.contains(topic) && !selectedToppics.contains(topic)) {
                                  selectedToppics.add(topic);
                                }
                              }
                            });
                          }
                        },
                        builder: (context, aiState) {
                          final isAiLoading = aiState is AiAssistLoading;
                          final canRunAi = contentController.text.trim().length >= 20;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: (isAiLoading || !canRunAi)
                                          ? null
                                          : () {
                                              context
                                                  .read<AiAssistCubit>()
                                                  .summarize(contentController.text.trim());
                                            },
                                      icon: const Icon(Icons.summarize_outlined),
                                      label: const Text('Summarize'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: (isAiLoading || !canRunAi)
                                          ? null
                                          : () {
                                              context.read<AiAssistCubit>().suggestMetadata(
                                                    title: titleController.text.trim(),
                                                    content: contentController.text.trim(),
                                                    allowedTopics: topics,
                                                  );
                                            },
                                      icon: const Icon(Icons.auto_awesome_outlined),
                                      label: const Text('Suggest title & topics'),
                                    ),
                                  ),
                                ],
                              ),
                              if (isAiLoading) ...[
                                const SizedBox(height: 10),
                                const LinearProgressIndicator(),
                              ],
                              if (aiSummary != null) ...[
                                const SizedBox(height: 10),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'AI Summary',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(aiSummary!),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
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
                        onChanged: (_) => setState(() {}),
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
