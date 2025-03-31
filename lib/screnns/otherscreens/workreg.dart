import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: WorkReg(),
  ));
}

class WorkReg extends StatefulWidget {
  @override
  _WorkRegState createState() => _WorkRegState();
}

class _WorkRegState extends State<WorkReg> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedJobTitle;
  String? _selectedLocation;
  bool isWorker = false;

  final List<String> jobCategories = [
    "Electronics",
    "Home",
    "Car",
    "Electrician",
    "Furniture",
    "Plumber",
    "Painter",
    "Gardener",
    "Cleaner"
  ];

  // Sri Lankan districts with popular ones first
  final List<String> districts = [
    'Colombo',
    'Kandy',
    'Galle',
    'Matara',
    'Hambantota',
    'Jaffna',
    'Negombo',
    'Kalutara',
    'Gampaha',
    'Kurunegala',
    'Anuradhapura',
    'Polonnaruwa',
    'Badulla',
    'Monaragala',
    'Ratnapura',
    'Kegalle',
    'Nuwara Eliya',
    'Trincomalee',
    'Batticaloa',
    'Ampara',
    'Puttalam',
    'Mannar',
    'Vavuniya',
    'Mullaitivu',
    'Kilinochchi'
  ];

  void _registerWorker() async {
    if (_formKey.currentState!.validate() &&
        (isWorker ? _selectedJobTitle != null : true)) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not logged in!")),
          );
          return;
        }

        // Convert rate to number before saving
        double? rate = isWorker ? double.tryParse(_rateController.text) : null;
        int? age = int.tryParse(_ageController.text);

        await FirebaseFirestore.instance.collection("workerregister").add({
          "userId": user.uid,
          "name": _nameController.text,
          "email": _emailController.text.isNotEmpty
              ? _emailController.text
              : user.email,
          "phone": _phoneController.text,
          "jobTitle": isWorker ? _selectedJobTitle : "User",
          "description": isWorker ? _descriptionController.text : "",
          "rate": isWorker ? rate : null,
          "age": age,
          "location": _selectedLocation,
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered successfully!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registration",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(26.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => isWorker = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          !isWorker ? Colors.blue : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: isWorker ? 5 : 0,
                        ),
                        child:
                        const Text("User", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => isWorker = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isWorker ? Colors.blue : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: isWorker ? 5 : 0,
                        ),
                        child: const Text("Worker",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email (Optional)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? "Enter your phone number" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null) {
                    return 'Please enter a valid number';
                  }
                  if (age < 18) {
                    return 'You must be at least 18 years old';
                  }
                  if (age > 100) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                  labelText: "District",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                items: districts.map((String district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                  });
                },
                validator: (value) =>
                value == null ? "Select your district" : null,
              ),
              const SizedBox(height: 10),
              if (isWorker) ...[
                DropdownButtonFormField<String>(
                  value: _selectedJobTitle,
                  decoration: const InputDecoration(
                    labelText: "Job Title",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                  items: jobCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedJobTitle = newValue;
                    });
                  },
                  validator: (value) =>
                  value == null ? "Select a job title" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(
                    labelText: "Hourly Rate (\$)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: isWorker
                      ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your hourly rate';
                    }
                    final rate = double.tryParse(value);
                    if (rate == null) {
                      return 'Please enter a valid number';
                    }
                    if (rate <= 0) {
                      return 'Rate must be greater than 0';
                    }
                    return null;
                  }
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description (Optional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerWorker,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    backgroundColor: Colors.blue,
                    textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child:
                  const Text("Register", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}