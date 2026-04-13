// ============================================================
//  CocheJugador.pde  —  Coche controlado por la IA
//  Snap instantáneo entre carril izquierdo y derecho
//  Lleva su propia RedNeuronal y acumula puntaje (fitness)
// ============================================================

class CocheJugador {

  // Posición y dimensiones
  float x, y;
  float ancho = 36;
  float alto  = 60;

  // Carril actual (0 = izquierdo, 1 = derecho)
  int carrilActual = 0;

  // Estado
  boolean vivo        = true;
  float   puntaje     = 0;
  float   tiempoVivo  = 0;   // frames sobrevividos

  // Red neuronal de este coche
  RedNeuronal cerebro;

  // Últimas entradas usadas (para visualizar la red)
  float[] ultimasEntradas = new float[6];

  // Animación de cambio de carril
  float xObjetivo;
  float velocidadLateral = 12; // px por frame al cambiar carril

  // Colores del coche (amarillo taxi)
  color colorCarroceria = color(255, 210, 0);
  color colorVentana    = color(50, 100, 180, 200);
  color colorRueda      = color(20, 20, 20);
  color colorFaro       = color(255, 255, 180);

  // Sprite (si existe como imagen cargada)
  PImage spriteImagen = null;

  // ──────────────────────────────────────────
  //  Constructor
  // ──────────────────────────────────────────
  CocheJugador(float xInicial, float yInicial, RedNeuronal cerebro) {
    this.x       = xInicial;
    this.y       = yInicial;
    this.cerebro = cerebro;
    this.xObjetivo = xInicial;

    // Intentar cargar sprite
    try {
      spriteImagen = loadImage("coche_jugador.png");
    } catch (Exception e) {
      spriteImagen = null;
    }
  }

  // ──────────────────────────────────────────
  //  Actualizar lógica del coche
  //  infoObstaculos: array con datos del entorno
  //  velocidadJuego: velocidad global del scroll
  // ──────────────────────────────────────────
  void actualizar(float[] infoObstaculos, float velocidadJuego, Carretera carretera) {
    if (!vivo) return;

    // Construir entradas normalizadas para la red neuronal
    construirEntradas(infoObstaculos, velocidadJuego, carretera);

    // Consultar a la red qué acción tomar
    int accion = cerebro.decidirAccion(ultimasEntradas);

    // Ejecutar acción: 0 = izquierda, 1 = derecha, 2 = recto
    if (accion == 0 && carrilActual != 0) {
      carrilActual = 0;
      xObjetivo = carretera.obtenerXCarril(0);
    } else if (accion == 1 && carrilActual != 1) {
      carrilActual = 1;
      xObjetivo = carretera.obtenerXCarril(1);
    }

    // Animación suave de movimiento lateral
    if (abs(x - xObjetivo) > 1) {
      x += (xObjetivo - x) * 0.25;
    } else {
      x = xObjetivo;
    }

    // Acumular puntaje por tiempo sobrevivido
    tiempoVivo++;
    puntaje = tiempoVivo + (velocidadJuego * 0.5);
  }

  // ──────────────────────────────────────────
  //  Construir vector de 6 entradas normalizado
  //  para la red neuronal
  // ──────────────────────────────────────────
  void construirEntradas(float[] infoObstaculos, float velocidadJuego, Carretera carretera) {
    // Entrada 0: carril actual normalizado [0,1]
    ultimasEntradas[0] = carrilActual;

    // Entradas 1-3: info del obstáculo más próximo
    // infoObstaculos[0] = distancia Y al obstáculo más próximo (normalizada)
    // infoObstaculos[1] = carril del obstáculo más próximo (0 o 1)
    // infoObstaculos[2] = tipo: 0=coche enemigo, 1=cono
    // infoObstaculos[3] = distancia Y al 2do obstáculo (normalizada)
    ultimasEntradas[1] = infoObstaculos[0]; // distancia 1
    ultimasEntradas[2] = infoObstaculos[1]; // carril obst. 1
    ultimasEntradas[3] = infoObstaculos[2]; // tipo obst. 1
    ultimasEntradas[4] = infoObstaculos[3]; // distancia 2

    // Entrada 5: velocidad actual normalizada [0,1]
    ultimasEntradas[5] = constrain((velocidadJuego - 3) / 12.0, 0, 1);
  }

