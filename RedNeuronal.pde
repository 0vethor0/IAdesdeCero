// ============================================================
//  RedNeuronal.pde  —  Red neuronal feedforward desde cero
//  Arquitectura: 6 entradas → 8 neuronas ocultas → 3 salidas
//  Activación: tanh en capa oculta, softmax en salida
//  Sin librerías externas — todo implementado manualmente
// ============================================================

class RedNeuronal {

  // Dimensiones de la red
  int cantEntradas   = 6;
  int cantOcultas    = 8;
  int cantSalidas    = 3;

  // Pesos y sesgos entre capas
  // pesosEntradaOculta[i][j] = peso de entrada i a neurona oculta j
  float[][] pesosEntradaOculta;
  float[]   sesgosOculta;

  // pesosOcultaSalida[i][j] = peso de neurona oculta i a salida j
  float[][] pesosOcultaSalida;
  float[]   sesgosSalida;

  // ──────────────────────────────────────────
  //  Constructor: inicializa pesos aleatorios
  // ──────────────────────────────────────────
  RedNeuronal() {
    pesosEntradaOculta = new float[cantEntradas][cantOcultas];
    sesgosOculta       = new float[cantOcultas];
    pesosOcultaSalida  = new float[cantOcultas][cantSalidas];
    sesgosSalida       = new float[cantSalidas];
    inicializarAleatorio();
  }

  // Constructor copia: clona los pesos de otra red
  RedNeuronal(RedNeuronal origen) {
    pesosEntradaOculta = new float[cantEntradas][cantOcultas];
    sesgosOculta       = new float[cantOcultas];
    pesosOcultaSalida  = new float[cantOcultas][cantSalidas];
    sesgosSalida       = new float[cantSalidas];
    copiarPesos(origen);
  }

  // ──────────────────────────────────────────
  //  Inicialización Xavier (mejora convergencia)
  // ──────────────────────────────────────────
  void inicializarAleatorio() {
    float escalaEntOculta = sqrt(2.0 / (cantEntradas + cantOcultas));
    float escalaOcuSal    = sqrt(2.0 / (cantOcultas  + cantSalidas));

    for (int i = 0; i < cantEntradas; i++)
      for (int j = 0; j < cantOcultas; j++)
        pesosEntradaOculta[i][j] = randomGaussiano() * escalaEntOculta;

    for (int j = 0; j < cantOcultas; j++)
      sesgosOculta[j] = 0;

    for (int j = 0; j < cantOcultas; j++)
      for (int k = 0; k < cantSalidas; k++)
        pesosOcultaSalida[j][k] = randomGaussiano() * escalaOcuSal;

    for (int k = 0; k < cantSalidas; k++)
      sesgosSalida[k] = 0;
  }

  // ──────────────────────────────────────────
  //  Propagación hacia adelante (forward pass)
  //  entradas: array de 6 valores normalizados [0,1]
  //  retorna:  índice de la acción con mayor activación
  //            0 = girar izquierda
  //            1 = girar derecha
  //            2 = seguir recto
  // ──────────────────────────────────────────
  int decidirAccion(float[] entradas) {
    // Capa oculta con activación tanh
    float[] activacionesOcultas = new float[cantOcultas];
    for (int j = 0; j < cantOcultas; j++) {
      float suma = sesgosOculta[j];
      for (int i = 0; i < cantEntradas; i++)
        suma += entradas[i] * pesosEntradaOculta[i][j];
      activacionesOcultas[j] = tanh(suma);
    }

    // Capa de salida
    float[] activacionesSalida = new float[cantSalidas];
    for (int k = 0; k < cantSalidas; k++) {
      float suma = sesgosSalida[k];
      for (int j = 0; j < cantOcultas; j++)
        suma += activacionesOcultas[j] * pesosOcultaSalida[j][k];
      activacionesSalida[k] = suma;
    }

    // Argmax: elegir la acción con mayor valor
    int mejorAccion = 0;
    for (int k = 1; k < cantSalidas; k++)
      if (activacionesSalida[k] > activacionesSalida[mejorAccion])
        mejorAccion = k;

    return mejorAccion;
  }

  // Versión que retorna todos los valores de salida (para visualizar la red)
  float[] obtenerSalidas(float[] entradas) {
    float[] activacionesOcultas = new float[cantOcultas];
    for (int j = 0; j < cantOcultas; j++) {
      float suma = sesgosOculta[j];
      for (int i = 0; i < cantEntradas; i++)
        suma += entradas[i] * pesosEntradaOculta[i][j];
      activacionesOcultas[j] = tanh(suma);
    }
    float[] activacionesSalida = new float[cantSalidas];
    for (int k = 0; k < cantSalidas; k++) {
      float suma = sesgosSalida[k];
      for (int j = 0; j < cantOcultas; j++)
        suma += activacionesOcultas[j] * pesosOcultaSalida[j][k];
      activacionesSalida[k] = suma;
    }
    return activacionesSalida;
  }

  // ──────────────────────────────────────────
  //  Copia profunda de pesos desde otra red
  // ──────────────────────────────────────────
  void copiarPesos(RedNeuronal origen) {
    for (int i = 0; i < cantEntradas; i++)
      for (int j = 0; j < cantOcultas; j++)
        pesosEntradaOculta[i][j] = origen.pesosEntradaOculta[i][j];

    for (int j = 0; j < cantOcultas; j++)
      sesgosOculta[j] = origen.sesgosOculta[j];

    for (int j = 0; j < cantOcultas; j++)
      for (int k = 0; k < cantSalidas; k++)
        pesosOcultaSalida[j][k] = origen.pesosOcultaSalida[j][k];

    for (int k = 0; k < cantSalidas; k++)
      sesgosSalida[k] = origen.sesgosSalida[k];
  }

