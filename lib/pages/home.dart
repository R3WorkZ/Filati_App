import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:esptouch_flutter/esptouch_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'connection_page.dart';
import '../utils/private.dart';
import '../utils/constants.dart';
import 'package:filati/utils/my_switch.dart';
import 'package:filati/helpers/switches_db_help.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _mySwitches = SwitchesDBHelp();

  final _selectedIndex = 1.obs;

  final List<bool> _isSelected = [true, false];

  initialSwitchCheck() async {
    await _mySwitches.getSwitchesStats();
    areSwitchesON();
  }

  areSwitchesON() async {
    if (_mySwitches.switch1.value == true &&
        _mySwitches.switch2.value == true &&
        _mySwitches.switch3.value == true &&
        _mySwitches.switch4.value == true) {
      _selectedIndex.value = 0;
    } else {
      _selectedIndex.value = 1;
    }
  }

  @override
  void initState() {
    initialSwitchCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      // appBar: AppBar(
      //   centerTitle: true,
      //   backgroundColor: colorWhite,
      //   elevation: 0,
      //   title: const Text(
      //     appName,
      //     style: TextStyle(color: myPrimaryColor, fontSize: 42),
      //   ),
      // ),
      body: FutureBuilder(
          future: FirebaseDatabase.instance.ref('myHome/switches').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Obx(
                () => Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //* Switch 2
                            mySwitch(_mySwitches.switch2, () async {
                              _mySwitches
                                  .setswitch2(!_mySwitches.switch2.value)
                                  .then((_) => {areSwitchesON()});
                            }),

                            //* Switch 1
                            mySwitch(_mySwitches.switch1, () async {
                              _mySwitches
                                  .setswitch1(!_mySwitches.switch1.value)
                                  .then((_) => {areSwitchesON()});
                            }),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //* Switch 4
                            mySwitch(_mySwitches.switch4, () async {
                              _mySwitches
                                  .setswitch4(!_mySwitches.switch4.value)
                                  .then((_) => {areSwitchesON()});
                            }),

                            //* Switch 3
                            mySwitch(_mySwitches.switch3, () async {
                              _mySwitches
                                  .setswitch3(!_mySwitches.switch3.value)
                                  .then((_) => {areSwitchesON()});
                            }),
                          ],
                        ),
                        //* Switch Mains
                        ToggleSwitch(
                          minHeight: 65,
                          minWidth: 170.0,
                          cornerRadius: 50.0,
                          totalSwitches: 2,
                          fontSize: 18,
                          iconSize: 32,
                          activeFgColor: colorWhite,
                          animate: true,
                          animationDuration: 300,
                          radiusStyle: true,
                          inactiveBgColor: colorGrey,
                          inactiveFgColor: colorWhite,
                          initialLabelIndex: _selectedIndex.value,
                          labels: const ['Lights ON', 'Lights OFF'],
                          icons: const [
                            FontAwesomeIcons.solidLightbulb,
                            FontAwesomeIcons.solidLightbulb
                          ],
                          activeBgColors: const [
                            [myPrimaryColor],
                            [Colors.black26]
                          ],
                          onToggle: (index) {
                            if (index == 0) {
                              _mySwitches
                                  .setAllSwitches(true)
                                  .then((_) => {areSwitchesON()});
                            } else if (index == 1) {
                              _mySwitches
                                  .setAllSwitches(false)
                                  .then((_) => {areSwitchesON()});
                            }

                            for (int i = 0; i < _isSelected.length; i++) {
                              _selectedIndex.value = index!;
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SizedBox(width: double.maxFinite),
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text('Retrieving Data...', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  Text('Please Wait!!!', style: TextStyle(fontSize: 14))
                ],
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Something Went Wrong! \n${snapshot.error}',
                    style: const TextStyle(fontSize: 16)),
              );
            } else {
              return const Center(
                child: Text(
                    'Something Went Wrong! \nCheck your Network connection & Try Reloading...',
                    style: TextStyle(fontSize: 16)),
              );
            }
          }),
      //* Connct to Wifi Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() => FloatingActionButton(
            onPressed: connectWifi,
            tooltip: 'SmartConnect Wifi',
            backgroundColor:
                _selectedIndex.value == 1 ? Colors.black45 : myPrimaryColor,
            child: const FaIcon(
              FontAwesomeIcons.plus,
              color: colorWhite,
            ),
          )),
    );
  }

  //* Connct to Wifi Func
  connectWifi() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController ssid = TextEditingController(text: mySSID),
        bssid = TextEditingController(text: myBSSID),
        password = TextEditingController(text: myPASS);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Center(
                child: Text(
              'Enter Wifi Credentials',
              style: TextStyle(fontSize: 24, color: myPrimaryColor),
            )),
            content: Form(
              key: formKey,
              child: Wrap(
                // shrinkWrap: true,
                // padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  TextFormField(
                    controller: ssid,
                    decoration: const InputDecoration(
                      labelText: 'SSID',
                      hintText: 'Android_AP',
                    ),
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Cannot be Empty';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: bssid,
                    decoration: const InputDecoration(
                      labelText: 'BSSID',
                      hintText: '00:a0:c9:14:c8:29',
                    ),
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Cannot be Empty';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: password,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: r'V3Ry.S4F3-P@$$w0rD',
                    ),
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Cannot be Empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConnectionPage(
                            task: ESPTouchTask(
                                ssid: ssid.text,
                                bssid: bssid.text,
                                password: password.text,
                                packet: ESPTouchPacket.broadcast,
                                taskParameter: const ESPTouchTaskParameter())),
                      ),
                    );
                  }
                },
                child: const Text('  BroadCast  '),
              ),
            ],
          );
        });
  }
}
