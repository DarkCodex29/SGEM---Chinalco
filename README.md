# SGEM - Sistema de Gestión Minera

[![Flutter](https://img.shields.io/badge/Flutter-3.3+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()

Aplicación multiplataforma desarrollada con Flutter para la gestión integral de operaciones mineras. Proyecto implementado por Ayesa como proveedor de soluciones tecnológicas para el cliente Minera Chinalco. Permite monitorear personal, capacitaciones, entrenamiento y administración de recursos.

<div align="center">
  <img src="assets/images/logo.png" alt="SGEM Logo" width="200"/>
</div>

## 📋 Características

- **Gestión de Personal**: Seguimiento de personal, permisos y roles en operaciones mineras
- **Capacitaciones**: Planificación, registro y seguimiento de capacitaciones del personal
- **Monitoreo**: Vigilancia en tiempo real de operaciones y cumplimiento de protocolos
- **Administración**: Gestión de recursos y configuración del sistema
- **Reportes**: Generación de informes en PDF/Excel para análisis y documentación
- **Multiplaforma**: Acceso desde cualquier dispositivo (Web, Android, iOS, Windows, macOS, Linux)

## 🚀 Instalación

### Requisitos previos

- Flutter SDK 3.3.0 o superior
- Dart SDK 3.0.0 o superior
- Conexión a Internet para descarga de dependencias

### Pasos de instalación

1. Clona este repositorio:
   ```bash
   git clone https://github.com/chinalco/sistema-gestion-mina-front.git
   cd sistema-gestion-mina-front
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Configura las variables de entorno:
   - Crea un archivo `.env` en la raíz del proyecto basado en `.env.example`
   ```
   # Ejemplo de configuración en .env
   API_URL=http://tu-servidor-api.com/SgemApi/api
   API_KEY=tu_api_key_aqui
   # ... otras variables
   ```

4. Ejecuta la aplicación:
   ```bash
   flutter run -d chrome    # Para web
   flutter run -d windows   # Para Windows
   flutter run -d android   # Para Android
   flutter run              # Para dispositivo predeterminado
   ```

## ⚙️ Configuración

### Variables de entorno

El proyecto utiliza variables de entorno para gestionar la configuración de forma segura:

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `API_URL` | URL base para la API | `http://api.ejemplo.com/SgemApi/api` |
| `API_URL_QR` | URL para códigos QR | `http://app.ejemplo.com/Sgemweb/#/qr` |
| `WEB_URL` | URL base de la aplicación web | `http://app.ejemplo.com/Sgemweb/#` |
| `API_KEY` | Clave de autenticación para la API | `abc123...` |
| `FLAG` | Entorno de ejecución | `DEV`, `STAGE`, `PROD` |
| `MCP_*` | Variables para el paquete Chinalco | Ver `.env.example` |

## 🏗️ Arquitectura

El proyecto sigue una arquitectura modular basada en GetX para la gestión de estado:

```
lib/
├── config/        # Configuración global, API y repositorios
│   ├── api/       # Servicios de API y clientes HTTP
│   ├── constants/ # Constantes y configuración
│   └── Repository/ # Implementación de repositorios
├── modules/       # Módulos funcionales organizados por características
│   └── pages/     # Páginas y vistas principales
├── shared/        # Widgets y utilidades compartidas
│   ├── widgets/   # Componentes reutilizables
│   ├── models/    # Modelos de datos
│   └── utils/     # Utilidades y helpers
└── main.dart      # Punto de entrada de la aplicación
```

### Patrones y frameworks utilizados:

- **GetX**: Para gestión de estado, inyección de dependencias y navegación
- **GoRouter**: Manejo avanzado de rutas y navegación
- **Repository Pattern**: Para separar la lógica de acceso a datos
- **Responsive Design**: Adaptación a múltiples tamaños de pantalla

## 🧪 Testing

Para ejecutar las pruebas del proyecto:

```bash
flutter test
```

## 📄 Licencia

Este proyecto es propiedad de Minera Chinalco Perú S.A. Todos los derechos reservados.

## 👥 Desarrollo

Proyecto desarrollado por Ayesa para Minera Chinalco Perú S.A.

### Desarrollador Principal
- **Gianpierre Mio**: Desarrollador de software en Ayesa, encargado de implementar esta solución para el cliente Minera Chinalco.

Para contribuir al proyecto:

1. Revisa las guías de estilo de código
2. Crea una rama para tu funcionalidad (`git checkout -b feature/nueva-funcionalidad`)
3. Haz commit de tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Envía un Pull Request

## 📞 Contacto

Para soporte o consultas, contacta al desarrollador:

- Nombre: Gianpierre Mio
- Email: gianxs296@gmail.com
- Teléfono: +51952164832
- Empresa: Desarrollador en Ayesa para el proyecto de Minera Chinalco
