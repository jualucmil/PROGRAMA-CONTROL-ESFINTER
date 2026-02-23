# 🚽 Control de Esfínteres — App Flutter

Aplicación Android/iOS para el seguimiento del aprendizaje de control de esfínteres infantil.

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada
├── theme/
│   └── app_theme.dart                 # Colores, tipografía, estilos globales
├── models/
│   └── registro.dart                  # Modelo de datos + enums
├── services/
│   ├── database_service.dart          # SQLite (CRUD + SharedPreferences)
│   └── pdf_service.dart               # Generación de PDFs (semanal + 30 días)
└── screens/
    ├── login_screen.dart              # Pantalla de acceso con historial
    ├── menu_principal_screen.dart     # Menú con 3 botones grandes
    ├── registro_screen.dart           # Formulario + cronómetro
    ├── matriz_semanal_screen.dart     # Matriz visual con celdas diagonales
    └── informe_30dias_screen.dart     # Estadísticas + generación PDF 30 días
```

---

## ⚙️ Instalación

### 1. Requisitos previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.10
- Android Studio o VS Code con extensión Flutter
- Dispositivo Android / emulador (API 21+) o iOS (13+)

### 2. Instalar dependencias

```bash
cd sphincter_app
flutter pub get
```

### 3. Ejecutar la aplicación

```bash
# En un dispositivo/emulador conectado:
flutter run

# Para compilar APK release:
flutter build apk --release
# El APK estará en: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Dependencias Principales

| Paquete | Versión | Uso |
|---------|---------|-----|
| `sqflite` | ^2.3.2 | Base de datos SQLite local |
| `shared_preferences` | ^2.2.2 | Historial de nombres |
| `pdf` | ^3.10.8 | Generación de PDFs |
| `printing` | ^5.12.0 | Vista previa e impresión de PDFs |
| `intl` | ^0.19.0 | Formato de fechas y horas |
| `path_provider` | ^2.1.2 | Rutas de archivos del sistema |

---

## 🎨 Funcionalidades por Pantalla

### 🔐 Pantalla de Acceso
- Campo de texto para el nombre del niño/a
- Autocomplete con los últimos 5 nombres usados (chips de acceso rápido)
- Persiste nombres via `SharedPreferences`

### 🏠 Menú Principal
- 3 botones grandes y claros con íconos emoji
- Muestra el nombre activo y la fecha actual

### ⏱ Registro (Formulario)
- **Cronómetro automático** al entrar, formato MM:SS o HH:MM:SS
- **Pregunta 1** — Estado del pañal: Nada / Pipí / Caca / Ambos
- **Pregunta 2** — Iniciativa: No pidió / Pidió ir (Pipí) / Pidió ir (Caca)
- **Pregunta 3** — Resultado en baño: Nada / Pipí / Caca / Ambos
- Botón "Finalizar y Guardar" → guarda en SQLite, muestra resumen

### 📊 Matriz Semanal
- Tabla Lunes–Viernes × 9:00–14:00 (slots de 30 min)
- **Celdas con diagonal**: punto superior-izq = pañal, punto inferior-der = baño
- **Colores**: Amarillo = Pipí, Marrón = Caca, Naranja = Ambos
- **★ Estrella púrpura** = el niño/a pidió ir
- Botón de exportar a PDF (abre vista previa de impresión)

### 📄 Informe 30 Días
- Panel de estadísticas: total sesiones, % éxito, iniciativas, etc.
- Lista de últimos 10 registros con detalle visual
- Genera PDF con **portada de estadísticas** + **una página por semana**
- Nombre de archivo automático: `Informe30Dias_NombreNino_dd-MM-yyyy.pdf`

---

## 🗃 Esquema de Base de Datos

```sql
CREATE TABLE registros (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  nombreNino       TEXT    NOT NULL,
  fecha            TEXT    NOT NULL,  -- ISO 8601
  horaInicio       TEXT    NOT NULL,  -- ISO 8601
  duracionSegundos INTEGER NOT NULL,
  estadoPanal      TEXT    NOT NULL,  -- nada | pipi | caca | ambos
  iniciativa       TEXT    NOT NULL,  -- noPidio | pidioWC | pidioCaca
  resultadoBano    TEXT    NOT NULL   -- nada | pipi | caca | ambos
);
```

---

## 🔑 Lógica de Celdas en la Matriz

```
┌─────────────────────┐
│  ● (pañal)    ★     │   ● color según estadoPanal
│         \           │   \ línea diagonal
│              ●      │   ● color según resultadoBano
└─────────────────────┘   ★ si el niño pidió (iniciativa ≠ noPidio)
```

---

## 📝 Notas Técnicas

- **Base de datos**: Se crea automáticamente en el primer arranque
- **PDFs**: Se generan en memoria y se abren en el visor de impresión del sistema
  - Permite guardar como PDF, compartir por WhatsApp/email, imprimir, etc.
- **Orientación**: Soporta portrait y landscape (la matriz semanal se ve mejor en landscape)
- **Mínimo Android**: API 21 (Android 5.0 Lollipop)
- **Mínimo iOS**: 13.0

---

## 🎯 Próximas Mejoras Sugeridas

- [ ] Exportar datos como CSV
- [ ] Gráfica de progreso semanal
- [ ] Notificaciones de recordatorio horario
- [ ] Modo oscuro
- [ ] Backup/restauración de datos via Google Drive
- [ ] Soporte para múltiples educadores/perfiles
