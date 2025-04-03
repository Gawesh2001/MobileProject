import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: WorkReg(),
    debugShowCheckedModeBanner: false,
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
  bool _showWelcomeMessage = true;
  bool _isLoading = true;

  final List<String> jobCategories = [
    "Electronics Repair",
    "Home Services",
    "Auto Mechanic",
    "Electrician",
    "Furniture Assembly",
    "Plumbing",
    "Painting",
    "Gardening",
    "Cleaning"
  ];

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // First check if user has any registrations (either worker or user)
        final querySnapshot = await FirebaseFirestore.instance
            .collection("workerregister")
            .where("userId", isEqualTo: user.uid)
            .orderBy("timestamp", descending: true)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the most recent registration
          final doc = querySnapshot.docs.first;
          final data = doc.data();

          setState(() {
            // Always load these common fields
            _nameController.text = data['name'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _emailController.text = data['email'] ?? user.email ?? '';
            _ageController.text = data['age']?.toString() ?? '';
            _selectedLocation = data['location'];

            // Check if this is a worker registration
            if (data['jobTitle'] != null && data['jobTitle'] != "User") {
              isWorker = true;
              _selectedJobTitle = data['jobTitle'];
              _rateController.text = data['rate']?.toString() ?? '';
              _descriptionController.text = data['description'] ?? '';
            } else {
              isWorker = false;
            }
          });
        } else {
          // No existing data - set email if available from auth
          setState(() {
            _emailController.text = user.email ?? '';
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
        // If error occurs, at least set the email if available
        setState(() {
          _emailController.text = user.email ?? '';
        });
      }
    }
    setState(() => _isLoading = false);
  }

  void _registerWorker() async {
    if (_formKey.currentState!.validate() &&
        (isWorker ? _selectedJobTitle != null : true) &&
        _selectedLocation != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please sign in to register"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

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
          SnackBar(
            content: Text(isWorker
                ? "Service registered successfully!"
                : "User profile updated!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );

        if (isWorker) {
          _descriptionController.clear();
          _rateController.clear();
          _selectedJobTitle = null;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Welcome to GoFinder Registration",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You can register for multiple services if you're a worker.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "• Workers: Register each service you offer",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 5),
            Text(
              "• Users: Register once to access services",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _showWelcomeMessage = false);
              Navigator.pop(context);
            },
            child:
                Text("GOT IT", style: TextStyle(color: Colors.blue.shade800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcomeMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
        setState(() => _showWelcomeMessage = false);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registration",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Register as:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: Text("User"),
                                  selected: !isWorker,
                                  onSelected: (selected) =>
                                      setState(() => isWorker = !selected),
                                  selectedColor: Colors.blue.shade800,
                                  labelStyle: TextStyle(
                                    color: !isWorker
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ChoiceChip(
                                  label: Text("Worker"),
                                  selected: isWorker,
                                  onSelected: (selected) =>
                                      setState(() => isWorker = selected),
                                  selectedColor: Colors.blue.shade800,
                                  labelStyle: TextStyle(
                                    color: isWorker
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isWorker) ...[
                            SizedBox(height: 10),
                            Text(
                              "You can register multiple times for different services",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _emailController,
                          label: "Email (Optional)",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _ageController,
                          label: "Age",
                          icon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Required';
                            final age = int.tryParse(value);
                            if (age == null) return 'Invalid number';
                            if (age < 18) return 'Must be 18+';
                            if (age > 100) return 'Invalid age';
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        _buildDropdown(
                          value: _selectedLocation,
                          items: districts,
                          label: "District",
                          icon: Icons.location_on_outlined,
                          validator: (value) =>
                              value == null ? "Required" : null,
                          onChanged: (value) =>
                              setState(() => _selectedLocation = value),
                        ),
                        if (isWorker) ...[
                          SizedBox(height: 15),
                          _buildDropdown(
                            value: _selectedJobTitle,
                            items: jobCategories,
                            label: "Service Category",
                            icon: Icons.work_outline,
                            validator: (value) =>
                                value == null ? "Required" : null,
                            onChanged: (value) =>
                                setState(() => _selectedJobTitle = value),
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            controller: _rateController,
                            label: "Hourly Rate (LKR)",
                            icon: Icons.attach_money_outlined,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              final rate = double.tryParse(value);
                              if (rate == null) return 'Invalid number';
                              if (rate <= 0) return 'Must be > 0';
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: "Service Description (Optional)",
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.blue.shade800),
                              ),
                              prefixIcon: Icon(Icons.description_outlined,
                                  color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                        SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _registerWorker,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              isWorker
                                  ? "REGISTER SERVICE"
                                  : "UPDATE USER PROFILE",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (isWorker) ...[
                          SizedBox(height: 15),
                          Text(
                            "You can register again for another service",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade800),
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade800),
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      borderRadius: BorderRadius.circular(10),
      dropdownColor: Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
    );
  }
}
