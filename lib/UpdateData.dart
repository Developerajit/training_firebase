import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:training_firebase/services/AuthController.dart';
import 'package:uuid/uuid.dart';

class UpdateNotes extends StatefulWidget {
  final String title1;
  final String subtitle1;
  final int Colorocde;
  final String docid;

  UpdateNotes({required this.title1,required this.subtitle1,required this.Colorocde,required this.docid});

  @override
  _UpdateNotesState createState() => _UpdateNotesState();
}

class _UpdateNotesState extends State<UpdateNotes> {
  final formKey=GlobalKey<FormState>();
  dynamic title;
  dynamic subtitle;
  final UpdateData updateData = Get.put(UpdateData());
  var uuid = Uuid();
  final AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.transparent,
        body: Obx((){
          return Container(
          color: Color(updateData.data.value.ColorCode!),
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
                    await  FirebaseFirestore.instance.doc("users/${authController.user!.uid}/notes/${widget.docid}").update({
                              'title':updateData.data.value.title,
                              'des':updateData.data.value.subtitle,
                              'color':updateData.data.value.ColorCode,
                              'docId':updateData.data.value.id,
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
                    ColorsBox(0xff000000,updateData.data.value.ColorCode!),
                    ColorsBox(0xFFE46472,updateData.data.value.ColorCode!),
                    ColorsBox(0xFFD5E4FE,updateData.data.value.ColorCode!),
                    ColorsBox(0xFF6488E4,updateData.data.value.ColorCode!),
                    ColorsBox(0xFF309397,updateData.data.value.ColorCode!),

                    ColorsBox(0xFFd7d8f7,updateData.data.value.ColorCode!),
                    ColorsBox(0xFFf2f2fe,updateData.data.value.ColorCode!),
                    ColorsBox(0xfffed23e,updateData.data.value.ColorCode!),
                    ColorsBox(0xfffe8afc,updateData.data.value.ColorCode!),

                    ColorsBox(0xff303658,updateData.data.value.ColorCode!),
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
                            initialValue: updateData.data.value.title,
                            maxLength: 25,
                            style: TextStyle(fontSize: 25,color: Colors.white),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Title",
                                labelStyle: TextStyle(fontSize: 25,color: Colors.white)
                            ),
                            onChanged: (value){
                              
                                updateData.updatetitle(value);
                              
                            },
                          ),
                          TextFormField(
                            initialValue: updateData.data.value.subtitle,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: TextStyle(fontSize: 16,color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Description",
                              border: InputBorder.none,
                              labelStyle: TextStyle(fontSize: 25,color: Colors.white)
                            ),
                            onChanged: (value){
                              
                                updateData.updatesubtitle(value);
                              
                            },
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
        }));
  }
   
  InkWell ColorsBox(int code,int ColorCode) {
    return InkWell(
                    onTap: (){ updateData.updateColor(code); },
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

class UpdateData extends GetxController{
    var data = Data().obs;

    updateallData(String title, String subtitle, int code, String id){
      data.update((val) {
        val!.title = title;
        val.subtitle = subtitle;
        val.ColorCode = code;
        val.id = id;
      });
    }
     updatetitle(String title){
       data.update((val) {
         val!.title = title;
       });
     }
      updatesubtitle(String subtitle){
       data.update((val) {
         val!.subtitle = subtitle;
       });
     }
      updateColor(int color){
       data.update((val) {
         val!.ColorCode = color;
       });
     }
}

class Data{
  String? title;
  String? subtitle;
  int? ColorCode;
  String? id;
  Data({this.title,this.subtitle,this.ColorCode,this.id});
}