import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'common.dart';

abstract class ListenerOfStatesRebuilder {
  void update();
}

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder implements Subject {
  //key holds the observer tags and the value holds the observers
  //_observers = {"tag" : {"tagID" : observer}}
  Map<String, Map<String, ListenerOfStatesRebuilder>> _observers = {};

  List<VoidCallback> _cleanerVoidCallBackList = [];

  ///Define a function to be called each time a tag is removed
  Function(String) statesRebuilderCleaner;

  /// observers getter
  Map<String, Map<String, ListenerOfStatesRebuilder>> observers() => _observers;

  ///Check whether the model has observing states
  bool get hasState => _observers.isNotEmpty;

  ///Map of custom listners to be called when rebuildStates is called
  Map<BuildContext, void Function()> customListener = HashMap();

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  @override
  void rebuildStates([List<dynamic> tags]) {
    assert(() {
      if (!hasState && customListener.isEmpty) {
        throw Exception("ERR(rebuildStates)01: No observer is registered yet.\n"
            "You have to register at least one observer using the `StateBuilder` or StateWithMixinBuilder` widgets.\n"
            "If you are sure you have registered at least one observer and you still see this error, please report an issue in the repository.\n");
      }
      return true;
    }());

    if (tags == null) {
      _observers.forEach((t, v) {
        v?.forEach((h, observer) {
          observer?.update();
        });
      });
      Map<dynamic, void Function()> _customListener = Map.from(customListener);

      _customListener.forEach((k, v) => v());

      return;
    }

    for (final tag in tags) {
      if (tag is String) {
        final split = tag?.split(splitter);
        if (split.length == 2) {
          final _observerTag = _observers[split[0]];
          if (_observerTag == null) {
            throw Exception(
                "ERR(rebuildStates)03: The tag: '${split[0]}' is not registered in this VM observers.\n"
                "If you see this error, please report an issue in the repository.\n");
          } else {
            final _observerHash = _observerTag[split.last];
            _observerHash?.update();
            // _customListener.forEach((k, v) => v());
          }
        }
      }

      final observerList = _observers["$tag"];
      if (observerList != null) {
        observerList.forEach((t, observer) {
          observer?.update();
        });
        // _customListener.forEach((k, v) => v());
      }
    }
  }

  /// Method to add observer
  @override
  void addObserver(
      {@required String tag,
      @required ListenerOfStatesRebuilder observer,
      @required String tagID}) {
    if (tag == null || tagID == null || observer == null) return;

    _observers[tag] ??= {};
    _observers[tag][tagID] = observer;
  }

  ///Method to remove observer
  @override
  void removeObserver({
    @required String tag,
    @required String tagID,
  }) {
    if (tag != null) {
      assert(() {
        if (_observers[tag] == null) {
          final _keys = _observers.keys;
          throw Exception(
              "ERR(removeFromObservers)01: The tag: $tag is not registered in this VM observers.\n"
              "If you see this error, please report an issue in the repository.\n"
              "The registered tags are : $_keys");
        }
        return true;
      }());
      List<String> keys = List.from(_observers[tag].keys);
      assert(() {
        if (keys == null) {
          throw Exception(
              "ERR(removeFromObservers)02: The Map list referred  by '$tag' tag is empty. It should be removed from this VM observers.\n"
              "If you see this error, please report an issue in the repository.\n");
        }
        return true;
      }());

      keys.forEach((k) {
        if (k == tagID) {
          _observers[tag].remove(k);
          if (statesRebuilderCleaner != null) statesRebuilderCleaner(tagID);

          return;
        }
      });

      if (_observers[tag].isEmpty) {
        _observers.remove(tag);
        if (statesRebuilderCleaner != null) statesRebuilderCleaner(tag);
      }
    }
    if (_observers.isEmpty) {
      if (statesRebuilderCleaner != null) statesRebuilderCleaner(null);

      _cleanerVoidCallBackList?.forEach((voidCallBack) {
        if (voidCallBack != null) {
          voidCallBack();
        }
      });

      statesRebuilderCleaner = null;
      _cleanerVoidCallBackList.clear();
    }
  }

  ///Add a callback to be executed when all listeners are removed
  void cleaner(VoidCallback voidCallback) {
    _cleanerVoidCallBackList.add(voidCallback);
  }

  // TODO register service from the viewModel
  // T registerAndGet<T>(dynamic Function() model) {
  //   final _model = Inject<T>(model);
  //   final modelRegisterer =
  //       RegisterInjectedModel([_model], InjectorState.allRegisteredModelInApp);
  //   cleaner(() {
  //     modelRegisterer.unRegisterInjectedModels(false);
  //   });
  //   return Injector.get<T>();
  // }
}
