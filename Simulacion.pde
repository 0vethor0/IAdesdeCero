// ============================================================
//  Simulacion.pde  —  Orquestador principal del juego
//  Gestiona: población IA, obstáculos, colisiones AABB,
//  generaciones evolutivas y todo el HUD en pantalla
// ============================================================

class Simulacion {

  // Motor del juego
  Carretera         carretera;
  ArrayList<Obstaculo> obstaculos;

  // Población de coches IA
  int              tamanioPoblacion;
  CocheJugador[]   cochesIA;
  RedNeuronal[]    redesNeuronales;
  AlgoritmoGenetico algoritmoGenetico;

  // Estado de la simulación
  float velocidadJuego      = 3.5;
  float velocidadMaxima     = 18.0;
  float incrementoVelocidad = 0.0008;
  int   puntajeActual       = 0;
  int   cochesVivos         = 0;

  // Datos inter-generacionales
  int   generacion          = 1;
  float mejorPuntajeUltimaGen   = 0;
  float promedioPuntajeUltimaGen = 0;
  float mejorFitnessHistorico   = 0;
  int   indiceMejorCoche        = 0;

  // Spawn de obstáculos
  float tiempoDesdeUltimoSpawn = 0;
  float tiempoEntreSpawns      = 90;   // frames entre spawns
  float tiempoEntreSpawnsMin   = 38;
  float tiempoEntreSpawnsMax   = 110;
  float probabilidadCono       = 0.25; // 25% de probabilidad de cono

  // ──────────────────────────────────────────
  //  Constructor: inicializa todo
  // ──────────────────────────────────────────
  Simulacion(int tamanioPoblacion) {
    this.tamanioPoblacion = tamanioPoblacion;

    carretera          = new Carretera();
    obstaculos         = new ArrayList<Obstaculo>();
    algoritmoGenetico  = new AlgoritmoGenetico(tamanioPoblacion);

    // Crear la primera generación con redes aleatorias
    redesNeuronales = new RedNeuronal[tamanioPoblacion];
    for (int i = 0; i < tamanioPoblacion; i++)
      redesNeuronales[i] = new RedNeuronal();

    inicializarCoches();
  }

  // ──────────────────────────────────────────
  //  Inicializar/reinicializar los coches
  //  con las redes neuronales actuales
  // ──────────────────────────────────────────
  void inicializarCoches() {
    cochesIA = new CocheJugador[tamanioPoblacion];
    for (int i = 0; i < tamanioPoblacion; i++) {
      float xInicial = carretera.obtenerXCarril(i % 2);
      cochesIA[i] = new CocheJugador(xInicial, height * 0.7, redesNeuronales[i]);
      cochesIA[i].carrilActual = i % 2;
      cochesIA[i].xObjetivo    = xInicial;
    }

    // Reiniciar parámetros del juego para nueva generación
    obstaculos.clear();
    velocidadJuego              = 3.5;
    puntajeActual               = 0;
    tiempoDesdeUltimoSpawn      = 0;
    cochesVivos                 = tamanioPoblacion;
    tiempoEntreSpawns           = tiempoEntreSpawnsMax;
  }

  // ──────────────────────────────────────────
  //  Actualizar todo el estado del juego
  // ──────────────────────────────────────────
  void actualizar() {
    if (cochesVivos == 0) {
      siguienteGeneracion();
      return;
    }

    // Actualizar velocidad (aumenta progresivamente)
    velocidadJuego = min(velocidadJuego + incrementoVelocidad, velocidadMaxima);

    // Reducir tiempo entre spawns al aumentar la velocidad
    float progreso = (velocidadJuego - 3.5) / (velocidadMaxima - 3.5);
    tiempoEntreSpawns = lerp(tiempoEntreSpawnsMax, tiempoEntreSpawnsMin, progreso);

    // Actualizar carretera
    carretera.actualizar(velocidadJuego);

    // Actualizar score global
    puntajeActual++;

    // Generar nuevos obstáculos
    tiempoDesdeUltimoSpawn++;
    if (tiempoDesdeUltimoSpawn >= tiempoEntreSpawns) {
      generarObstaculo();
      tiempoDesdeUltimoSpawn = 0;
    }

    // Actualizar obstáculos y eliminar los que salieron de pantalla
    for (int i = obstaculos.size() - 1; i >= 0; i--) {
      Obstaculo obs = obstaculos.get(i);
      obs.actualizar(velocidadJuego);
      if (obs.fueraDePantalla) obstaculos.remove(i);
    }

    // Construir info del entorno para cada coche
    cochesVivos = 0;
    for (int i = 0; i < tamanioPoblacion; i++) {
      if (!cochesIA[i].vivo) continue;

      float[] infoEntorno = construirInfoEntorno(cochesIA[i]);
      cochesIA[i].actualizar(infoEntorno, velocidadJuego, carretera);

      // Verificar colisiones
      for (Obstaculo obs : obstaculos) {
        if (cochesIA[i].estaColisionandoCon(obs)) {
          cochesIA[i].morir();
          break;
        }
      }

      if (cochesIA[i].vivo) cochesVivos++;
    }

    // Encontrar índice del mejor coche vivo
    indiceMejorCoche = encontrarMejorCocheVivo();
  }

