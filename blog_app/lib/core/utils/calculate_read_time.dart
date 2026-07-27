int calculateReadingTime(String content) {
  /// getting the word count in scentence by new line character and space 
  final wordCount = content.split(RegExp(r'\s+')).length;

  /// cal time
  final readingTime = wordCount / 225;

  /// rounding up the reading time to the nearest whole number and returning it  
  /// cieling function is used to round up the reading time to the nearest whole number
  return readingTime.ceil();

}