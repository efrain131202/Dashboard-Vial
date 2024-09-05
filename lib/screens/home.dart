import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/components/exit_app.dart';
import 'package:vial_dashboard/screens/features/categories.dart';
import 'package:vial_dashboard/screens/features/dashboard.dart';
import 'package:vial_dashboard/screens/features/profile.dart';
import 'package:vial_dashboard/screens/features/support.dart';
import 'package:vial_dashboard/screens/features/users.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isExitSelected = false;

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.dashboard_rounded, title: 'Panel'),
    NavItem(icon: Icons.people_alt_rounded, title: 'Usuarios'),
    NavItem(icon: Icons.business_rounded, title: 'Categorías'),
    NavItem(icon: Icons.forum_rounded, title: 'Soporte'),
    NavItem(icon: Icons.account_circle_rounded, title: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          return Row(
            children: [
              _buildSideNav(isMobile),
              Expanded(child: _buildBody()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSideNav(bool isMobile) {
    double width = isMobile ? 70 : 200;
    return Container(
      width: width,
      color: const Color(0xFF2C3E50),
      child: Column(
        children: [
          Expanded(child: Container()),
          const SizedBox(height: 100),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _selectedIndex == index ? 1.0 : 0.5,
                    child: Container(
                      height: 40,
                      padding:
                          EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
                      child: Row(
                        children: [
                          Icon(
                            _navItems[index].icon,
                            size: isMobile ? 24 : 16,
                            color: Colors.white,
                          ),
                          if (!isMobile) const SizedBox(width: 12),
                          if (!isMobile)
                            Text(
                              _navItems[index].title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExitSelected = true;
              });
              Future.delayed(const Duration(milliseconds: 200), () {
                exitApp(context);
              });
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isExitSelected ? 1.0 : 0.5,
              child: Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app_rounded,
                      size: isMobile ? 24 : 16,
                      color: Colors.white,
                    ),
                    if (!isMobile) const SizedBox(width: 12),
                    if (!isMobile)
                      const Text(
                        'Salir',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C3E50),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const Dashboard();
      case 1:
        return const Users();
      case 2:
        return const Categories();
      case 3:
        return const Support();
      case 4:
        return const Profile();
      default:
        return Center(child: Text(_navItems[_selectedIndex].title));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isExitSelected = false;
    });
  }
}

class NavItem {
  final IconData icon;
  final String title;

  NavItem({required this.icon, required this.title});
}