  // ──────────────────────────────────────────
  //  Construir vector de información del entorno
  //  para un coche específico
  //  Retorna: [distObst1, carrilObst1, tipoObst1, distObst2, ...]
  // ──────────────────────────────────────────
  float[] construirInfoEntorno(CocheJugador coche) {
    float[] info = {1.0, 0.5, 0.0, 1.0}; // valores por defecto = sin obstáculos

    // Buscar los dos obstáculos más próximos por encima del coche
    Obstaculo primerObstaculo  = null;
    Obstaculo segundoObstaculo = null;
    float distanciaPrimero     = Float.MAX_VALUE;
    float distanciaSegundo     = Float.MAX_VALUE;

    for (Obstaculo obs : obstaculos) {
      // Solo considerar obstáculos que están más arriba (menor Y)
      if (obs.y < coche.y) {
        float dist = coche.y - obs.y;
        if (dist < distanciaPrimero) {
          distanciaSegundo     = distanciaPrimero;
          segundoObstaculo     = primerObstaculo;
          distanciaPrimero     = dist;
          primerObstaculo      = obs;
        } else if (dist < distanciaSegundo) {
          distanciaSegundo     = dist;
          segundoObstaculo     = obs;
        }
      }
    }

    float rangoDeteccion = height * 1.2;

    if (primerObstaculo != null) {
      info[0] = constrain(distanciaPrimero / rangoDeteccion, 0, 1); // distancia normalizada
      info[1] = primerObstaculo.carril;                              // carril (0 o 1)
      info[2] = primerObstaculo.tipo;                                // tipo (0=coche, 1=cono)
    }
    if (segundoObstaculo != null) {
      info[3] = constrain(distanciaSegundo / rangoDeteccion, 0, 1);
    }

    return info;
  }

  // ──────────────────────────────────────────
  //  Generar un nuevo obstáculo en la parte
  //  superior de la pantalla (fuera de vista)
  // ──────────────────────────────────────────
  void generarObstaculo() {
    int carrilElegido = int(random(2)); // 0 = izquierdo, 1 = derecho
    float xCarril     = carretera.obtenerXCarril(carrilElegido);
    int tipoElegido   = (random(1) < probabilidadCono) ? TIPO_CONO : TIPO_COCHE;
    obstaculos.add(new Obstaculo(tipoElegido, carrilElegido, xCarril));
  }

  // ──────────────────────────────────────────
  //  Encontrar el índice del mejor coche vivo
  // ──────────────────────────────────────────
  int encontrarMejorCocheVivo() {
    int mejorIndice    = 0;
    float mejorPuntaje = -1;
    for (int i = 0; i < tamanioPoblacion; i++) {
      if (cochesIA[i].vivo && cochesIA[i].puntaje > mejorPuntaje) {
        mejorPuntaje = cochesIA[i].puntaje;
        mejorIndice  = i;
      }
    }
    return mejorIndice;
  }

  // ──────────────────────────────────────────
  //  Evolucionar a la siguiente generación
  // ──────────────────────────────────────────
  void siguienteGeneracion() {
    // Recolectar puntajes como fitness
    float[] puntajes = new float[tamanioPoblacion];
    float sumaPuntajes = 0;
    float mejorPuntaje = 0;

    for (int i = 0; i < tamanioPoblacion; i++) {
      puntajes[i] = cochesIA[i].puntaje;
      sumaPuntajes += puntajes[i];
      if (puntajes[i] > mejorPuntaje) mejorPuntaje = puntajes[i];
    }

    // Guardar estadísticas para el HUD
    mejorPuntajeUltimaGen    = mejorPuntaje;
    promedioPuntajeUltimaGen = sumaPuntajes / tamanioPoblacion;

    // Ajustar fuerza de mutación según si hubo mejora
    algoritmoGenetico.ajustarMutacion(mejorPuntaje, mejorFitnessHistorico);

    if (mejorPuntaje > mejorFitnessHistorico)
      mejorFitnessHistorico = mejorPuntaje;

    // Evolucionar población
    redesNeuronales = algoritmoGenetico.evolucionarPoblacion(redesNeuronales, puntajes);

    generacion++;
    inicializarCoches();
  }

