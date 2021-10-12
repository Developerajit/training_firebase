import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:training_firebase/UpdateData.dart';
import 'package:training_firebase/services/AuthController.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:uuid/uuid.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();
  runApp(MyApp());
}

class AuthenticationBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AuthenticationBinding(),
      title: "My Notes",
      home: ControlPage(),
    );
  }
}
class ControlPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    return Obx((){
      return authController.user!=null?HomePage():SignInPage();
    });
  }
  
}

class SignInPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: height*0.8,
           decoration:  BoxDecoration(
             image: DecorationImage(
               image: NetworkImage("https://i.pinimg.com/originals/6f/20/38/6f20383c8ab632706dcc097d642b091a.jpg"),
               fit: BoxFit.fill
               )
           ),
            

          ),


          SizedBox(height: 50,),
          
          SignInButton(
            Buttons.Google,
            onPressed: () {
              authController.signInWithGoogle();
            },
          ),

        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left:10.0,right: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Notes",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w600),),
                    Spacer(),
                    Button1(Icons.logout, () { authController.signOut(); })
          
                  ],
                ),
                SizedBox(height: 20,),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users/${authController.user!.uid}/notes').orderBy("time").snapshots(),
                  builder: (context, snapshot) {
          
                    if(snapshot.data==null){
                      return Center(child: CircularProgressIndicator(),);
                    }

                    return StaggeredGridView.countBuilder(
                      reverse: true,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 4, 
                      itemCount: snapshot.data!.docs.length,
                       staggeredTileBuilder: (int index)=>
                       StaggeredTile.count(2, index.isEven?2:1),      
                       mainAxisSpacing: 4.0,
                       crossAxisSpacing: 4.0,            
                       itemBuilder: (context,index){
                          return InkWell(
                            onTap: (){
                              final UpdateData updateData = Get.put(UpdateData());
                              updateData.updateallData(snapshot.data!.docs[index]["title"], snapshot.data!.docs[index]["des"], snapshot.data!.docs[index]["color"], snapshot.data!.docs[index].id);
                              Get.to(UpdateNotes(title1: snapshot.data!.docs[index]["title"],subtitle1:snapshot.data!.docs[index]["des"] ,docid: snapshot.data!.docs[index].id,Colorocde: snapshot.data!.docs[index]["color"],));
                            },
                              onLongPress: (){
                                Get.bottomSheet(
                                  Container(
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Are you sure you want to delete ${snapshot.data!.docs[index]["title"]} note" ),
                                        SizedBox(height: 20,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                         
                                          

                                            TextButton(onPressed: ()async{
                                             await FirebaseFirestore.instance.doc('users/${authController.user!.uid}/notes/${snapshot.data!.docs[index].id}').delete().whenComplete(() {Get.back();});
                                              Get.snackbar("Info", "${snapshot.data!.docs[index]["title"]} deleted",backgroundColor: Colors.white);

                                            }, child: Text("Yes")),

                                              SizedBox(width: 20,),
                                               TextButton(onPressed: (){
                                              Get.back();
                                              Get.snackbar("Info", " Bach gaya",backgroundColor: Colors.white);
                                            }, child: Text("No")),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                );
                              },
                            child: Container(
                              
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(snapshot.data!.docs[index]["color"]),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${snapshot.data!.docs[index]["title"]}",style: TextStyle(fontSize: 24,color: Colors.white),overflow: TextOverflow.ellipsis,),
                                  SizedBox(height: 10,),
                                  Text("${snapshot.data!.docs[index]["des"]}",style: TextStyle(fontSize: 12,color: Colors.white),overflow: TextOverflow.ellipsis),
                                  Spacer(),
                                  Text("Last Edit: ${snapshot.data!.docs[index]["time"].toDate()}",style: TextStyle(fontSize: 8,color: Colors.white),overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          );
                        
                       },
                       );
                  }
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor:  Color(0xff28282B),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddNotes()));
        },
      ),
    );
  }
  Widget Button1(IconData iconData,VoidCallback ontap) {
    return InkWell(
      onTap: ontap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xff28282B)
        ),
        child: Icon(iconData,color: Colors.white,size: 24,),
      ),
    );
  }
}

class AddNotes extends StatefulWidget {

  @override
  _AddNotesState createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  final formKey=GlobalKey<FormState>();
  dynamic title;
  dynamic subtitle;
  int ColorCode = 0xff000000;
  var uuid = Uuid();
  final AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.transparent,
        body: Container(
          color: Color(ColorCode),
          child: Padding(
            padding: const EdgeInsets.only(left:10.0,right: 10,top: 30),
            child: Column(
              children: [
                Row(
                  children: [
                    Button1(Icons.arrow_back_ios,(){
                      Get.back();
                    }),
                    Spacer(),
                    Button1(Icons.edit,()async{
                    await  FirebaseFirestore.instance.doc("users/${authController.user!.uid}/notes/${uuid.v1()}").set({
                              'title':title,
                              'des': subtitle,
                              'color':ColorCode,
                              'docId':uuid.v1(),
                              'time':FieldValue.serverTimestamp()
                      }).whenComplete(() {
                        Get.back();
                      });
                    }),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ColorsBox(0xff000000),
                    ColorsBox(0xFFE46472),
                    ColorsBox(0xFFD5E4FE),
                    ColorsBox(0xFF6488E4),
                    ColorsBox(0xFF309397),

                    ColorsBox(0xFFd7d8f7),
                    ColorsBox(0xFFf2f2fe),
                    ColorsBox(0xfffed23e),
                    ColorsBox(0xfffe8afc),

                    ColorsBox(0xff303658),
                  ],
                ),
                SizedBox(height: 20,),
                Form(
                    key: formKey,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(

                            maxLength: 25,
                            style: TextStyle(fontSize: 25,color: Colors.white),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Title",
                                labelStyle: TextStyle(fontSize: 25,color: Colors.white)
                            ),
                            onChanged: (value){
                              
                                title=value;
                              
                            },
                          ),
                          TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: TextStyle(fontSize: 16,color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Description",
                              border: InputBorder.none,
                              labelStyle: TextStyle(fontSize: 25,color: Colors.white)
                            ),
                            onChanged: (value){
                              
                                subtitle=value;
                              
                            },
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ));
  }

  InkWell ColorsBox(int code) {
    return InkWell(
                    onTap: (){
                      setState(() {
                        ColorCode = code;
                      });
                    },
                    child: Container(
                      height: 20,
                      width: 20,
                      color: Color(code),
                    ),
                  );
  }

  Widget Button1(IconData iconData,VoidCallback ontap) {
    return InkWell(
      onTap: ontap,
      child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(15),
              
              child: Icon(iconData,color: Colors.white,size: 24,),
            ),
    );
  }
}