  // ──────────────────────────────────────────
  //  Detectar colisión con un obstáculo (AABB)
  // ──────────────────────────────────────────
  boolean estaColisionandoCon(Obstaculo obstaculo) {
    float margen = 6; // margen de tolerancia para mejor jugabilidad
    return (x - ancho / 2 + margen < obstaculo.x + obstaculo.ancho / 2 &&
            x + ancho / 2 - margen > obstaculo.x - obstaculo.ancho / 2 &&
            y - alto / 2 + margen < obstaculo.y + obstaculo.alto / 2 &&
            y + alto / 2 - margen > obstaculo.y - obstaculo.alto / 2);
  }

  // ──────────────────────────────────────────
  //  Morir (registra el puntaje final)
  // ──────────────────────────────────────────
  void morir() {
    vivo = false;
  }

  // ──────────────────────────────────────────
  //  Dibujar el coche
  // ──────────────────────────────────────────
  void dibujar(boolean esMejor) {
    if (!vivo) return;

    pushMatrix();
    translate(x, y);

    if (spriteImagen != null && spriteImagen.width > 0) {
      // Usar sprite si está disponible
      imageMode(CENTER);
      image(spriteImagen, 0, 0, ancho, alto);
    } else {
      // Dibujo procedural del coche amarillo
      dibujarCocheProcedural(esMejor);
    }

    popMatrix();

    // Resaltar el mejor coche con un halo
    if (esMejor) {
      noFill();
      stroke(255, 255, 0, 120);
      strokeWeight(2);
      ellipse(x, y, ancho + 10, alto + 10);
      strokeWeight(1);
    }
  }

  void dibujarCocheProcedural(boolean esMejor) {
    float a = ancho;
    float al = alto;

    // Sombra debajo del coche
    noStroke();
    fill(0, 0, 0, 60);
    ellipse(2, 4, a * 0.8, al * 0.3);

    // Carrocería principal
    noStroke();
    fill(esMejor ? colorCarroceria : color(200, 170, 0));
    rect(-a/2, -al/2, a, al, 6);

    // Capó delantero (parte superior = frente del coche, Y negativo)
    fill(esMejor ? color(240, 190, 0) : color(180, 150, 0));
    rect(-a/2 + 3, -al/2, a - 6, al * 0.25, 6, 6, 0, 0);

    // Maletero trasero
    fill(esMejor ? color(220, 170, 0) : color(160, 130, 0));
    rect(-a/2 + 3, al/2 - al * 0.18, a - 6, al * 0.18, 0, 0, 6, 6);

    // Ventana delantera
    fill(colorVentana);
    rect(-a/2 + 5, -al/2 + al * 0.08, a - 10, al * 0.2, 3);

    // Ventana trasera
    fill(colorVentana);
    rect(-a/2 + 5, al/2 - al * 0.32, a - 10, al * 0.18, 3);

    // Ventanas laterales
    fill(colorVentana);
    rect(-a/2 + 5, -al/2 + al * 0.32, a - 10, al * 0.24, 2);

    // Faros delanteros
    fill(colorFaro);
    ellipse(-a/2 + 6, -al/2 + 5, 8, 5);
    ellipse( a/2 - 6, -al/2 + 5, 8, 5);

    // Faros traseros
    fill(200, 50, 50);
    ellipse(-a/2 + 6, al/2 - 5, 8, 5);
    ellipse( a/2 - 6, al/2 - 5, 8, 5);

    // Ruedas (4 esquinas)
    fill(colorRueda);
    rect(-a/2 - 4, -al/2 + 6,  8, 14, 2);   // delantera izq
    rect( a/2 - 4, -al/2 + 6,  8, 14, 2);   // delantera der
    rect(-a/2 - 4,  al/2 - 20, 8, 14, 2);   // trasera izq
    rect( a/2 - 4,  al/2 - 20, 8, 14, 2);   // trasera der

    // Logo "CRAZY" en el techo (solo el mejor)
    if (esMejor) {
      fill(0);
      textSize(7);
      textAlign(CENTER, CENTER);
      text("CRAZY", 0, -2);
    }
  }
}
