// ============================================================
//  Obstaculo.pde  —  Obstáculos en la carretera
//  Tipos: COCHE_ENEMIGO (se mueven) y CONO (más lento)
//  Se generan fuera de pantalla (arriba) y bajan con el scroll
// ============================================================

// Constantes de tipo de obstáculo
final int TIPO_COCHE  = 0;
final int TIPO_CONO   = 1;

class Obstaculo {

  float x, y;
  float ancho, alto;
  int   tipo;           // TIPO_COCHE o TIPO_CONO
  int   carril;         // 0 = izquierdo, 1 = derecho
  boolean fueraDePantalla = false;

  // Variante visual del coche enemigo (0=rojo, 1=naranja, 2=azul)
  int varianteColor;

  // Colores predefinidos para cada variante
  color[] coloresCoches = {
    color(200, 40,  40),   // rojo
    color(220, 120, 30),   // naranja
    color(50,  80, 200)    // azul
  };

  // Sprites (si están disponibles)
  PImage spriteCoche = null;
  PImage spriteCono  = null;

  // ──────────────────────────────────────────
  //  Constructor
  // ──────────────────────────────────────────
  Obstaculo(int tipo, int carril, float xCarril) {
    this.tipo    = tipo;
    this.carril  = carril;
    this.x       = xCarril;
    this.y       = -80;  // nace fuera de pantalla (arriba)
    this.varianteColor = int(random(3));

    if (tipo == TIPO_COCHE) {
      ancho = 36;
      alto  = 60;
      // Intentar cargar sprite
      try { spriteCoche = loadImage("coche_enemigo.png"); }
      catch (Exception e) { spriteCoche = null; }
    } else {
      ancho = 22;
      alto  = 28;
      try { spriteCono = loadImage("cono.png"); }
      catch (Exception e) { spriteCono = null; }
    }
  }

  // ──────────────────────────────────────────
  //  Actualizar posición (desciende con el scroll)
  // ──────────────────────────────────────────
  void actualizar(float velocidad) {
    y += velocidad;
    if (y > height + 100) fueraDePantalla = true;
  }

  // ──────────────────────────────────────────
  //  Dibujar obstáculo
  // ──────────────────────────────────────────
  void dibujar() {
    pushMatrix();
    translate(x, y);

    if (tipo == TIPO_COCHE) {
      if (spriteCoche != null && spriteCoche.width > 0) {
        imageMode(CENTER);
        // Rotar 180° porque va hacia abajo (mirando al jugador)
        rotate(PI);
        image(spriteCoche, 0, 0, ancho, alto);
      } else {
        dibujarCocheEnemigo();
      }
    } else {
      if (spriteCono != null && spriteCono.width > 0) {
        imageMode(CENTER);
        image(spriteCono, 0, 0, ancho, alto);
      } else {
        dibujarCono();
      }
    }

    popMatrix();
  }

  // ──────────────────────────────────────────
  //  Dibujo procedural del coche enemigo
  //  (mirando hacia abajo = viene hacia el jugador)
  // ──────────────────────────────────────────
  void dibujarCocheEnemigo() {
    float a  = ancho;
    float al = alto;
    color colorBase = coloresCoches[varianteColor];

    // Sombra
    noStroke();
    fill(0, 0, 0, 60);
    ellipse(2, 4, a * 0.8, al * 0.3);

    // Carrocería
    noStroke();
    fill(colorBase);
    rect(-a/2, -al/2, a, al, 6);

    // Capó (ahora abajo porque viene de frente)
    fill(red(colorBase) * 0.85, green(colorBase) * 0.85, blue(colorBase) * 0.85);
    rect(-a/2 + 3, al/2 - al * 0.25, a - 6, al * 0.25, 0, 0, 6, 6);

    // Ventana delantera (abajo)
    fill(50, 100, 180, 200);
    rect(-a/2 + 5, al/2 - al * 0.42, a - 10, al * 0.2, 3);

    // Ventana trasera (arriba)
    fill(50, 100, 180, 160);
    rect(-a/2 + 5, -al/2 + al * 0.08, a - 10, al * 0.18, 3);

    // Ventanas laterales
    fill(50, 100, 180, 180);
    rect(-a/2 + 5, -al/2 + al * 0.3, a - 10, al * 0.22, 2);

    // Faros delanteros (abajo, color blanco/amarillo)
    fill(255, 255, 200);
    ellipse(-a/2 + 6, al/2 - 5, 8, 5);
    ellipse( a/2 - 6, al/2 - 5, 8, 5);

    // Faros traseros (arriba, rojo)
    fill(200, 50, 50);
    ellipse(-a/2 + 6, -al/2 + 5, 8, 5);
    ellipse( a/2 - 6, -al/2 + 5, 8, 5);

    // Ruedas
    fill(20, 20, 20);
    rect(-a/2 - 4, -al/2 + 6,  8, 14, 2);
    rect( a/2 - 4, -al/2 + 6,  8, 14, 2);
    rect(-a/2 - 4,  al/2 - 20, 8, 14, 2);
    rect( a/2 - 4,  al/2 - 20, 8, 14, 2);

    // Detalles de rayas laterales (variantes)
    if (varianteColor == 1) { // naranja: rayas negras
      stroke(0, 0, 0, 150);
      strokeWeight(1.5);
      line(-a/2 + 3, -al/2 + al * 0.35, a/2 - 3, -al/2 + al * 0.35);
      line(-a/2 + 3, -al/2 + al * 0.5,  a/2 - 3, -al/2 + al * 0.5);
      strokeWeight(1);
      noStroke();
    }
  }

  // ──────────────────────────────────────────
  //  Dibujo procedural del cono de tráfico
  // ──────────────────────────────────────────
  void dibujarCono() {
    float w = ancho;
    float h = alto;

    // Base gris del cono
    noStroke();
    fill(160, 160, 160);
    rect(-w/2, h/2 - h * 0.22, w, h * 0.22, 2);

    // Cuerpo naranja del cono (triángulo)
    fill(230, 90, 20);
    triangle(0, -h/2,
             -w/2, h/2 - h * 0.22,
              w/2, h/2 - h * 0.22);

    // Banda reflectante blanca
    fill(255, 255, 255, 200);
    float yBanda = -h/2 + h * 0.45;
    float anchoBanda = w * 0.55;
    rect(-anchoBanda/2, yBanda, anchoBanda, h * 0.12, 1);

    // Punta naranja oscuro
    fill(180, 60, 10);
    triangle(0, -h/2,
             -w * 0.12, -h/2 + h * 0.2,
              w * 0.12, -h/2 + h * 0.2);
  }
}
