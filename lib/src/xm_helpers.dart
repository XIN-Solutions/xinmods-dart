/**
 * Determine whether a link has a value in it
 */
bool isLinkSpecified(Map<String, dynamic>? link) {
  return link?['link']?['type'] == 'local';
}

/**
 * Determine whether a field has a date.
 */
bool fieldHasDate(String dateValue) {
  return dateValue.indexOf("0001") != 0;
}

