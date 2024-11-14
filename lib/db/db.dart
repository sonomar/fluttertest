import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './collectible.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'kloppocar_database.db'),
    // When the database is first created, create a table to store collectibles.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE collectibles(id INTEGER PRIMARY KEY, title TEXT, mint INTEGER, description TEXT, image TEXT)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  // Define a function that inserts collectibles into the database
  Future<void> insertCollectible(Collectible collectible) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Collectible into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same collectible is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'collectibles',
      collectible.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the collectibles from the collectibles table.
  Future<List<Collectible>> collectibles() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all the collectibles.
    final List<Map<String, Object?>> collectibleMaps =
        await db.query('collectibles');

    // Convert the list of each collectible's fields into a list of `Collectible` objects.
    return [
      for (final {
            'id': id as int,
            'title': title as String,
            'mint': mint as int,
            'description': description as String,
            'image': image as String,
          } in collectibleMaps)
        Collectible(
            id: id,
            title: title,
            mint: mint,
            description: description,
            image: image),
    ];
  }

  Future<void> updateCollectible(Collectible collectible) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Collectible.
    await db.update(
      'collectibles',
      collectible.toMap(),
      // Ensure that the Collectible has a matching id.
      where: 'id = ?',
      // Pass the Collectible's id as a whereArg to prevent SQL injection.
      whereArgs: [collectible.id],
    );
  }

  Future<void> deleteCollectible(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Collectible from the database.
    await db.delete(
      'collectibles',
      // Use a `where` clause to delete a specific collectible.
      where: 'id = ?',
      // Pass the Collectible's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  // Create a Collectible and add it to the collectibles table
  var kloppocarDoor = const Collectible(
      id: 0,
      title: 'Kloppocar Door',
      mint: 22,
      description: 'The Signed Left Car Door',
      image: 'default');

  await insertCollectible(kloppocarDoor);

  // Now, use the method above to retrieve all the collectibles.
  print(await collectibles()); // Prints a list that include Kloppocar Door.

  // Update kloppocarDoor's mint and save it to the database.
  kloppocarDoor = Collectible(
    id: kloppocarDoor.id,
    title: kloppocarDoor.title,
    mint: kloppocarDoor.mint + 7,
    description: kloppocarDoor.description,
    image: kloppocarDoor.image,
  );
  await updateCollectible(kloppocarDoor);

  // Print the updated results.
  print(await collectibles()); // Prints Kloppocar Door with mint 42.

  // Delete Kloppocar Door from the database.
  await deleteCollectible(kloppocarDoor.id);

  // Print the list of collectibles (empty).
  print(await collectibles());
}
