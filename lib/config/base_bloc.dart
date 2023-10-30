import 'package:baeit/config/common.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseBloc extends Bloc<BaseBlocEvent, BaseBlocState> {
  BaseBloc(BaseBlocState initialState) : super(initialState);
  
  @override
  void onError(Object error, StackTrace stacktrace) {
    print('BaseBloc_Error : $stacktrace');
    super.onError(error, stacktrace);
  }
}

@immutable
abstract class BaseBlocEvent {
  String? get tag => null;

  List<Object> get props => [DateTime.now()];
}

@immutable
abstract class BaseBlocState {
  String? get tag => null;

  List<Object> get props => [DateTime.now()];
}

abstract class BlocStatefulWidget extends StatefulWidget {
  const BlocStatefulWidget({Key? key}) : super(key: key);

  @override
  State<BlocStatefulWidget> createState() {
    init();
    return buildState();
  }

  init() {}

  BlocState buildState();
}

enum StateCondition { AllChanged, TypeChanged }

abstract class BlocState<B extends BaseBloc, T extends BlocStatefulWidget>
    extends State<T> with WidgetsBindingObserver {
  B? _bloc;
  var currState;
  var prevState;
  final StateCondition conditionType;

  BlocState({this.conditionType = StateCondition.TypeChanged});

  initState() {
    WidgetsBinding.instance.addObserver(this);
    _bloc = initBloc();
    super.initState();

    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == AppLifecycleState.resumed.toString()) {
        systemColorSetting();
      }
      return;
    });

    // Connectivity().onConnectivityChanged.listen((event) async {
      // 현재 모바일 데이터 통신 종료 시 제대롤 리턴이 안오는 버그가 있음
      // print("CHECK : $event");
      // print("CHECK 2 : ${await Connectivity().checkConnectivity()}");
      // if (event == ConnectivityResult.none) {
      //   customDialog(
      //       context: context, barrier: true, widget: loadingView(true));
      // }
    // });
  }

  @override
  Widget build(BuildContext context) {
    init(context);

    return BlocListener(
        bloc: _bloc,
        listenWhen: (previousState, currentState) =>
            _blocCondition(previousState, currentState),
        listener: (context, state) => blocListener(context, state),
        child: BlocBuilder(
            bloc: _bloc,
            builder: (context, state) => blocBuilder(context, state)));
  }

  init(BuildContext context) {}

  B initBloc();

  B get bloc => _bloc!;

  blocListener(BuildContext context, dynamic state);

  Widget blocBuilder(BuildContext context, dynamic state);

  bool _blocCondition(dynamic previousState, dynamic currentState) {
    prevState = previousState;
    currState = currentState;

    bool ret = conditionType == StateCondition.AllChanged ||
        currentState != previousState;

    return ret;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class ChatOpenEvent extends BaseBlocEvent {}

class ChatOpenState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

// 중복된 state 호출로 인한 예외 상황 방지
// 다음 state 가 중복될 것 같으면 반드시 아래 CheckState 호출
class CheckState extends BaseBlocState {}

class ErrorState extends BaseBlocState {}
