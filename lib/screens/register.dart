import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  // Dropdown + date vars
  String? selectedBlood;
  String? selectedCity;
  DateTime? selectedDate;

  // lists
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> lebanonCities = [
    "Beirut",
    "Tripoli",
    "Sidon",
    "Tyre",
    "Nabatieh",
    "Zahle",
    "Baalbek",
    "Byblos",
    "Jounieh",
    "Aley",
    "Chouf",
    "Keserwan",
    "Metn",
    "Akkar",
    "Batroun",
    "Zgharta",
    "Minieh",
    "Hermel",
  ];

  Future pickBirthday() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime(2025),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Red header
            Container(
              width: double.infinity,
              height: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(140),
                  bottomRight: Radius.circular(140),
                ),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF330000), Color(0xFFB71C1C)],
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                children: const [
                  SizedBox(height: 40),
                  Text(
                    "Registration",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Top image
            SizedBox(
              height: 180,
              child: Image.asset("assets/images/register.png"),
            ),

            const SizedBox(height: 15),

            // Form fields with margin around boxes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  buildField("Username", controller: usernameController),
                  buildField("Email", controller: emailController),
                  buildField(
                    "Password",
                    controller: passwordController,
                    isPassword: true,
                  ),
                  buildField(
                    "Confirm Password",
                    controller: confirmPassController,
                    isPassword: true,
                  ),

                  // Birthday + Blood type
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: pickBirthday,
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.only(top: 10, right: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: box(),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              selectedDate == null
                                  ? "Date of Birth"
                                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 45,
                          margin: const EdgeInsets.only(top: 10, left: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: box(),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              hint: const Text(
                                "Blood Type",
                                style: TextStyle(color: Colors.black54),
                              ),
                              value: selectedBlood,
                              items: bloodTypes
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedBlood = v),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // City dropdown
                  Container(
                    height: 45,
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: box(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: const Text(
                          "City",
                          style: TextStyle(color: Colors.black54),
                        ),
                        value: selectedCity,
                        items: lebanonCities
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedCity = v),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Register button
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Color(0xffA60000), Color(0xffFF3D3D)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text.rich(
                    TextSpan(
                      text: "By signing in you agree to our ",
                      children: [
                        TextSpan(
                          text: "Terms & Conditions",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- reusable input field
  Widget buildField(String hint, {controller, bool isPassword = false}) {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: box(),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  BoxDecoration box() => BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(15),
  );
}