  // ──────────────────────────────────────────
  //  Utilidades matemáticas
  // ──────────────────────────────────────────
  float tanh(float x) {
    // Implementación manual de tanh usando la identidad
    float e2x = exp(2 * x);
    return (e2x - 1) / (e2x + 1);
  }

  float randomGaussiano() {
    // Box-Muller transform para distribución normal estándar
    float u1 = random(0.0001, 1);
    float u2 = random(0.0001, 1);
    return sqrt(-2 * log(u1)) * cos(TWO_PI * u2);
  }

  // ──────────────────────────────────────────
  //  Visualización de la red en pantalla
  //  Dibuja nodos y conexiones con colores
  //  según intensidad de los pesos
  // ──────────────────────────────────────────
  void dibujarRed(float xOrigen, float yOrigen, float anchoPanel, float altoPanel, float[] ultimasEntradas) {
    float margenV  = 20;
    float margenH  = 30;
    float anchoUtil = anchoPanel - 2 * margenH;
    float altoUtil  = altoPanel  - 2 * margenV;

    // Posiciones X de cada capa
    float xEntradas = xOrigen + margenH;
    float xOcultas  = xOrigen + margenH + anchoUtil * 0.45;
    float xSalidas  = xOrigen + margenH + anchoUtil * 0.90;

    float radioNodo = 6;

    // Calcular posiciones Y de cada capa
    float[] yEntradas = posicionesY(yOrigen + margenV, altoUtil, cantEntradas);
    float[] yOcultas  = posicionesY(yOrigen + margenV, altoUtil, cantOcultas);
    float[] ySalidas  = posicionesY(yOrigen + margenV + altoUtil * 0.2, altoUtil * 0.6, cantSalidas);

    // Obtener activaciones para colorear nodos
    float[] activacionesOcultas = new float[cantOcultas];
    float[] activacionesSalida  = new float[cantSalidas];
    if (ultimasEntradas != null) {
      activacionesSalida = obtenerSalidas(ultimasEntradas);
      for (int j = 0; j < cantOcultas; j++) {
        float suma = sesgosOculta[j];
        for (int i = 0; i < cantEntradas; i++)
          suma += ultimasEntradas[i] * pesosEntradaOculta[i][j];
        activacionesOcultas[j] = tanh(suma);
      }
    }

    strokeWeight(0.5);

    // Conexiones entrada → oculta
    for (int i = 0; i < cantEntradas; i++) {
      for (int j = 0; j < cantOcultas; j++) {
        float peso = pesosEntradaOculta[i][j];
        colorConexion(peso);
        line(xEntradas, yEntradas[i], xOcultas, yOcultas[j]);
      }
    }

    // Conexiones oculta → salida
    for (int j = 0; j < cantOcultas; j++) {
      for (int k = 0; k < cantSalidas; k++) {
        float peso = pesosOcultaSalida[j][k];
        colorConexion(peso);
        line(xOcultas, yOcultas[j], xSalidas, ySalidas[k]);
      }
    }

    strokeWeight(1);

    // Nodos de entrada
    String[] etiquetasEntradas = {"Carril", "Dist1", "Carril1", "Tipo1", "Dist2", "Veloc"};
    for (int i = 0; i < cantEntradas; i++) {
      float activacion = (ultimasEntradas != null) ? ultimasEntradas[i] : 0;
      dibujarNodo(xEntradas, yEntradas[i], radioNodo, activacion, etiquetasEntradas[i], true);
    }

    // Nodos ocultos
    for (int j = 0; j < cantOcultas; j++)
      dibujarNodo(xOcultas, yOcultas[j], radioNodo, activacionesOcultas[j], "", false);

    // Nodos de salida
    String[] etiquetasSalidas = {"Izq", "Der", "Recto"};
    int mejorSalida = 0;
    for (int k = 1; k < cantSalidas; k++)
      if (activacionesSalida[k] > activacionesSalida[mejorSalida]) mejorSalida = k;

    for (int k = 0; k < cantSalidas; k++) {
      color colorSalida = (k == mejorSalida) ? color(50, 220, 100) : color(180, 180, 180);
      fill(colorSalida);
      stroke(255);
      ellipse(xSalidas, ySalidas[k], radioNodo * 2.5, radioNodo * 2.5);
      fill(255);
      textSize(9);
      textAlign(LEFT);
      text(etiquetasSalidas[k], xSalidas + radioNodo * 1.5, ySalidas[k] + 3);
    }
  }

  void colorConexion(float peso) {
    float intensidad = constrain(abs(peso) / 2.0, 0, 1);
    if (peso > 0)
      stroke(100, 180, 255, intensidad * 180);
    else
      stroke(255, 100, 100, intensidad * 180);
  }

  void dibujarNodo(float x, float y, float radio, float activacion, String etiqueta, boolean mostrarEtiqueta) {
    float t = (activacion + 1) / 2.0; // normalizar de [-1,1] a [0,1]
    t = constrain(t, 0, 1);
    color col = lerpColor(color(40, 40, 80), color(80, 200, 255), t);
    fill(col);
    stroke(255, 255, 255, 150);
    ellipse(x, y, radio * 2, radio * 2);
    if (mostrarEtiqueta && etiqueta.length() > 0) {
      fill(200, 200, 200);
      textSize(8);
      textAlign(RIGHT);
      text(etiqueta, x - radio - 2, y + 3);
    }
  }

  float[] posicionesY(float yInicio, float altoDisponible, int cantidad) {
    float[] posiciones = new float[cantidad];
    float separacion = altoDisponible / (cantidad + 1);
    for (int i = 0; i < cantidad; i++)
      posiciones[i] = yInicio + separacion * (i + 1);
    return posiciones;
  }
}
