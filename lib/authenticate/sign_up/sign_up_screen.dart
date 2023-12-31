import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocode/geocode.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:store_responsive_dashboard/authenticate/sign_up/more_details.dart';
import 'package:store_responsive_dashboard/authenticate/sign_up/signup_successful.dart';
import 'package:store_responsive_dashboard/components/constants.dart';
import 'package:store_responsive_dashboard/components/keyboard.dart';
import 'package:store_responsive_dashboard/constants/custom_surfix_icon.dart';
import 'package:store_responsive_dashboard/constants/default_button.dart';
import 'package:store_responsive_dashboard/constants/form_error.dart';
import 'package:store_responsive_dashboard/constants/size_config.dart';
import 'package:store_responsive_dashboard/providers/laundromat.dart';
import 'package:store_responsive_dashboard/widgets/autocomplate_prediction.dart';
import 'package:store_responsive_dashboard/widgets/location_list_tile.dart';
import 'package:store_responsive_dashboard/widgets/network_utility.dart';

import 'package:store_responsive_dashboard/providers/currentUser.dart';
import 'package:store_responsive_dashboard/widgets/place_auto_complate_response.dart';
import 'package:store_responsive_dashboard/widgets/responsive.dart';
import 'package:flutter_google_places_web/flutter_google_places_web.dart';

class SignUpScreen extends StatefulWidget {
  final Function toggleView;
  static String routeName = "/sign_up";

  const SignUpScreen({super.key, required this.toggleView});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var kGoogleApiKey = apiKey;

  @override
  void initState() {
    loadImage();
    // Future.delayed(Duration(seconds: 3), () {
    //   setState(() {
    //     loading = false;
    //   });
    // });

    super.initState();
  }

// address
  final userAddressController = TextEditingController();
  // final LocatitonGeocoder geocoder = LocatitonGeocoder(apiKey);
  List<AutocompletePrediction> placePredictions = [];
  Timer? debounce;
  FocusNode focusNode = FocusNode();
  UploadTask? uploadTask;

// forms
  final formKey = GlobalKey<FormState>();

  // signup items
  final List<String> roleItems = ['Manager', 'Owner'];
  final List<String> laundryType = [
    'Laundromat',
    'Dry Cleaner',
    "Shoe Laundry",
    "Carpet Cleaner",
    "Laundromat & Dry Cleaner"
  ];
  final List<String> number = ["1", "2", "3", "4", "5 or more"];

// images loading
  loadImage() {
    asset = SvgPicture.asset("/icons/signUp.svg");
  }

  Future main() async {
    GeoCode geoCode = GeoCode();

    try {
      Coordinates coordinates = await geoCode.forwardGeocoding(
          address: FlutterGooglePlacesWeb.value['name'] ?? '');

      location =
          GeoPoint(coordinates.latitude ?? 0, coordinates.longitude ?? 0);
      print(location?.latitude);
    } catch (e) {
      print(e);
    }
  }

  PlatformFile? pickedFile;
  FilePickerResult? result;
// upload to firebase
  Future uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    final path = 'pricelist/${pickedFile!.name}';
//  final ref =FirebaseStorage.instance.ref().child('$dirpath$filename');

    final file = File(pickedFile!.path!);
    Uint8List uploadfile = result?.files.single.bytes ?? Uint8List(1);

    // String filename = basename(result?.files.single.name);

    // upload file to firebase
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putData(uploadfile);

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    // Url Download
    print("Download Link:$urlDownload");
  }

