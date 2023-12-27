import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_services/firestore_service.dart';
import 'screens/home_screens/profile.dart';
import 'screens/search/search_products.dart';
import 'screens/widgets/animation_text.dart';
import 'screens/widgets/cart_button.dart';
import 'screens/home_screens/cart_screen.dart';
import 'screens/home_screens/drawer_screen.dart';
import 'screens/home_screens/homepage.dart';

const List<TabItem> items = [
  TabItem(
    icon: Icons.home,
    title: 'Home',
  ),
  TabItem(
    icon: Icons.search_sharp,
    title: 'Shop',
  ),
  TabItem(
    icon: Icons.shopping_cart_outlined,
    title: 'Cart',
  ),
  TabItem(
    icon: Icons.account_box,
    title: 'Profile',
  ),
];

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();
  Color color2 = Colors.white;
  Color bgColor = Colors.red;

  int selectedIndex = 0;

  List<Widget> homeScreens = [
    const HomePageScreen(),
    const SearchProducts(),
    const CartScreen(),
    const ProfileScreen(fromLogin: false, home: true),
  ];
  List<String> titles = [
    "Home",
    "Search Product",
    "Cart",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    fireStoreService.checkAdminAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerScreen(),
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: const Icon(Icons.menu)),
        title: AnimatedText(
          titles[selectedIndex],
          fadeAnimation: true,
          key: ValueKey(titles[selectedIndex] + DateTime.now().millisecondsSinceEpoch.toString()),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          CartButton(
            onPressed: () {
              selectedIndex = 2;
              setState(() {});
            },
          )
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: homeScreens,
      ),
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: bgColor,
        color: color2,
        colorSelected: Colors.white,
        indexSelected: selectedIndex,
        onTap: (int index) => setState(() {
          selectedIndex = index;
        }),
        chipStyle: const ChipStyle(convexBridge: true),
        itemStyle: ItemStyle.circle,
        animated: false,
      ),
    );
  }
}
