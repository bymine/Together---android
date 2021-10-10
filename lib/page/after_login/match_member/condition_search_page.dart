import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/hobby_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';

class ConditionSearchPage extends StatefulWidget {
  const ConditionSearchPage({Key? key}) : super(key: key);

  @override
  _ConditionSearchPageState createState() => _ConditionSearchPageState();
}

class _ConditionSearchPageState extends State<ConditionSearchPage> {
  TextEditingController licenseController = TextEditingController();
  List<String> _selectedLicense = [];
  RangeValues _currentRangeValues = RangeValues(10, 50);

  List<String> tagName = [];
  List<String> categoryName = [];
  List<String> categoryIdx = [];
  List<String> tagIdx = [];
  List<String> containTag = [];

  List<String> myTag = [];
  List<String> postTagIdx = [];
  Map mappingIdx = Map<String, String>();
  Map mappingName = Map<String, String>();
  Map mappingTag = Map<String, String>();
  String selectedCategory = "게임";
  String selectedTag = "롤";

  @override
  void initState() {
    super.initState();

    Future<List<FetchHobby>> future = fetchHobbyData();

    future.then((value) {
      value.forEach((element) {
        if (categoryName.contains(element.hobbyName.keys.first) == false) {
          categoryName.add(element.hobbyName.keys.first.toString());
          categoryIdx.add(element.hobbyIdx.keys.first);
        }
        if (tagName.contains(element.hobbyName.values.first) == false) {
          tagName.add(element.hobbyName.values.first.toString());
          tagIdx.add(element.hobbyIdx.values.first);
        }

        element.hobbyIdx.forEach((key, value) {
          mappingIdx[value] = key;
        });

        element.hobbyName.forEach((key, value) {
          mappingName[value] = key;
        });
      });

      tagIdx.forEach((element) {
        int i = tagIdx.indexOf(element);
        mappingTag[tagName[i]] = element;
      });

      // print(tagName);
      // print(tagIdx);
      // print(mappingIdx);
      // print(mappingName);
      print(mappingTag);
      selectedCategory = categoryName[0];
      selectedTag = tagName[0];
    });
  }

  Future<List<FetchHobby>> fetchHobbyData() async {
    return await togetherGetAPI("/user/edit_hobby", "");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: width * 0.08, right: width * 0.08, bottom: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Detail Search", style: headingStyle),
                  ElevatedButton(
                      onPressed: () async {
                        myTag.forEach((element) {
                          postTagIdx.add(mappingTag[element].toString());
                        });
                        print(postTagIdx);
                        var userIdx =
                            Provider.of<SignInModel>(context, listen: false)
                                .userIdx;

                        Navigator.of(context).pop(jsonEncode({
                          "min_age": _currentRangeValues.start.toInt(),
                          "max_age": _currentRangeValues.end.toInt(),
                          "license": _selectedLicense,
                          "main_addr": "",
                          "reference_addr": "",
                          "detail_addr": "",
                          "hobby_small_idx": postTagIdx,
                        }));
                      },
                      style: elevatedStyle,
                      child: Text("Apply"))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Age",
                style: editTitleStyle,
              ),
              SizedBox(
                height: 10,
              ),
              RangeSlider(
                min: 10,
                max: 50,
                divisions: 30,
                activeColor: Colors.blueGrey,
                values: _currentRangeValues,
                labels: RangeLabels(
                  _currentRangeValues.start.round().toString(),
                  _currentRangeValues.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                  });
                },
              ),
              MyInputField(title: "license1", hint: "Input license1"),
              MyInputField(title: "license2", hint: "Input license2"),
              MyInputField(title: "license3", hint: "Input license3"),
              MyInputField(
                title: "Hobby (${myTag.length}/3)",
                hint:
                    myTag.toString().substring(1, myTag.toString().length - 1),
                suffixIcon: IconButton(
                  onPressed: () {
                    tagBottomsheet(context, width, height)
                        .then((value) => setState(() {}));
                  },
                  icon: Icon(
                    Icons.tag,
                    color: Colors.grey,
                  ),
                ),
              ),
              MyInputField(
                title: "Address",
                hint: "",
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  tagBottomsheet(BuildContext context, double width, double height) {
    containTag = [];
    mappingName.keys.forEach((element) {
      if (mappingName[element] == selectedCategory) containTag.add(element);
    });

    selectedTag = containTag[0];
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                  left: width * 0.08,
                  right: width * 0.08,
                  top: height * 0.02,
                  bottom: height * 0.02),
              child: Wrap(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Tag",
                            style: headingStyle,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (myTag.contains(selectedTag) == false)
                                    myTag.add(selectedTag);
                                });
                                Navigator.of(context).pop();
                              },
                              style: elevatedStyle,
                              child: Text("+ Add"))
                        ],
                      ),
                      MyInputField(
                        title: "Select Category",
                        hint: "",
                        suffixIcon: DropdownButton(
                          dropdownColor: Colors.blueGrey,
                          underline: Container(),
                          isExpanded: true,
                          value: selectedCategory,
                          items: categoryName.map((value) {
                            return DropdownMenuItem(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                  ),
                                  child: Text(value,
                                      style: editSubTitleStyle.copyWith(
                                          color: Colors.black)),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value.toString();

                              containTag = [];
                              mappingName.keys.forEach((element) {
                                if (mappingName[element] == selectedCategory)
                                  containTag.add(element);
                              });
                              selectedTag = containTag[0];
                            });
                          },
                        ),
                      ),
                      MyInputField(
                        title: "Select Tag",
                        hint: "",
                        suffixIcon: DropdownButton(
                          dropdownColor: Colors.blueGrey,
                          underline: Container(),
                          isExpanded: true,
                          value: selectedTag,
                          items: containTag.map((value) {
                            return DropdownMenuItem(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                  ),
                                  child: Text(value,
                                      style: editSubTitleStyle.copyWith(
                                          color: Colors.black)),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTag = value.toString();
                            });
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          });
        });
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: Colors.black,
        ),
      ),
      actions: [
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              color: Colors.grey,
              size: 24,
            )),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
