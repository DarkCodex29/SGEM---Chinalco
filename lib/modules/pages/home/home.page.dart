import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sgem/config/Repository/auth_repository.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/administracion.dart';
import 'package:sgem/modules/pages/capacitaciones/capacitacion.page.dart';
import 'package:sgem/modules/pages/consulta.entrenamiento/consulta.entrenamiento.page.dart';
import 'package:sgem/modules/pages/consulta.personal/consulta.personal.page.dart';
import 'package:sgem/modules/pages/monitoring/view/monitoring.page.dart';
import 'package:sgem/shared/widgets/app_visibility.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  factory HomePage.routeBuilder(_, __) {
    return const HomePage(key: Key('home_page'));
  }

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final isSmallScreen = screenWidth <= 400;
    final isHome = selectedIndex == 0;

    final pages = <Widget>[
      _buildHomeContent(isLargeScreen, isSmallScreen),
      PersonalSearchPage(),
      MonitoringPage(),
      CapacitacionPage(onCancel: () {}),
      ConsultaEntrenamientoPage(),
      const AdministracionPage(),
    ];

    return Scaffold(
      appBar: _buildAppBar(isSmallScreen),
      drawer:
          isHome || !isLargeScreen ? Drawer(child: _buildDrawerItems()) : null,
      body: Row(
        children: [
          if (!isHome && isLargeScreen) Drawer(child: _buildDrawerItems()),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(bool isSmallScreen) {
    final user = Get.find<AuthRepository>().user.value!;

    return AppBar(
      backgroundColor: AppTheme.backgroundBlue,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        children: [
          if (!isSmallScreen)
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
          if (!isSmallScreen) const SizedBox(width: 10),
          Expanded(
            child: Text(
              isSmallScreen ? 'GEM' : 'Gestión de Entrenamiento Mina',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 16 : 20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user.rol.nombre!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user_avatar.png'),
                  radius: 18,
                ),
                const SizedBox(width: 16),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el modal
                  Get.find<AuthRepository>().logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: StadiumBorder(),
                ),
                icon: const Icon(Icons.logout, size: 20, color: Colors.black),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawerItems() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (selectedIndex == 0)
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.backgroundBlue,
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: 50,
            ),
          ),
        _buildDrawerItem(Icons.home, 'Inicio', 0),
        AppVisibility(
          'Busqueda_de_entrenamiento_personal',
          child: _buildDrawerItem(
            Icons.search,
            'Búsqueda de Entrenamiento Personal',
            1,
          ),
        ),
        AppVisibility(
          'Consultar_monitoreos',
          child: _buildDrawerItem(
            Icons.monitor,
            'Búsqueda de Monitoreos',
            2,
          ),
        ),
        AppVisibility(
          'Busqueda_de_capacitaciones',
          child: _buildDrawerItem(
            Icons.book,
            'Búsqueda de Capacitaciones',
            3,
          ),
        ),
        AppVisibility(
          'Consultar_entrenamientos',
          child: _buildDrawerItem(
            Icons.school,
            'Consultar Entrenamiento',
            4,
          ),
        ),
        _buildDrawerItem(
          Icons.settings,
          'Administración',
          5,
        ),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent1.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? AppTheme.primaryText : AppTheme.secondaryText,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryText : AppTheme.secondaryText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            if (selectedIndex == 0 ||
                MediaQuery.of(context).size.width <= 800) {
              context.go('/');
              //Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(bool isLargeScreen, bool isSmallScreen) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 40 : 20),
        child: Column(
          children: [
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(20),
              child: const Column(
                children: [
                  Text(
                    '¡Bienvenido al Sistema de Gestión de Entrenamiento Mina!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nos complace recibirte en nuestra plataforma, dedicada a la formación y desarrollo de nuestros colaboradores. Este sistema está diseñado para proporcionarte las herramientas y recursos necesarios para garantizar tu crecimiento profesional y asegurar el cumplimiento de los más altos estándares de seguridad y eficiencia en nuestras operaciones.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.primaryText,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Wrap(
                spacing: isLargeScreen ? 24 : 12,
                runSpacing: isLargeScreen ? 24 : 12,
                alignment: WrapAlignment.center,
                children: [
                  AppVisibility(
                    'Busqueda_de_entrenamiento_personal',
                    child: _buildCard(
                      'Búsqueda de entrenamiento de personal',
                      Icons.people,
                      Colors.blue,
                      Colors.blueAccent,
                      () {
                        setState(() {
                          selectedIndex = 1;
                        });
                      },
                    ),
                  ),
                  AppVisibility(
                    'Consultar_entrenamientos',
                    child: _buildCard(
                      'Consulta de entrenamientos',
                      Icons.school,
                      Colors.lightBlue,
                      Colors.lightBlueAccent,
                      () {
                        setState(() {
                          selectedIndex = 4;
                        });
                      },
                    ),
                  ),
                  AppVisibility(
                    'Consultar_monitoreos',
                    child: _buildCard(
                      'Búsqueda de monitoreos',
                      Icons.monitor,
                      Colors.teal,
                      Colors.tealAccent,
                      () {
                        setState(() {
                          selectedIndex = 2;
                        });
                      },
                    ),
                  ),
                  AppVisibility(
                    'Busqueda_de_capacitaciones',
                    child: _buildCard(
                      'Búsqueda de capacitaciones',
                      Icons.book,
                      Colors.orange,
                      Colors.deepOrangeAccent,
                      () {
                        setState(() {
                          selectedIndex = 3;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    String title,
    IconData icon,
    Color color1,
    Color color2,
    Function()? onTap, // Nuevo parámetro
  ) {
    return GestureDetector(
      onTap: onTap, // Añade funcionalidad al tap
      child: SizedBox(
        width: 250,
        height: 170,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 10,
                right: 10,
                child: Icon(
                  Icons.trending_up,
                  size: 60,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Icon(
                        icon,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
