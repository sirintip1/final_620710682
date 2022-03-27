import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_result.dart';


class QuizzesPage extends StatefulWidget {
  const QuizzesPage({Key? key}) : super(key: key);

  @override
  _QuizzesPageState createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  late Future<List> _data = _fetch();
  var _id = 0;
  var _text = "";
  var _isCorrect = false;
  var _incorrect = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(_id < 5)
                    FutureBuilder<List>(
                      future: _data,
                      builder: (context, snapshot){
                        if(snapshot.connectionState != ConnectionState.done){
                          return const CircularProgressIndicator();
                        }

                        if(snapshot.hasData) {
                          var data = snapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.network(data[_id]['image'], height: 350.0,),
                              for(var i=0;i<data[_id]['choice_list'].length;++i)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        if(data[_id]['choice_list'][i] == data[_id]['answer']){
                                          _text = "เก่งมากค่ะ";
                                          _isCorrect = true;
                                          Timer(Duration(seconds: 1), () {
                                            setState(() {
                                              _id++;
                                              _text = "";
                                            });
                                          });

                                        }else{
                                          setState(() {
                                            _text = "ยังไม่ถูก ลองใหม่นะคะ";
                                            _isCorrect = false;
                                            _incorrect++;
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                        height: 50.0,
                                        color: Colors.blue,
                                        child: Center(child: Text(data[_id]['choice_list'][i], style: TextStyle(fontSize: 18.0),))
                                    ),
                                  ),
                                )
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("จบเกม" , style: TextStyle(fontSize: 42.0),),
                        Text("ทายผิด $_incorrect ครั้ง" , style: TextStyle(fontSize: 28.0),),
                        ElevatedButton(
                          onPressed: (){
                            setState(() {
                              _id = 0;
                              _incorrect = 0;
                              _data = _fetch();
                            });
                          },
                          child: Container(
                              height: 50.0,
                              width: 150.0,
                              color: Colors.blue,
                              child: Text("เริ่มเกมใหม่", textAlign: TextAlign.center, style: TextStyle(fontSize: 18.0),)
                          ),
                        )
                      ],
                    ),
                  if(_isCorrect)
                    Text(_text, style: TextStyle(fontSize: 28.0, color: Colors.green),)
                  else
                    Text(_text, style: TextStyle(fontSize: 28.0, color: Colors.red),)
                ],
              ),
            )
        ),
      ),
    );
  }

  Future<List> _fetch() async{
    final url = Uri.parse('https://cpsu-test-api.herokuapp.com/quizzes');
    var response = await http.get(url, headers: {'id': '620710682'},);

    var json = jsonDecode(response.body);
    var apiResult = ApiResult.fromJson(json);
    List data = apiResult.data;
    print(data);
    return data;
  }
}

