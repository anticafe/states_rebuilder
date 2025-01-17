import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterBlocAll {
  int counter = 0;
  increment() {
    counter++;
  }
}

class RebuildAllExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<CounterBlocAll>(() => CounterBlocAll())],
      builder: (_, __) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: <Widget>[
          Text("Rebuild All subscribed states"),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                for (var i = 0; i < 12; i++)
                  Builder(builder: (context) {
                    final bloc =
                        Injector.getAsModel<CounterBlocAll>(context: context);
                    return StateBuilder(
                      viewModels: [bloc],
                      tag: i % 2,
                      builder: (_, __) => GridItem(
                        count: bloc.state.counter,
                        onTap: () => bloc.setState((model) => model.increment(),
                            tags: null),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final int count;
  final Function onTap;
  GridItem({this.count, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          border:
              Border.all(color: Theme.of(context).primaryColorDark, width: 4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            "$count",
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
