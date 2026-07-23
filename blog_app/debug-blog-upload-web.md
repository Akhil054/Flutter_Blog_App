# Debug Session: blog-upload-web

Status: OPEN

## Symptom
- Uploading a blog on Chrome throws an image decode error for a `blob:` URL and then fails during Supabase storage upload with `Unsupported operation: _Namespace`.

## Scope
- Feature: blog upload
- Platform: Flutter web on Chrome

## Initial Hypotheses
- `pickImage()` returns a web `File`/blob-backed object that is safe for preview but not compatible with the storage upload call that expects bytes/web file handling.
- The preview widget uses `Image.network` with a `blob:` URL that the browser decoder intermittently cannot decode.
- `BlogRemoteDataSourceImpl.uploadBlogImage()` uses a native-file upload path that works on mobile but fails on web.
- The selected image object is valid in UI state but loses metadata or byte access by the time upload is attempted.
- The failure happens before blog row insertion, so repository flow is blocked specifically at image upload rather than at database insert.

## Evidence Log
- Pending instrumentation.

## Next Step
- Add minimal runtime instrumentation around image selection, preview source, and storage upload path.
