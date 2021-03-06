import 'dart:math';

import 'package:covid_19/widgets/app_drawer.dart';
import 'package:covid_19/widgets/dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:covid_19/widgets/counter.dart';
import 'package:covid_19/widgets/myheader.dart';
import 'package:covid_19/constant.dart';
import 'package:covid_19/screens/detailed_table.dart';
import 'package:covid_19/utils/utils.dart';

class Home extends StatefulWidget {
  
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Map<String,double> states={};
  bool loading = true;
  double offset = 0;
  String selected="India";
  int infected = -1;
  int deaths = -1;
  double constant = 300;
  List<dynamic> list = [];
  int recovered = -1;
  Map data = {};
  String lastUpdated="";
  bool infectedSwitchControl = false;
  bool recoveredSwitchControl = false;
  bool deathsSwitchControl = false;
  @override
  void initState() {
    super.initState();
    getData();
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: AppDrawer(),
      body: Builder(
            builder: (context)=>SingleChildScrollView(
            controller: controller,
            child: Column(
            children: <Widget>[
              MyHeader(
                image: "assets/icons/Drcorona.svg",
                textTop: "All you need",
                textBottom: "is stay at home." ,
                // scaffoldContextKey: scaffoldKey,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal : 20),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Color(0xFFE5E5E5)
                  )
                ),
                child: Row(
                  children: <Widget>[
                    SvgPicture.asset("assets/icons/maps-and-flags.svg"),
                    SizedBox(width: 20),
                    Expanded(
                      child: DropdownButton(
                        isExpanded: true,
                        underline: SizedBox(),
                        icon: SvgPicture.asset("assets/icons/dropdown.svg"),
                        value : selected,
                        items: ['India','Maharashtra','Gujarat', 'Delhi', 'Tamil Nadu', 'Rajasthan', 'Madhya Pradesh', 'Uttar Pradesh' , 'Andhra Pradesh']
                        .map<DropdownMenuItem<String>>((String value){
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value)
                          );
                        }).toList(),
                        onChanged: (value){
                          setState(() {
                            selected=value;
                            loading = true;
                          });
                          getData();
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                  Row(
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Case Update\n",
                                style: kTitleTextstyle
                              ),
                              TextSpan(
                                text: lastUpdated,
                                style: TextStyle(
                                  color : kTextLightColor
                                )
                              )
                            ]
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context){return DetailedTable(data: data);}),);
                            },
                            child: Text(
                            "See Details",
                            style: TextStyle(
                              color : kPrimaryColor,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 30,
                            color: kShadowColor,
                          ),
                        ]
                      ),
                      child : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          loading==true ? Container() : 
                          Counter(
                            color: kInfectedColor,
                            number: infected,
                            title: "Infected",
                          ),
                          loading==true ? Text('Loading...') :
                          Counter(
                            color: kRecovercolor,
                            number: recovered,
                            title: "Recovered",
                          ),
                          loading==true ? Container() :
                          Counter(
                            color: kDeathColor,
                            number: deaths,
                            title: "Deaths",
                          ),
                        ]  
                      )
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Spread of Virus",
                          style: kTitleTextstyle,
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top : 20),
                      padding: EdgeInsets.all(20),
                      height: 350,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0,10),
                            blurRadius: 30,
                            color: kShadowColor,
                          )
                        ]
                      ),
                      child: states.isEmpty ? Align(
                        alignment: Alignment.topCenter,
                        child: Text('Loading...'),
                      ) : SizedBox(
                          height: 350,
                          width: 300,
                          child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              //to fill stack(or equal to stack size)
                              child: Image.asset(
                              "assets/images/india.png",
                              fit: BoxFit.contain,
                              ),
                            ),
                            //For Rajasthan
                            Positioned(
                              left: 45 -((states['Rajasthan']/states['Total'])*constant - 10.0)/2.0,
                              top: 115 -((states['Rajasthan']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Rajasthan']/states['Total'])*constant),
                            ),
                            //For Gujarat
                            Positioned(
                              left: 30-((states['Gujarat']/states['Total'])*constant - 10.0)/2.0,
                              top: 150-((states['Gujarat']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Gujarat']/states['Total'])*constant),
                            ),
                            //For Maharashtra
                            Positioned(
                              left: 60 -((states['Maharashtra']/states['Total'])*constant - 10.0)/2.0 ,
                              top: 185 -((states['Maharashtra']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Maharashtra']/states['Total'])*constant),
                            ),
                            //For Delhi
                            Positioned(
                              left: 78 -((states['Delhi']/states['Total'])*constant - 10.0)/2.0,
                              top: 95 -((states['Delhi']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Delhi']/states['Total'])*constant),
                            ),
                            //For Madhya Pradesh
                            Positioned(
                              left: 90-((states['Madhya Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              top: 145-((states['Madhya Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Madhya Pradesh']/states['Total'])*constant),
                            ),
                            //For Uttar Pradesh
                            Positioned(
                              left: 110-((states['Uttar Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              top: 110-((states['Uttar Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Uttar Pradesh']/states['Total'])*constant),
                            ),
                            //For Andhra Pradesh
                            Positioned(
                              left: 95-((states['Andhra Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              top: 225-((states['Andhra Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Andhra Pradesh']/states['Total'])*constant),
                            ),
                            //For Telangana
                            Positioned(
                              left: 91-((states['Telangana']/states['Total'])*constant - 10.0)/2.0,
                              top: 198-((states['Telangana']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Telangana']/states['Total'])*constant),
                            ),
                            //For Karnataka
                            Positioned(
                              left: 65-((states['Karnataka']/states['Total'])*constant - 10.0)/2.0,
                              top: 230-((states['Karnataka']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Karnataka']/states['Total'])*constant),
                            ),
                            //For Tamil Nadu
                            Positioned(
                              left: 85-((states['Tamil Nadu']/states['Total'])*constant - 10.0)/2.0,
                              top: 260-((states['Tamil Nadu']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Tamil Nadu']/states['Total'])*constant),
                            ),
                            //For Kerala
                            Positioned(
                              left: 70-((states['Kerala']/states['Total'])*constant - 10.0)/2.0,
                              top: 265-((states['Kerala']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Kerala']/states['Total'])*constant),
                            ),
                            // For Goa
                            Positioned(
                              left: 50-((states['Goa']/states['Total'])*constant - 10.0)/2.0,
                              top: 220-((states['Goa']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Goa']/states['Total'])*constant),
                            ),
                            //For Odisha
                            Positioned(
                              left: 145-((states['Odisha']/states['Total'])*constant - 10.0)/2.0,
                              top: 170-((states['Odisha']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Odisha']/states['Total'])*constant),
                            ),
                            //For Bihar
                            Positioned(
                              left: 150-((states['Bihar']/states['Total'])*constant - 10.0)/2.0,
                              top: 120-((states['Bihar']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Bihar']/states['Total'])*constant),
                            ),
                            //For Haryana
                            Positioned(
                              left: 70-((states['Haryana']/states['Total'])*constant - 10.0)/2.0,
                              top: 87-((states['Haryana']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Haryana']/states['Total'])*constant ),
                            ),
                            //For West Bengal
                            Positioned(
                              left: 167-((states['West Bengal']/states['Total'])*constant - 10.0)/2.0,
                              top: 147-((states['West Bengal']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['West Bengal']/states['Total'])*constant),
                            ),
                            //For Jammu and Kashmir
                            Positioned(
                              left: 56-((states['Jammu and Kashmir']/states['Total'])*constant - 10.0)/2.0,
                              top: 43-((states['Jammu and Kashmir']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Jammu and Kashmir']/states['Total'])*constant),
                            ),
                            //For Jharkhand
                            Positioned(
                              left: 145-((states['Jharkhand']/states['Total'])*constant - 10.0)/2.0,
                              top: 145-((states['Jharkhand']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Jharkhand']/states['Total'])*constant),
                            ),
                            //For Uttarakhand
                            Positioned(
                              left: 95-((states['Uttarakhand']/states['Total'])*constant - 10.0)/2.0,
                              top: 80-((states['Uttarakhand']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Uttarakhand']/states['Total'])*constant),
                            ),
                            //For Tripura
                            Positioned(
                              left: 200-((states['Tripura']/states['Total'])*constant - 10.0)/2.0,
                              top: 140-((states['Tripura']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Tripura']/states['Total'])*constant),
                            ),
                            //For Chhattisgarh
                            Positioned(
                              left: 120-((states['Chhattisgarh']/states['Total'])*constant - 10.0)/2.0,
                              top: 160-((states['Chhattisgarh']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Chhattisgarh']/states['Total'])*constant),
                            ),
                            //For Assam
                            Positioned(
                              left: 200-((states['Assam']/states['Total'])*constant - 10.0)/2.0,
                              top: 115-((states['Assam']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Assam']/states['Total'])*constant ),
                            ),
                            //For Himachal Pradesh
                            Positioned(
                              left: 80-((states['Himachal Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              top: 220-((states['Himachal Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Himachal Pradesh']/states['Total'])*constant ),
                            ),
                            //For Ladakh
                            Positioned(
                              left: 80-((states['Ladakh']/states['Total'])*constant - 10.0)/2.0,
                              top: 30-((states['Ladakh']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Ladakh']/states['Total'])*constant),
                            ),
                            //For Andaman and Nicobar Islands
                            Positioned(
                              left: 210-((states['Andaman and Nicobar Islands']/states['Total'])*constant - 10.0)/2.0,
                              top: 250-((states['Andaman and Nicobar Islands']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Andaman and Nicobar Islands']/states['Total'])*constant),
                            ),
                            //For Meghalaya
                            Positioned(
                              left: 200-((states['Meghalaya']/states['Total'])*constant - 10.0)/2.0,
                              top: 125-((states['Meghalaya']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Meghalaya']/states['Total'])*constant),
                            ),
                            //For Manipur
                            Positioned(
                              left: 220-((states['Manipur']/states['Total'])*constant - 10.0)/2.0,
                              top: 130-((states['Manipur']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Manipur']/states['Total'])*constant),
                            ),
                            //For Mizoram
                            Positioned(
                              left: 210-((states['Mizoram']/states['Total'])*constant - 10.0)/2.0,
                              top: 150-((states['Mizoram']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Mizoram']/states['Total'])*constant),
                            ),
                            //For Arunachal Pradesh
                            Positioned(
                              left: 225-((states['Arunachal Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              top: 100-((states['Arunachal Pradesh']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Arunachal Pradesh']/states['Total'])*constant),
                            ),
                            //For Nagaland
                            Positioned(
                              left: 225-((states['Nagaland']/states['Total'])*constant - 10.0)/2.0,
                              top: 120-((states['Nagaland']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Nagaland']/states['Total'])*constant ),
                            ),
                            //For Sikkim
                            Positioned(
                              left: 175-((states['Sikkim']/states['Total'])*constant - 10.0)/2.0,
                              top: 102-((states['Sikkim']/states['Total'])*constant - 10.0)/2.0,
                              child: Dots(opaticy: 0.60, radius: (states['Sikkim']/states['Total'])*constant),
                            ),
                          ],
                        ),
                      ) 
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Spread Trends",
                          style: kTitleTextstyle,
                        ),
                        // Text(
                        //   "See details",
                        //   style: TextStyle(
                        //     color: kPrimaryColor,
                        //     fontWeight: FontWeight.w600
                        //   ),
                        // )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                          Text(
                          'Infected',
                            style: TextStyle(
                              color : Colors.deepOrange,
                              fontSize: 16
                            ),
                          ), 
                          Row(
                            children: <Widget>[
                              Text(
                                'Daily',
                                style: TextStyle(
                                  color: infectedSwitchControl==true?kInfectedColor:kTextLightColor
                                ),
                              ),
                              Switch(
                                onChanged: (bool value){
                                  setState(() {
                                    infectedSwitchControl = !infectedSwitchControl;
                                  });
                                },
                                value: infectedSwitchControl,
                                activeColor: kInfectedColor,
                                activeTrackColor: Colors.orange[100],
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey,
                              ),
                            ],
                          )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top : 20),
                      padding: EdgeInsets.only(top: 10 , bottom:  20, left: 10),
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0,10),
                            blurRadius: 30,
                            color: kShadowColor,
                          )
                        ]
                      ),
                      child: infectedSwitchControl? createBarChart('dailyconfirmed') : createChart('totalconfirmed'),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                          Text(
                          'Recovered',
                            style: TextStyle(
                              color : kRecovercolor,
                              fontSize: 16
                            ),
                          ), 
                          Row(
                            children: <Widget>[
                              Text(
                                'Daily',
                                style: TextStyle(
                                  color: recoveredSwitchControl ==true?kRecovercolor:kTextLightColor
                                ),
                              ),
                              Switch(
                                onChanged: (bool value){
                                  setState(() {
                                    recoveredSwitchControl = !recoveredSwitchControl;
                                  });
                                },
                                value: recoveredSwitchControl,
                                activeColor: kRecovercolor,
                                activeTrackColor: Colors.green[100],
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey,
                              ),
                            ],
                          )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top : 20),
                      padding: EdgeInsets.only(top: 10 , bottom:  20, left: 10),
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0,10),
                            blurRadius: 30,
                            color: kShadowColor,
                          )
                        ]
                      ),
                      child: recoveredSwitchControl==true? createBarChart('dailyrecovered') : createChart('totalrecovered'),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                          Text(
                          'Deaths',
                            style: TextStyle(
                              color : kDeathColor,
                              fontSize: 16
                            ),
                          ), 
                          Row(
                            children: <Widget>[
                              Text(
                                'Daily',
                                style: TextStyle(
                                  color: deathsSwitchControl==true ? kDeathColor:kTextLightColor
                                ),
                              ),
                              Switch(
                                onChanged: (bool value){
                                  setState(() {
                                    deathsSwitchControl = !deathsSwitchControl;
                                  });
                                },
                                value: deathsSwitchControl,
                                activeColor: kDeathColor,
                                activeTrackColor: Colors.red[100],
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey,
                              ),
                            ],
                          )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top : 20),
                      padding: EdgeInsets.only(top: 10 , bottom:  20, left: 10),
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0,10),
                            blurRadius: 30,
                            color: kShadowColor,
                          )
                        ]
                      ),
                      child: deathsSwitchControl==true ? createBarChart('dailydeceased') : createChart('totaldeceased'),
                    ),
                    SizedBox(height: 50)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getData() async{
    try{
      if(data.isEmpty){
        Response response = await get("https://api.covid19india.org/data.json");
        data =jsonDecode(response.body); 
      }
      if(list.isEmpty){
        list = data['cases_time_series'];
        list = list.reversed.toList();
      }
      lastUpdated = data['statewise'][0]['lastupdatedtime'];
      if(states.isEmpty){
        storeAllStatesDataToMap();
      }
      updateToLiveStates();
    }catch(e){
      print('error is ' + e.toString());
    }
  }
  void storeAllStatesDataToMap(){
    data['statewise'].forEach((value){
      states[value['state']] =double.parse(value['confirmed']) ;
    });
  }
  void updateToLiveStates(){
    String compareTo = selected;
    if(selected == "India"){
      compareTo = "Total";
    }
    lastUpdated = Utils().formatDate(lastUpdated);
    int index = data['statewise'].indexWhere((value)=>value['state']==compareTo);
    setState(() {
      loading = false;
      infected =int.parse(data['statewise'][index]["confirmed"]);  
      deaths =int.parse(data['statewise'][index]["deaths"]);
      recovered = int.parse(data['statewise'][index]["recovered"]);  
    });
    print('last updated at : ' + lastUpdated);
  }

  //Spread trends
  charts.Series<TimeSeriesNums, DateTime> createSeries(String id, int i, String type){
    return charts.Series<TimeSeriesNums, DateTime>(
      id : id,
      colorFn: (_, index) => type=="totalconfirmed" || type =="dailyconfirmed" ? charts.MaterialPalette.deepOrange.shadeDefault 
      : type=="totalrecovered" || type == "dailyrecovered"? 
      charts.MaterialPalette.green.shadeDefault : charts.MaterialPalette.red.shadeDefault,

      // measureFn also there
      domainFn: (TimeSeriesNums sales, _) => sales.time,
      measureFn: (TimeSeriesNums sales, _) => sales.nums,
      data: [
        TimeSeriesNums(Utils().reformatDate(list[i]['date']), int.parse(list[i][type]))
      ]
    );
  }
  Widget createChart(String type){
    List<charts.Series<TimeSeriesNums , DateTime >> seriesList = [];
    for(int i=0; i< min(list.length, 60); i++){
      String id = 'ROHIT${i+1}';
      seriesList.add(createSeries(id, i, type));
    }
    return charts.TimeSeriesChart(
      seriesList,
      animate: true,
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 10)
      ),
      defaultRenderer: new charts.LineRendererConfig(),
    );
  }
  Widget createBarChart(String type){
    List<charts.Series<TimeSeriesNums , DateTime >> seriesList = [];
    for(int i=0; i< min(list.length, 60); i++){
      String id = 'ROHIT${i+1}';
      seriesList.add(createSeries(id, i, type));
    }
    return new charts.TimeSeriesChart(
      seriesList,
      animate: true,
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 10)
      ),
      defaultRenderer: new charts.BarRendererConfig<DateTime>(),
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }
  

}
class TimeSeriesNums {
  final DateTime time;
  final int nums;
  TimeSeriesNums(this.time, this.nums);
}