// selecting the file
  Future selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  SvgPicture? asset;

  String? selectedValue;

  String userName = '';
  String phoneNumber = '';
  String address = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String laundryT = '';
  String laundromatName = '';
  String role = '';
  String numberOfLocations = '';
  String laundry = '';
  String city = '';
  String turnAround = '';
  String uid = '';
  double distance = 0.0;
  double rating = 0.0;
  String status = 'Inactive';
  GeoPoint? location;

  String error = '';
  bool loading = false;

  final CurrentUser _auth = CurrentUser();
  final jobRole = TextEditingController();

  // void _signUpUser(String email, String password, BuildContext context) async {
  //   CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);

  //   try {
  //     if (await _currentUser.signUpWithEmailAndPassword(email, password)) {
  //       print("user signed up");
  //     }
  //   } catch (e) {}
  // }

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              icon: Icon(Icons.error),
              title: (Text(message)),
            ));
  }

  bool remember = false;
  final List<String?> errors = [];

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return loading
        ? SizedBox()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: SizedBox(
                height: height,
                width: width,
                child: Row(
                  children: [
                    ResponsiveWidget.isSmallScreen(context)
                        ? const SizedBox()
                        : Expanded(
                            child: Center(
                              child: Container(
                                height: height * .65,
                                child: asset,
                              ),
                            ),
                          ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: SizedBox(
                                width: ResponsiveWidget.isSmallScreen(context)
                                    ? width * 0.85
                                    : 400,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 15), // 4%
                                      Text("Register Business",
                                          style: headingStyle),
                                      const SizedBox(
                                        height: 10,
                                      ),

                                      Text(
                                        "Join the Team, Let's build together.",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 10),
                                      Column(
                                        children: [
                                          Form(
                                            key: formKey,
                                            child: Column(
                                              children: [
                                                Text("User Details",
                                                    style: headingStyle),
                                                const SizedBox(height: 5),
                                                buildRoleDropdown(),
                                                const SizedBox(height: 15),
                                                buildFirstNameFormField(),
                                                const SizedBox(height: 15),
                                                buildPhoneNumberFormField(),
                                                const SizedBox(height: 15),
                                                buildEmailFormField(),
                                                const SizedBox(height: 15),
                                                buildPasswordFormField(),
                                                const SizedBox(height: 15),
                                                buildConfirmPasswordFormField(),
                                                const SizedBox(height: 15),
                                                Text("Business Details",
                                                    style: headingStyle),
                                                const SizedBox(height: 5),
                                                FlutterGooglePlacesWeb(
                                                  decoration: InputDecoration(
                                                    labelText: "Address",
                                                    hintText:
                                                        "Enter your Business Address",
                                                  ),
                                                  apiKey: apiKey,
                                                  components: "country:za",
                                                  proxyURL:
                                                      'https://cors-anywhere.herokuapp.com/',
                                                  required: true,
                                                ),
                                                const SizedBox(height: 15),
                                                buildLaundryTypeDropdown(),
                                                const SizedBox(height: 15),
                                                buildLaundryNameFormField(),
                                                const SizedBox(height: 15),
                                                buildNumberOfLocations(),
                                                const SizedBox(height: 15),
                                                buildTurnAroundTimeFormField(),
                                                const SizedBox(height: 15),
                                                SizedBox(
                                                    height:
                                                        pickedFile?.name == null
                                                            ? 15
                                                            : 0),
                                                pickedFile?.name == null
                                                    ? SizedBox()
                                                    : SizedBox(
                                                        height: 100,
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(Icons
                                                                  .file_copy_outlined),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(pickedFile
                                                                      ?.name ??
                                                                  ''),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                pickedFile?.name == null
                                                    ? Text(
                                                        "Please Upload a copy of your Pricelist")
                                                    : SizedBox(),
                                                SizedBox(
                                                    height:
                                                        pickedFile?.name == null
                                                            ? 15
                                                            : 0),
                                                pickedFile?.name == null
                                                    ? SizedBox(
                                                        width: width * 0.10,
                                                        height:
                                                            getProportionateScreenHeight(
                                                                60),
                                                        child: ElevatedButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15)),
                                                            primary:
                                                                Colors.white,
                                                            backgroundColor:
                                                                Colors
                                                                    .blue[300],
                                                          ),
                                                          onPressed: () {
                                                            selectFile();
                                                          },
                                                          child: Text(
                                                            "Upload Pricelist",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getProportionateScreenWidth(
                                                                      18),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                                SizedBox(
                                                    height:
                                                        pickedFile?.name == null
                                                            ? 15
                                                            : 0),
                                                FormError(errors: errors),
                                                const SizedBox(height: 15),
                                                DefaultButton(
                                                  text: "Submit",
                                                  press: () async {
                                                    if (formKey.currentState!
                                                        .validate()) {
                                                      setState(() {
                                                        address =
                                                            FlutterGooglePlacesWeb
                                                                        .value[
                                                                    'name'] ??
                                                                '';
                                                        city =
                                                            FlutterGooglePlacesWeb
                                                                        .value[
                                                                    'city'] ??
                                                                '';
                                                        loading = true;
                                                        Provider.of<Laundry>(
                                                                context,
                                                                listen: false)
                                                            .updateBusinessData(
                                                                userName,
                                                                phoneNumber,
                                                                role,
                                                                email,
                                                                laundromatName,
                                                                address,
                                                                laundromatName,
                                                                city,
                                                                rating,
                                                                turnAround,
                                                                location ??
                                                                    GeoPoint(
                                                                        0, 0),
                                                                distance,
                                                                laundryT,
                                                                numberOfLocations,
                                                                uid);
                                                      });

                                                      // uploadFile();

                                                      // await UserSimplePreferences
                                                      //     .setUserEmail(email);
                                                      // await UserSimplePreferences.setUserName(
                                                      //     userName);
                                                      // await UserSimplePreferences
                                                      //     .setUserPhone(phoneNumber);

                                                      KeyboardUtil.hideKeyboard(
                                                          context);

                                                      dynamic result = await _auth
                                                          .signUpWithEmailAndPassword(
                                                              email,
                                                              password,
                                                              userName,
                                                              phoneNumber,
                                                              laundromatName,
                                                              context);

                                                      if (result == "success") {
                                                        setState(() {
                                                          loading = false;

                                                          Future.delayed(
                                                              Duration(
                                                                  seconds: 3),
                                                              () {
                                                            Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            SignUpSuccess()));
                                                          });
                                                        });
                                                      } else {
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 15,
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Already Registered? ",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              widget.toggleView();
                                            },
                                            child: const Text(
                                              "Sign In",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: kPrimaryColor),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 15),

                                      Text(
                                        'By continuing your confirm that you agree \nwith our Terms and Conditions',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Widget buildLaundryTypeDropdown() {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        // Add Horizontal padding using menuItemStyleData.padding so it matches
        // the menu padding when button's width is not specified.

        labelText: "Business Type",

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        // Add more decoration..
      ),
      hint: const Text(
        'Business Type',
        // style: TextStyle(fontSize: 14),
      ),
      items: laundryType
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                      // fontSize: 14,
                      ),
                ),
              ))
          .toList(),
      validator: (value) {
        if (value == null) {
          return 'Please Select Business TYpe';
        }
        return null;
      },
      onChanged: (value) {
        laundryT = value ?? '';
        main();
      },
      onSaved: (value) {
        selectedValue = value.toString();
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget buildNumberOfLocations() {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        // Add Horizontal padding using menuItemStyleData.padding so it matches
        // the menu padding when button's width is not specified.
        focusColor: Colors.white,
        hoverColor: Colors.white,
        fillColor: Colors.white,
        labelText: "Locations",
        hintText: "Enter Number of Locations",
        border: OutlineInputBorder(
          gapPadding: 4,
          borderRadius: BorderRadius.circular(15),
        ),
        // Add more decoration..
      ),
      hint: const Text(
        'Number of Locations',
        // style: TextStyle(fontSize: 14),
      ),
      items: number
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                      // fontSize: 14,
                      ),
                ),
              ))
          .toList(),
      validator: (value) {
        if (value == null) {
          return 'Please Select the number 0f Locations';
        }
        return null;
      },
      onChanged: (value) {
        numberOfLocations = value ?? '';
      },
      onSaved: (value) {
        selectedValue = value.toString();
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  TextFormField buildTurnAroundTimeFormField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          turnAround = value;
        });

        if (value.isNotEmpty) {
          removeError(error: kTurnAroundNullError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kTurnAroundNullError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "Turn Around Time",
        hintText: "e.g. 24 or 48 hrs",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        // suffixIcon: CustomSurffixIcon(svgIcon: "/icons/User.svg"),
      ),
    );
  }

  TextFormField buildLaundryNameFormField() {
    return TextFormField(
      onChanged: (value) {
        setState(() {
          laundromatName = value;
        });

        if (value.isNotEmpty) {
          removeError(error: kBusinessNullError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kBusinessNullError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "Business Name",
        hintText: "e.g. Laundrify",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        // suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  Widget buildRoleDropdown() {
    return DropdownButtonFormField2<String>(
      isDense: true,
      isExpanded: false,
      decoration: InputDecoration(
        labelText: "Role",
        // Add Horizontal padding using menuItemStyleData.padding so it matches
        // the menu padding when button's width is not specified.

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        // Add more decoration..
      ),
      hint: const Text(
        'Select Your Role',
        // style: TextStyle(fontSize: 14),
      ),
      items: roleItems
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                      // fontSize: 14,
                      ),
                ),
              ))
          .toList(),
      validator: (value) {
        if (value == null) {
          return 'Please Select your Role';
        }
        return null;
      },
      onChanged: (value) {
        role = value ?? '';
      },
      onSaved: (value) {
        selectedValue = value.toString();
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 0),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onChanged: (value) {
        setState(() {
          password = value;
        });
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 6) {
          removeError(error: kShortPassError);
        }
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 5) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        setState(() {
          email = value;
        });

        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "/icons/Mail.svg"),
      ),
    );
  }

  TextFormField buildFirstNameFormField() {
    return TextFormField(
      onChanged: (value) {
        setState(() {
          userName = value;
        });

        if (value.isNotEmpty) {
          removeError(error: kNamelNullError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kNamelNullError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "Full Name",
        hintText: "Enter Full Name",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "/icons/User.svg"),
      ),
    );
  }

  TextFormField buildPhoneNumberFormField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      onChanged: (value) {
        setState(() {
          phoneNumber = value;
        });
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPhoneNumberNullError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "Phone Number",
        hintText: "Enter your phone number",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildConfirmPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.isNotEmpty && password == confirmPassword) {
          removeError(error: kMatchPassError);
        }
        confirmPassword = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if ((password != value)) {
          addError(error: kMatchPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Re-enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "/icons/Lock.svg"),
      ),
    );
  }
}
