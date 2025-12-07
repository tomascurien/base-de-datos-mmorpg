# Base de Datos de Videojuego RPG – Proyecto Universitario

---

## 📘 **Descripción del Proyecto**

Este proyecto corresponde al trabajo integrador de la materia **Bases de Datos II** de la *Tecnicatura Universitaria en Programación de Sistemas*.

Diseñamos y desarrollamos una base de datos completa basada en uno de los primeros videojuegos RPG creados en Argentina (1999). Elegimos este escenario por su complejidad relacional y porque nos permitía trabajar con un universo que ya conocíamos previamente.

El proyecto incluye:

* Creación del modelo entidad-relación (DER)
* Implementación de tablas con PK y FK
* Vistas, stored procedures y triggers
* Inserción masiva de datos
* Gestión de roles y usuarios
* Reportes en Power BI

---

## 🗂️ **Contenido del Repositorio**

* `MMORPG-querys.sql` → Creación de tablas, PK, FK, vistas, procedimientos y triggers.
* `MMORPG.bak` → Respaldo completo de la base de datos.
* `Diagrama entidad-relación` → Imágenes del modelo E-R.
* `documentacion.pdf` → Informe académico completo en PDF.
* `README.md` → Este documento.

---

## 🛠️ **Tecnologías Utilizadas**

* **SQL Server** (motor principal)
* **Power BI** (visualización y análisis)
* **Mockaroo** (generación de datos masivos)

---

## 🧩 **Modelo Entidad-Relación (DER)**

A continuación se incluye el diagrama E-R diseñado para el videojuego, donde se modelan entidades como personajes, razas, clases, cuentas, estadísticas, monstruos y mucho más.
<img width="607" height="655" alt="Screenshot_ER" src="https://github.com/user-attachments/assets/d96a54f1-c3e7-4eb5-a366-80413449216e" />


---

## 🧱 **Diseño de Tablas y Procedimientos**

El desarrollo comenzó con la construcción de la tabla **CUENTAS**, base para la creación de usuarios. A partir de allí se relacionaron las entidades principales del juego:

### **Tablas principales:**

* **CUENTAS** → Usuarios del juego
* **PERSONAJES** → Datos generales del personaje
* **CLASES / CLASES_TIPOS** → Sistema de clases
* **RAZAS** → Razas disponibles
* **SEXOS** → Clasificación
* **ESTADISTICAS_PERSONAJES** → Progresión del personaje
* **ESTADISTICAS_COMBATE_PERSONAJES** → Datos de combate
* **MONSTRUOS** → Enemigos del juego
* **NIVELES** → Sistema de progreso

### **Stored Procedures destacados:**

* `crearCuenta` → Valida datos y crea cuentas
* `crearPersonaje` → Verifica existencia, límite de personajes, unicidad de nombre y validez de atributos
* `EstadisticasId` / `EstadisticasNombre` → Asignan estadísticas
* `ActualizarPersonaje` → Actualiza progreso, kills y horas jugadas

### **Trigger:**

* `trg_subirNivel` → Actualiza automáticamente nivel y estadísticas cuando corresponde

---

## 📥 **Inserción Masiva de Datos**

Utilizamos **Mockaroo** para generar datos en formato `.json` y desarrollar un procedure automatizado:

* `CREAR_DATOS_MASIVOS_EN_TABLAS` → Población automática de:

  * Cuentas
  * Personajes
  * Estadísticas
  * Niveles
  * Atributos especiales

---

## 🔐 **Roles y Usuarios**

Se crearon dos roles para administrar permisos:

* **gameMaster** → Acceso total (SELECT, INSERT, UPDATE, DELETE, EXECUTE)
* **consultant** → Solo lectura (SELECT)

Se configuraron logins, usuarios y asignación de roles correspondiente.

---

## 📊 **Reportes en Power BI**

Se diseñaron vistas y consultas específicas para analizar el estado del juego y los personajes.

### Reportes destacados:

1. Personajes creados por raza
2. Personajes creados por clase
3. Cantidad de personajes por nivel
4. Evolución de creación de cuentas
5. Promedio de kills por clase

Los datos se conectaron a Power BI para generar visualizaciones como:

* Gráfico circular de personajes por raza
* Evolución temporal de cuentas
* Barras comparativas de asesinatos por clase

---

## ▶️ **Cómo Probar el Proyecto**

1. Restaurar el archivo `backup-bbdd.sql` en SQL Server.
2. Ejecutar `schema.sql` si se desea ver el diseño desde cero.
3. Revisar las vistas y procedures incluidos.
4. Utilizar los reportes de Power BI incluidos o conectar la BD al programa.

---

## 🙌 **Autores**

* **Tomás Ignacio Curien**
* **Nicolás García Bietti**