  // ──────────────────────────────────────────
  //  Dibujar todo: juego + HUD
  // ──────────────────────────────────────────
  void dibujar() {
    background(0);

    carretera.dibujar();

    // Dibujar obstáculos
    for (Obstaculo obs : obstaculos) obs.dibujar();

    // Dibujar coches (el mejor encima de todos)
    for (int i = 0; i < tamanioPoblacion; i++) {
      if (cochesIA[i].vivo && i != indiceMejorCoche)
        cochesIA[i].dibujar(false);
    }
    // El mejor siempre al frente
    if (cochesIA[indiceMejorCoche].vivo)
      cochesIA[indiceMejorCoche].dibujar(true);

    // Dibujar HUD informativo
    dibujarHUD();

    // Dibujar visualización de la red neuronal
    dibujarVisualizacionRed();
  }

  // ──────────────────────────────────────────
  //  HUD: panel informativo izquierdo
  // ──────────────────────────────────────────
  void dibujarHUD() {
    // Fondo semitransparente del panel
    int xPanel = 5;
    int yPanel = 5;
    int wPanel = 170;
    int hPanel = 185;

    fill(0, 0, 0, 160);
    noStroke();
    rect(xPanel, yPanel, wPanel, hPanel, 6);

    // Título
    fill(255, 210, 0);
    textSize(13);
    textAlign(LEFT);
    text("▶ CARRERAS RL", xPanel + 10, yPanel + 22);

    // Línea separadora
    stroke(100, 100, 100, 150);
    line(xPanel + 8, yPanel + 28, xPanel + wPanel - 8, yPanel + 28);
    noStroke();

    // Datos de la generación
    int xTexto = xPanel + 10;
    int yBase  = yPanel + 46;
    int espacioLinea = 22;

    dibujarLineaHUD("Generación:",   str(generacion),                          xTexto, yBase,                color(180, 180, 255));
    dibujarLineaHUD("Vivos:",        cochesVivos + " / " + tamanioPoblacion,   xTexto, yBase + espacioLinea,  color(100, 220, 100));
    dibujarLineaHUD("Score:",        nf(puntajeActual, 0),                     xTexto, yBase + espacioLinea*2, color(255, 255, 255));
    dibujarLineaHUD("Mejor (gen):",  nf(mejorPuntajeUltimaGen, 0, 1),         xTexto, yBase + espacioLinea*3, color(255, 180, 50));
    dibujarLineaHUD("Promedio:",     nf(promedioPuntajeUltimaGen, 0, 1),      xTexto, yBase + espacioLinea*4, color(200, 200, 200));
    dibujarLineaHUD("Vel:",          nf(velocidadJuego, 0, 1) + " px/f",      xTexto, yBase + espacioLinea*5, color(150, 220, 255));

    // Instrucciones en la parte inferior
    fill(120, 120, 120);
    textSize(9);
    text("R=reiniciar  +/-=velocidad", xPanel + 8, yPanel + hPanel - 8);
  }

  void dibujarLineaHUD(String etiqueta, String valor, int x, int y, color colorValor) {
    textAlign(LEFT);
    textSize(11);
    fill(160, 160, 160);
    text(etiqueta, x, y);
    fill(colorValor);
    textAlign(RIGHT);
    text(valor, x + 150, y);
    textAlign(LEFT);
  }

  // ──────────────────────────────────────────
  //  Visualización de la red neuronal del mejor
  //  coche en el panel inferior derecho
  // ──────────────────────────────────────────
  void dibujarVisualizacionRed() {
    int wPanel = 280;
    int hPanel = 260;
    int xPanel = width - wPanel - 5;
    int yPanel = height - hPanel - 5;

    // Fondo del panel
    fill(0, 0, 0, 170);
    noStroke();
    rect(xPanel, yPanel, wPanel, hPanel, 6);

    // Título
    fill(255, 210, 0);
    textSize(12);
    textAlign(LEFT);
    text("Red neuronal (mejor)", xPanel + 10, yPanel + 18);

    // Subtítulo: arquitectura
    fill(120, 120, 120);
    textSize(10);
    text("6 entradas → 8 ocultas → 3 salidas", xPanel + 10, yPanel + 32);

    // Línea separadora
    stroke(100, 100, 100, 150);
    line(xPanel + 6, yPanel + 38, xPanel + wPanel - 6, yPanel + 38);
    noStroke();

    // Dibujar la red del mejor coche vivo
    if (cochesIA[indiceMejorCoche].vivo) {
      RedNeuronal redMejor = cochesIA[indiceMejorCoche].cerebro;
      float[] ultimasEntradas = cochesIA[indiceMejorCoche].ultimasEntradas;
      redMejor.dibujarRed(xPanel + 4, yPanel + 42, wPanel - 8, hPanel - 58, ultimasEntradas);
    }

    // Leyenda en la parte baja del panel
    int yLeyenda = yPanel + hPanel - 14;
    fill(50, 220, 100);  textSize(10); textAlign(LEFT);
    text("● acción elegida", xPanel + 10, yLeyenda);
    fill(100, 180, 255); textSize(10);
    text("— peso positivo", xPanel + 115, yLeyenda);
    fill(255, 100, 100);
    text("— negativo", xPanel + 210, yLeyenda);
  }
}
