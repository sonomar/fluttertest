bool sortData(dataList, column) {
  (dataList as List).sort((a, b) {
    // Assuming 'a' and 'b' are Map<String, dynamic> or similar objects
    // Ensure that 'name' property exists and is a String, handling potential nulls
    final String? nameA = a[column] as String?;
    final String? nameB = b[column] as String?;

    // Handle nulls first for sorting
    if (nameA == null && nameB == null) {
      return 0; // Both are null, treat as equal
    }
    if (nameA == null) {
      return -1; // nameA is null, comes before non-null nameB
    }
    if (nameB == null) {
      return 1; // nameB is null, comes after non-null nameA
    }

    // Both are non-null Strings, so compare them
    return nameA.compareTo(nameB);
  });
  return false;
}
