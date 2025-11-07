import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  // Create a collection reference for 'items'
  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('items');

  // Add a new item to Firestore
  Future<void> addItem(Item item) async {
    try {
      await _itemsCollection.add(item.toMap());
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  // Get a real-time stream of all items
  Stream<List<Item>> getItemsStream() {
    return _itemsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // Update an existing item by ID
  Future<void> updateItem(Item item) async {
    try {
      if (item.id == null) {
        throw Exception('Item ID cannot be null for update operation');
      }
      await _itemsCollection.doc(item.id).update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // Delete an item by ID
  Future<void> deleteItem(String itemId) async {
    try {
      await _itemsCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }
}