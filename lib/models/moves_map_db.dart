import 'dart:convert';

class MovesMapDB {
  final Map<double, MonMovesLib> _moveMap;

  Map<double, MonMovesLib> get all {
    return Map<double, MonMovesLib>.from(_moveMap);
  }

  MovesMapDB.initFromJson(String jsonString) : _moveMap = _decodeMoveMapJson(jsonString);

  static Map<double, MonMovesLib> _decodeMoveMapJson(String jsonString) {
    Map<double, MonMovesLib> map = {};
    
    List jsonData = json.decode(jsonString);
    
    for (var moveObj in jsonData) {
      int moveId = moveObj['move_id'];
      List basePool = List.from(moveObj['base_pool']);
      List extendedPool = List.from(moveObj['extended_pool']);

      for (var baseId in basePool) {
        if (!map.containsKey(baseId)) {
          map[baseId.toDouble()] = MonMovesLib(basePool: [], extendedPool: []);
        }
        map[baseId]!.addToBase(moveId);
      }
      for (var extendedId in extendedPool) {
        if (!map.containsKey(extendedId)) {
          map[extendedId.toDouble()] = MonMovesLib(basePool: [], extendedPool: []);
        }
        map[extendedId.toDouble()]!.addToExtended(moveId);
      }
    }
    return map;
  }
}

class MonMovesLib {
  List<int> _basePool;
  List<int> _extendedPool;

  MonMovesLib({required List<int> basePool, required List<int> extendedPool}) 
    : _basePool = basePool,
      _extendedPool = extendedPool;

  void addToBase(int id) {
    _basePool.add(id);
  }

  void addToExtended(int id) {
    _extendedPool.add(id);
  }

  List<int> get basePool {
    return List<int>.from(_basePool, growable: false);
  }

  List<int> get extendedPool {
    return List<int>.from(_extendedPool, growable: false);
  }

  List<int> get all {
    List<int> pool = List<int>.from(_basePool);
    pool.addAll(_extendedPool);
    pool.sort();
    return pool;
  }
}