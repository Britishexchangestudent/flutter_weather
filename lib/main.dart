import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_weather_openapi/constants/constants.dart';
import 'package:flutter_weather_openapi/cubits/temp_settings/temp_settings_cubit.dart';
import 'package:flutter_weather_openapi/cubits/theme/theme_cubit.dart';
import 'package:flutter_weather_openapi/cubits/weather/weather_cubit.dart';
import 'package:flutter_weather_openapi/repositories/weather_repo.dart';
import 'package:flutter_weather_openapi/services/weather_api_services.dart';
import 'package:flutter_weather_openapi/widgets/error_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:recase/recase.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => WeatherRepo(
          weatherApiServices: WeatherApiServices(httpClient: http.Client())),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WeatherCubit>(
              create: (context) =>
                  WeatherCubit(weatherRepo: context.read<WeatherRepo>())),
          BlocProvider<TempSettingsCubit>(
              create: (context) => TempSettingsCubit()),
          BlocProvider<ThemeCubit>(
              create: (context) => ThemeCubit(
                    weatherCubit: context.read<WeatherCubit>(),
                  )),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
                  title: 'Flutter Demo',
                  theme: state.appTheme == AppTheme.light
                      ? ThemeData.light()
                      : ThemeData.dark(),
                  home: const MyHomePage(title: 'Flutter Demo Home Page'),
                );
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _city;
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  _fetchWeather() {
    context.read<WeatherCubit>().fetchWeather('new york');
  }

  void _submit() {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form != null && form.validate()) {
      form.save();
      if (_city != null) {
        context.read<WeatherCubit>().fetchWeather(_city!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30.0),
          Form(
              key: _formKey,
              autovalidateMode: autovalidateMode,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextFormField(
                        autofocus: true,
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                          labelText: 'City name',
                          hintText: 'more than 2 characters',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? input) {
                          if (input == null || input.trim().length < 2) {
                            return 'City name must be at least 2 characters long';
                          }
                          return null;
                        },
                        onSaved: (String? input) {
                          _city = input;
                        }),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text("Search Weather",
                          style: TextStyle(fontSize: 18.0)),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 20),
          _showWeather(),
        ],
      ),
    );
  }

  String showTemp(double temp) {
    final tempUnit = context.watch<TempSettingsCubit>().state.tempUnit;

    if (tempUnit == TempUnit.fahrenheit) {
      return ((temp * 9 / 5) + 32).toStringAsFixed(2) + ' ℉';
    }
    return temp.toStringAsFixed(2) + ' ℃';
  }

  Widget showIcon(String icon) {
    return FadeInImage.assetNetwork(
      placeholder: 'assets/images/loading.gif',
      image: 'http://$kIconHost/img/wn/$icon@4x.png',
      width: 96,
      height: 96,
    );
  }

  Widget formatText(String description) {
    final formattedString = description.titleCase;
    return Text(
      formattedString,
      style: TextStyle(fontSize: 24.0),
      textAlign: TextAlign.center,
    );
  }

  Widget _showWeather() {
    return BlocConsumer<WeatherCubit, WeatherState>(
      listener: (context, state) {
        if (state.status == WeatherStatus.error) {
          errorDialog(context, state.error.errorMessage);
        }
      },
      builder: (context, state) {
        if (state.status == WeatherStatus.initial) {
          return Center(
            child: Text(
              'Select a city',
              style: TextStyle(fontSize: 18.0),
            ),
          );
        }
        if (state.status == WeatherStatus.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == WeatherStatus.error && state.weather.name == "") {
          return Center(
            child: Text(
              'Select a city',
              style: TextStyle(fontSize: 18.0),
            ),
          );
        }
        return Column(
          children: [
            ListTile(
              title: Text('Temparature Units'),
              subtitle: Text('Celsius/Fahrenheit (Default: Celsius)'),
              trailing: Switch(
                value: context.watch<TempSettingsCubit>().state.tempUnit ==
                    TempUnit.celsius,
                onChanged: (_) {
                  context.read<TempSettingsCubit>().toggleTempUnit();
                },
              ),
            ),
            ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 6),
                Text(
                  state.weather.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        TimeOfDay.fromDateTime(state.weather.lastUpdated)
                            .format(context),
                        style: TextStyle(fontSize: 18.0)),
                    SizedBox(width: 10.0),
                    Text(
                      '(${state.weather.country})',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
                SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showTemp(state.weather.temp),
                      style: TextStyle(
                          fontSize: 30.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                          showTemp(state.weather.tempMax),
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 10),
                        Text(
                          showTemp(state.weather.tempMin),
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Spacer(),
                    showIcon(state.weather.icon),
                    Expanded(
                        child: formatText(state.weather.description), flex: 3),
                    Spacer(),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
