import 'package:flutter/material.dart';
import 'dart:async';
import 'package:Smart_Cargo_mobile/model/profileResponse.dart';
import 'package:async/async.dart';
import 'package:Smart_Cargo_mobile/model/scheduleResponse.dart';
import 'package:Smart_Cargo_mobile/services/authService.dart';
import 'package:Smart_Cargo_mobile/services/driverService.dart';

class ScheduleOrderPage extends StatefulWidget {
  ScheduleOrderPage({Key key}) : super(key: key);

  @override
  _ScheduleOrderPageState createState() => _ScheduleOrderPageState();
}

class _ScheduleOrderPageState extends State<ScheduleOrderPage> {
  //schedule details
  StreamController _schduleController;
  StreamController _profileController;
  StreamZip scheduleAndProfle;

  bool isLoading = false;
  bool isProfileLoaded = false;
  bool initLoad = true;

  setStateIfMounted(f) {
    if (mounted) setState(f);
  }

//load profile of driver
  loadProfile() {
    setStateIfMounted(() {
      isLoading = true;
    });

    DriverService.profile().then((res) async {
      _profileController.add(res);
      if (mounted)
        setStateIfMounted(() {
          isLoading = false;
        });
      return res;
    });

    print("profile");
  }

//load schedule from network
  loadSchedule() {
    setState(() {
      isLoading = true;
    });

    DriverService.getSchedules().then((res) async {
      _schduleController.add(res);

      setState(() {
        isLoading = false;
      });
      return res;
    });

    print("schedule");
  }

  refresh() {
    //refresh schedule every 2minutes
    if (initLoad) {
      loadSchedule();
      initLoad = false;
      this.refresh();
    } else {
      Timer.periodic(Duration(seconds: 120), (_) => {loadSchedule()});
    }
  }

  @override
  void initState() {
    super.initState();
    _schduleController = new StreamController();
    _profileController = new StreamController();
    scheduleAndProfle =
        new StreamZip([_schduleController.stream, _profileController.stream]);
    this.loadProfile();
    this.refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     this.loadSchedule();
        //   },
        //   child: Icon(Icons.refresh),
        // ),
        appBar: AppBar(
          title: 
            Text("Current Schedule",
                style: TextStyle(color: Colors.black, fontFamily: 'Exo')),
       
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
                      child: StreamBuilder(
                stream: scheduleAndProfle,
                builder: (context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasData && isLoading == false) {
                    var data = ScheduleResponse.fromJson(snapshot.data[0]);
                    var profileData = ProfileResponse.fromJson(snapshot.data[1]);
                    if (data.schedule == null)
                      return Column(
                        children: [
                          Container(
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xffF3F3F3),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Text("No Schedules yet!")),
                        ],
                      );
                    else {
                      var totalOrders = data.schedule.route.length;
                      var deliverdOrders = 0;
                      var pendingOrders = 0;
                      data.schedule.route.forEach((order) {
                        order.status == 'delivered'
                            ? deliverdOrders++
                            : pendingOrders++;
                      });
                      return Column(
                        children: [
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xffF3F3F3),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: profileData.profile != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Hi ${profileData.profile.name.first} ${profileData.profile.name.last}!",
                                          style: TextStyle(
                                              fontFamily: 'Exo',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          "You are assinged to a delivery schedule",
                                          style: TextStyle(
                                              fontFamily: 'Exo',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Divider(
                                          color: Color(0xff4D5C84),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          'Vehicle Number : ${data.schedule.vehicle.licensePlate}',
                                          style: TextStyle(
                                              fontFamily: 'Exo',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          'Vehicle Type : ${data.schedule.vehicle.vehicleType.type}',
                                          style: TextStyle(
                                              fontFamily: 'Exo',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        )
                                      ],
                                    )
                                  : Center(child: CircularProgressIndicator()),
                            ),
                          ),
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xffF3F3F3),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: profileData.profile != null
                                  ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Total Number of orders : $totalOrders",
                                            style: TextStyle(
                                                fontFamily: 'Exo',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Divider(
                                            color: Color(0xff4D5C84),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          IntrinsicHeight(child:
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Pending',
                                                      style: TextStyle(
                                                          fontFamily: 'Exo',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text(
                                                      '$pendingOrders',
                                                      style: TextStyle(
                                                          fontFamily: 'Exo',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                          color: Color(0xff4D5C84)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                             VerticalDivider(color: Color(0xff4D5C84),
            thickness: 0.5, width: 20,
            indent: 5,
            endIndent:5,),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Delivered',
                                                      style: TextStyle(
                                                        fontFamily: 'Exo',
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text(
                                                      '$deliverdOrders',
                                                      style: TextStyle(
                                                          fontFamily: 'Exo',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                          color: Color(0xff4D5C84)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          )
                                        ],
                                      )
                                  : Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        ],
                      );
                    }
                  }

                  return  Center(child: CircularProgressIndicator());
                }),
          ),
        ),
      );
}