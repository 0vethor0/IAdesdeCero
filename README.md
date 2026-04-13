# 🚗 IAdesdeCero — Fundamentos Basicos sobre la IA y aplicacion del Aprendizaje por Refuerzo Evolutivo en Processing

[![Processing](https://img.shields.io/badge/Processing-4.x-blue.svg)](https://processing.org/)
[![AI](https://img.shields.io/badge/AI-Neural%20Networks-orange.svg)]()
[![GA](https://img.shields.io/badge/Algoritmo-Genético-red.svg)]()

---

## 📖 Descripción del Proyecto
Este proyecto esta inspirado del repositorio: [dino-reinforcement-learning](https://img.shields.io/badge/Algoritmo-Genético-red.svg)

**IAdesdeCero** es un proyecto educativo que implementa un sistema de **Aprendizaje por Refuerzo Evolutivo** desde cero, sin librerías externas de machine learning. El repositorio demuestra cómo una población de agentes de IA (coches autónomos) aprende a navegar una carretera 2D esquivando obstáculos mediante la combinación de **Redes Neuronales Artificiales** y **Algoritmos Genéticos**.

### 🎯 Propósito Principal

Este proyecto tiene como objetivo **democratizar el entendimiento de la Inteligencia Artificial** mostrando cada componente del proceso de aprendizaje de manera transparente y visual:

- ✅ **Red Neuronal Feedforward** implementada manualmente (6 entradas → 8 neuronas ocultas → 3 salidas)
- ✅ **Algoritmo Genético** con selección por ruleta, cruce uniforme y mutación gaussiana
- ✅ **Aprendizaje Evolutivo** donde la IA mejora generación tras generación
- ✅ **Visualización en tiempo real** de la arquitectura neuronal y decisiones de la IA

### 🌟 ¿Por Qué Este Proyecto?

| Característica | Beneficio |
|---------------|-----------|
| **Sin librerías ML** | Todo el código de IA está escrito desde cero |
| **Visualización gráfica** | Puedes ver cómo la red neuronal toma decisiones |
| **Código educativo** | Comentarios detallados en cada módulo |
| **Processing 4** | Fácil de ejecutar y modificar |

---

## 📁 Estructura de Carpetas y Archivos

```
IAdesdeCero/
├── CarrerasRL.pde           # 🎮 Punto de entrada principal (setup & draw)
├── RedNeuronal.pde          # 🧠 Implementación de la red neuronal
├── AlgoritmoGenetico.pde    # 🧬 Motor evolutivo (selección, cruce, mutación)
├── Simulacion.pde           # 🎯 Orquestador del juego y generaciones
├── CocheJugador.pde         # 🚗 Agente IA con su propia red neuronal
├── Obstaculo.pde            # 🚧 Obstáculos (coches enemigos y conos)
├── GeneradorSprites.pde     # 🎨 Generador de assets gráficos
└── data/                    # 📦 Sprites generados automáticamente
    ├── coche_jugador.png
    ├── coche_enemigo.png
    └── cono.png
```

## 🔑 Palabras Clave (Topics)

Para optimizar la descubribilidad del repositorio, se recomiendan los siguientes **topics**:

```
processing, artificial-intelligence, neural-networks, genetic-algorithms, 
machine-learning, reinforcement-learning, evolutionary-algorithms, 
deep-learning-from-scratch, ai-visualization, educational-project, 
java-mode, autonomous-agents, neuroevolution, ai-simulation
```

## 🚀 Instrucciones de Uso

### 1️⃣ Instalación de Processing

#### Paso 1: Descargar Processing
1. Visita el sitio oficial: [https://processing.org/download](https://processing.org/download)
2. Descarga la versión **Processing 4.x** más reciente
3. Descomprime el archivo en una carpeta de tu preferencia

#### Paso 2: Configurar el Modo Java
```
Processing → Sketch → Export Application → Asegúrate de usar Java Mode
```

#### Paso 3: Verificar Instalación
```java
// Crea un nuevo sketch y ejecuta este código de prueba:
void setup() {
  size(400, 400);
  background(255);
  println("Processing instalado correctamente!");
}
```

### 2️⃣ Clonar el Repositorio

```bash
# Usando Git
git clone https://github.com/0vethor0/IAdesdeCero.git

# Navegar al directorio
cd IAdesdeCero

# Abrir en Processing
# (Arrastra CarrerasRL.pde a Processing o usa File → Open)
```

### 3️⃣ Ejecutar la Simulación

| Acción | Tecla | Descripción |
|--------|-------|-------------|
| **Reiniciar** | `R` | Reinicia la simulación completa |
| **Aumentar velocidad** | `+` | Incrementa FPS (máx 120) |
| **Disminuir velocidad** | `-` | Reduce FPS (mín 10) |

```bash
# Pasos para ejecutar:
1. Abre Processing 4.x
2. File → Open → Selecciona CarrerasRL.pde
3. Presiona el botón ▶ (Run)
4. ¡Observa cómo la IA aprende!
```

---

## 🧠 Entendiendo el Aprendizaje de la IA

### Arquitectura de la Red Neuronal

```
┌─────────────────────────────────────────────────────────┐
│                    ARQUITECTURA DE RED                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   ENTRADAS (6)    →    OCULTAS (8)    →    SALIDAS (3) │
│   ───────────         ───────────         ───────────   │
│   • Carril actual       • 8 neuronas        • Izquierda │
│   • Distancia Obs1      • Activación tanh   • Derecha   │
│   • Carril Obs1         • Pesos ajustables  • Recto     │
│   • Tipo Obs1           • Sesgos            │
│   • Distancia Obs2      │
│   • Velocidad juego     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 📊 Vector de Entradas (Inputs)

| Índice | Variable | Rango | Descripción |
|--------|----------|-------|-------------|
| 0 | `carrilActual` | [0, 1] | Carril donde está el coche (0=izq, 1=der) |
| 1 | `distanciaObs1` | [0, 1] | Distancia normalizada al obstáculo más cercano |
| 2 | `carrilObs1` | [0, 1] | Carril del obstáculo más cercano |
| 3 | `tipoObs1` | [0, 1] | Tipo de obstáculo (0=coche, 1=cono) |
| 4 | `distanciaObs2` | [0, 1] | Distancia al segundo obstáculo |
| 5 | `velocidad` | [0, 1] | Velocidad actual del juego normalizada |

### 🎯 Vector de Salidas (Actions)

| Índice | Acción | Descripción |
|--------|--------|-------------|
| 0 | `Izquierda` | Cambiar al carril izquierdo |
| 1 | `Derecha` | Cambiar al carril derecho |
| 2 | `Recto` | Mantenerse en el carril actual |

### 🧬 Proceso Evolutivo

```
GENERACIÓN N                          GENERACIÓN N+1
┌─────────────────┐                  ┌─────────────────┐
│  10 Coches IA   │                  │  10 Coches IA   │
│  (RedesRandom)  │───Fitness───────▶│  (RedesEvoluc.) │
└─────────────────┘                  └─────────────────┘
        │                                    ▲
        │  1. Evaluar puntuación             │
        │  2. Seleccionar mejores            │
        │  3. Cruzar genes (pesos)           │
        │  4. Mutar aleatoriamente           │
        └────────────────────────────────────┘
```

### 📈 Parámetros del Algoritmo Genético

| Parámetro | Valor | Propósito |
|-----------|-------|-----------|
| `tamañoPoblación` | 10 | Número de agentes por generación |
| `tasaMutación` | 10% | Probabilidad de mutar cada peso |
| `fuerzaMutación` | 0.20 | Magnitud del cambio en mutación |
| `élite` | 2 | Mejores individuos que pasan sin cambios |

### 🔍 Cómo Interpretar los Datos de Aprendizaje

#### HUD Izquierdo (Estadísticas)

```
▶ CARRERAS RL
─────────────────
Generación:    15        ← Generación actual
Vivos:         3 / 10    ← Coches aún en juego
Score:         2847      ← Puntuación actual
Mejor (gen):   3120.5    ← Mejor score de esta generación
Promedio:      1856.3    ← Score promedio de la generación
Vel:           12.4 px/f ← Velocidad del juego
```

#### Panel Derecho (Red Neuronal)

| Elemento Visual | Significado |
|-----------------|-------------|
| 🔵 **Línea azul** | Peso positivo (excitatorio) |
| 🔴 **Línea roja** | Peso negativo (inhibitorio) |
| 🟢 **Nodo verde** | Acción seleccionada por la IA |
| **Intensidad** | Magnitud del peso/conexión |

#### Señales de que la IA Está Aprendiendo

✅ **Indicadores de Progreso:**
- El **score máximo** aumenta entre generaciones
- Los coches **sobreviven más tiempo** en promedio
- La IA **esquiva obstáculos** de manera consistente
- Los **pesos de la red** se estabilizan

⚠️ **Indicadores de Problemas:**
- El score se estanca por muchas generaciones
- Todos los coches mueren rápidamente
- Comportamiento errático sin mejora

---

## 🛠️ Personalización y Experimentación

### Modificar Parámetros de la IA

```java
// En AlgoritmoGenetico.pde
float tasaMutacion   = 0.10;  // Aumentar para más exploración
float fuerzaMutacion = 0.20;  // Aumentar para cambios más drásticos

// En Simulacion.pde
int tamanioPoblacion = 10;    // Más agentes = más diversidad genética
```

### Cambiar la Arquitectura Neural

```java
// En RedNeuronal.pde
int cantEntradas = 6;   // Añadir más sensores
int cantOcultas  = 8;   // Más neuronas = más capacidad
int cantSalidas  = 3;   // Más acciones posibles
```

### Ajustar Dificultad del Juego

```java
// En Simulacion.pde
float velocidadMaxima     = 18.0;  // Velocidad máxima del juego
float incrementoVelocidad = 0.0008; // Cuánto acelera con el tiempo
float probabilidadCono    = 0.25;  // % de obstáculos que son conos
```

---

## 📚 Recursos de Aprendizaje

| Tema | Recurso Recomendado |
|------|---------------------|
| Redes Neuronales | [3Blue1Brown - Neural Networks](https://www.3blue1brown.com/topics/neural-networks) |
| Algoritmos Genéticos | [Nature of Code - Genetic Algorithms](https://natureofcode.com/genetic-algorithms/) |
| Processing | [Processing.org Tutorials](https://processing.org/tutorials/) |
| Neuroevolución | [NEAT Algorithm Paper](http://nn.cs.utexas.edu/?neat) |

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para contribuir:

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/NuevaCaracteristica`)
3. Commit tus cambios (`git commit -m 'Añadir nueva característica'`)
4. Push a la rama (`git push origin feature/NuevaCaracteristica`)
5. Abre un Pull Request

---


## 🙏 Agradecimientos

- **Processing Foundation** — Por la plataforma de creative coding
- **Comunidad de IA** — Por inspirar proyectos educativos open source
- **Contribuidores** — Por mantener vivo el aprendizaje accesible

---

<div align="center">

**¿Te gustó este proyecto?** ⭐ Dale una estrella en GitHub

**¿Tienes preguntas?** 📩 Abre un issue en el repositorio

---

*Hecho con ❤️ para democratizar el aprendizaje de Inteligencia Artificial*

</div>
