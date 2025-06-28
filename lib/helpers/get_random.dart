import 'dart:math';

int? generateRandomMint(dynamic collectible, List<dynamic> userCollectibles) {
  // Ensure the essential properties exist on the collectible object
  if (collectible == null ||
      collectible.id == null ||
      collectible.circulation == null) {
    throw ArgumentError(
        'Collectible object must have "id" and "circulation" properties.');
  }

  final String collectibleId = collectible.id as String;
  final int circulation = collectible.circulation as int;

  // 1. Collect an array (Set) of all UserCollectible Mints for the given collectible
  final Set<int> usedMints = userCollectibles
      .where((uc) {
        // Ensure the essential properties exist on each userCollectible object
        if (uc == null || uc.collectibleId == null || uc.mint == null) {
          return false; // Skip invalid userCollectible entries
        }
        return uc.collectibleId == collectibleId;
      })
      .map((uc) => uc.mint as int)
      .toSet(); // Using a Set for efficient lookup

  // 2. Create a list of every number up to the circulation of the collectible,
  //    but without the numbers that are already used.
  final List<int> availableMints = [];
  for (int i = 1; i <= circulation; i++) {
    if (!usedMints.contains(i)) {
      availableMints.add(i);
    }
  }

  // 3. Return a new random number based on the numbers that remain in the second array.
  if (availableMints.isEmpty) {
    // All mints are taken.
    return null;
  }

  final random = Random();
  final int randomIndex = random.nextInt(availableMints.length) + 1;
  return availableMints[randomIndex];
}
