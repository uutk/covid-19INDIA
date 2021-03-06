import 'package:covid_19/widgets/app_drawer.dart';
import 'package:covid_19/widgets/create_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailedTable extends StatefulWidget {
  final Map data;
  const DetailedTable({Key key, this.data}) : super(key: key);
  @override
  _DetailedTableState createState() => _DetailedTableState();
}

class _DetailedTableState extends State<DetailedTable> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      key: _scaffoldKey,
      endDrawer: AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
         icon: Icon(Icons.arrow_back_ios),
         onPressed: (){
           Navigator.pop(context);
         },
        ),
        backgroundColor: Color(0xFF11249F).withOpacity(0.80),
        elevation: 0.0,
        actions: <Widget>[
          /*
            Note the 'Builder' is necessary so that the IconButton gets the context
            underneath the Scaffold. Without that, it would instead be using the
            context of the App and therefore wouldn't be able to find the Scaffold.
          */
          Builder(
            builder: (context)=>Tooltip(
                  message: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  child: Padding(
                  padding: EdgeInsets.only(right: 17),
                  child: GestureDetector(
                  child: SvgPicture.asset('assets/icons/menu.svg'),
                  onTap: (){
                    print(_scaffoldKey);
                    _scaffoldKey.currentState.openEndDrawer();
                  },
                ),
              ),
            ),
          )
        ],
      ),
        body: SingleChildScrollView(
          child: createTable(context , this.widget.data),
          ),
    );
  }
}