import 'package:flutter/material.dart';
import 'package:genix_jot_do/data/database_helper.dart';

class SettingsMenu extends StatefulWidget {
  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  late TextEditingController _nameController;
  late String _currentUserName;
  bool _isNameExpanded = false;
  bool _isAboutExpanded = false;
  bool _isContactUsExpanded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userName = await DatabaseHelper().getUserName();
    setState(() {
      _currentUserName = userName;
      _nameController.text = userName;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text('Back'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Your Name'),
              onTap: () {
                setState(() {
                  _isNameExpanded = !_isNameExpanded;
                });
              },
              trailing: Icon(_isNameExpanded ? Icons.expand_less : Icons.expand_more),
            ),
            if (_isNameExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _currentUserName = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveUserName,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            Divider(),
            ExpansionTile(
              title: Text('About'),
              initiallyExpanded: false,
              onExpansionChanged: (isExpanded) {
                setState(() {
                  _isAboutExpanded = isExpanded;
                });
              },
              children: [
                _isAboutExpanded
                    ? ListTile(
                  title: Text(
                    'GENIX - JOT and DO Is a personalized app for quick noted and todos,that allows you to create noted and todos with just a songle click dont miss out to write important points while on a meeting and plan your activilies very well so that you wont miss out on the important tasks',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : Container(),
              ],
            ),
            ExpansionTile(
              title: Text('Contact Us'),
              initiallyExpanded: false,
              onExpansionChanged: (isExpanded) {
                setState(() {
                  _isContactUsExpanded = isExpanded;
                });
              },
              children: [
                _isContactUsExpanded
                    ? ListTile(
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'For support and Querries,Send us mail to: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: 'genixl@gmail.com',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUserName() async {
    await DatabaseHelper().updateUserName(_currentUserName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Username updated successfully')),
    );
  }
}
