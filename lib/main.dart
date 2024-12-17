import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  int _age = 0;

  String get name => _name;
  int get age => _age;

  void updateUser(String name, int age) {
    _name = name;
    _age = age;
    notifyListeners();
  }
}

class GreetingProvider extends ChangeNotifier {
  String _greeting = 'Hello';

  String get greeting => _greeting;

  void updateGreeting(int age) {
    if (age < 12) {
      _greeting = 'Child';
    } else if (age < 20) {
      _greeting = 'Teenager';
    } else {
      _greeting = 'Adult';
    }
    notifyListeners();
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, GreetingProvider>(
          create: (_) => GreetingProvider(),
          update: (_, userProvider, greetingProvider) {
            greetingProvider?.updateGreeting(userProvider.age);
            return greetingProvider!;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: UserFormScreen(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
            bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[700]),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class UserFormScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final greetingProvider = Provider.of<GreetingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Greeting App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your details:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person,
              ),
              SizedBox(height: 15),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake,
                isNumber: true,
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    String name = _nameController.text.trim();
                    int? age = int.tryParse(_ageController.text);

                    if (name.isEmpty || age == null || age < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter valid details!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    userProvider.updateUser(name, age);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 30),
              _buildResultCard(
                'Name',
                userProvider.name.isEmpty ? 'Not entered' : userProvider.name,
                Icons.person_outline,
                Colors.blueAccent,
              ),
              _buildResultCard(
                'Age',
                userProvider.age == 0
                    ? 'Not entered'
                    : userProvider.age.toString(),
                Icons.cake_outlined,
                Colors.blue[400]!,
              ),
              _buildResultCard(
                'Greeting',
                greetingProvider.greeting,
                Icons.message,
                Colors.lightBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        labelStyle: TextStyle(color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildResultCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
