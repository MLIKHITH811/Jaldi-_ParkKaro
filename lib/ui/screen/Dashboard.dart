import 'package:flutter/material.dart';
import 'package:mobileoffice/ui/screen/ParkingMap.dart';
import 'package:mobileoffice/utils/Logger.dart';
import 'package:mobileoffice/controller/CurrentMonthController.dart';
import 'package:mobileoffice/ui/page/AccountPage.dart';
import 'package:mobileoffice/ui/page/DaysPage.dart';
import 'package:mobileoffice/ui/page/PlannerPage.dart';
import 'package:mobileoffice/utils/Utils.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key, this.title}) : super(key: key);

  final String title;

  @override
  DashboardState createState() => new DashboardState();
}

class DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin<Dashboard>, WidgetsBindingObserver {
  int selectedTabIndex = 0;
  Widget displayedTabWidget = null;
  TabController tabController;


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Logger.log("state $state");

    if (state == AppLifecycleState.resumed) {
      CurrentMonthReservationsController.get().updateReservations().then((r) {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: buildBottomNavigation(),
      body: new Column(children: <Widget>[
        Material(
            child: new Container(
                height: 72.0,
                child: Stack(
                  children: <Widget>[
                    Align(
                        child: Image(
                          image: AssetImage("img/car_white.png"),
                          height: 36.0,
                        ),
                        alignment: FractionalOffset(0.88, 0.95)),
                    Align(child: Text("Parking App", style: TextStyle(color: Colors.white, fontSize: 20.0),), alignment: FractionalOffset(0.05, 0.8))
                  ],
                )),
            elevation: 4.0,
            color: Colors.orange),
        new Stack(children: <Widget>[
          new Offstage(offstage: selectedTabIndex != 0, child: DaysPage()),
          new Offstage(offstage: selectedTabIndex != 1, child: PlannerPage()),
          new Offstage(offstage: selectedTabIndex != 3, child: AccountPage()),
        ])
      ]),
      floatingActionButton: null,
    );
  }

  Widget buildBottomNavigation() {
    return Builder(builder: (context) => BottomNavigationBar(
          currentIndex: selectedTabIndex,
          fixedColor: Colors.orange,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            if (index == 2) {
              ParkingMap.createFileOfPdfUrl().then((file) {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ParkingMap(file.path)));
              }).catchError((error) {
                Logger.log("pdf loading error: ${error.toString()}");
                Utils.displaySnackbarText(
                    context, "Could not load the map. Please try again later.");
              });
              return;
            }

            setState(() {
              this.selectedTabIndex = index;
            });
          },
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(
                icon: new Icon(Icons.today),
                title: new Text('Days')),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.calendar_today),
                title: new Text('Planner')),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.map),
                title: new Text('Map')),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.account_circle),
                title: new Text('Account')),
          ])
    );
  }
}
