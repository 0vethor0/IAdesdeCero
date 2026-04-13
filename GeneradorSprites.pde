// ============================================================
//  GeneradorSprites.pde  —  Genera y guarda sprites PNG
//  Dibuja programáticamente cada asset y lo exporta a /data/
//  Se ejecuta UNA SOLA VEZ al inicio del programa
//  Archivos generados: coche_jugador.png, coche_enemigo.png, cono.png
// ============================================================

class GeneradorSprites {

  // ──────────────────────────────────────────
  //  Generar y guardar todos los sprites
  // ──────────────────────────────────────────
  void generarTodos() {
    generarCocheJugador();
    generarCocheEnemigo();
    generarCono();
    println("[GeneradorSprites] Sprites generados correctamente en /data/");
  }

  // ──────────────────────────────────────────
  //  Coche amarillo (jugador / IA)
  //  72 × 120 px — vista cenital (top-down)
  // ──────────────────────────────────────────
  void generarCocheJugador() {
    int sprW = 72;
    int sprH = 120;
    PGraphics pg = createGraphics(sprW, sprH);
    pg.beginDraw();
    pg.clear(); // fondo transparente

    float a  = sprW;
    float al = sprH;

    // Sombra suave
    pg.noStroke();
    pg.fill(0, 0, 0, 50);
    pg.ellipse(a/2 + 2, al/2 + 4, a * 0.75, al * 0.28);

    // Carrocería principal amarilla
    pg.fill(255, 210, 0);
    pg.rect(4, 4, a - 8, al - 8, 10);

    // Detalle capó delantero (amarillo más claro)
    pg.fill(255, 230, 50);
    pg.rect(6, 4, a - 12, al * 0.22, 10, 10, 4, 4);

    // Detalle maletero trasero
    pg.fill(220, 175, 0);
    pg.rect(6, al - al * 0.2, a - 12, al * 0.17, 4, 4, 10, 10);

    // Parabrisas delantero
    pg.fill(80, 140, 220, 230);
    pg.rect(10, al * 0.08, a - 20, al * 0.18, 5);

    // Ventana trasera
    pg.fill(70, 120, 200, 180);
    pg.rect(10, al - al * 0.32, a - 20, al * 0.17, 4);

    // Ventanas laterales izquierda y derecha
    pg.fill(70, 120, 200, 190);
    pg.rect(10, al * 0.30, a - 20, al * 0.24, 3);

    // Líneas de carrocería (detalle)
    pg.stroke(200, 160, 0, 180);
    pg.strokeWeight(1.5);
    pg.line(a * 0.3, al * 0.08, a * 0.3, al * 0.92);
    pg.line(a * 0.7, al * 0.08, a * 0.7, al * 0.92);
    pg.noStroke();

    // Faros delanteros (amarillo brillante)
    pg.fill(255, 255, 180);
    pg.ellipse(14, 12, 14, 8);
    pg.ellipse(a - 14, 12, 14, 8);

    // Faros traseros (rojo)
    pg.fill(220, 50, 50);
    pg.ellipse(14, al - 12, 14, 8);
    pg.ellipse(a - 14, al - 12, 14, 8);

    // Ruedas (4 esquinas, negro con gris)
    pg.fill(25, 25, 25);
    pg.rect(0, 10, 10, 22, 3);          // delantera izq
    pg.rect(a - 10, 10, 10, 22, 3);    // delantera der
    pg.rect(0, al - 32, 10, 22, 3);    // trasera izq
    pg.rect(a - 10, al - 32, 10, 22, 3); // trasera der

    // Aro de rueda (gris)
    pg.fill(110, 110, 110);
    pg.ellipse(5, 21, 6, 12);
    pg.ellipse(a - 5, 21, 6, 12);
    pg.ellipse(5, al - 21, 6, 12);
    pg.ellipse(a - 5, al - 21, 6, 12);

    // Logo "CRAZY" en el techo
    pg.fill(0, 0, 0, 180);
    pg.rect(a/2 - 18, al/2 - 8, 36, 16, 3);
    pg.fill(255, 255, 255);
    pg.textSize(9);
    pg.textAlign(CENTER, CENTER);
    pg.text("CRAZY", a/2, al/2);

    // Patrón ajedrez del taxi (franja inferior)
    pg.fill(0);
    int tamCuadro = 6;
    for (int cx = 0; cx < (int)((a - 8) / tamCuadro); cx++) {
      if (cx % 2 == 0) {
        pg.rect(6 + cx * tamCuadro, al - al * 0.2 - tamCuadro, tamCuadro, tamCuadro);
      }
    }

    pg.endDraw();
    pg.save(sketchPath("data/coche_jugador.png"));
  }

  // ──────────────────────────────────────────
  //  Coche enemigo rojo (con rayas negras)
  //  72 × 120 px — vista cenital mirando hacia abajo
  // ──────────────────────────────────────────
  void generarCocheEnemigo() {
    int sprW = 72;
    int sprH = 120;
    PGraphics pg = createGraphics(sprW, sprH);
    pg.beginDraw();
    pg.clear();

    float a  = sprW;
    float al = sprH;

    // Sombra
    pg.noStroke();
    pg.fill(0, 0, 0, 50);
    pg.ellipse(a/2 + 2, al/2 + 4, a * 0.75, al * 0.28);

    // Carrocería roja
    pg.fill(200, 35, 35);
    pg.rect(4, 4, a - 8, al - 8, 10);

    // Detalle capó (ahora en la parte baja = viene hacia el jugador)
    pg.fill(170, 25, 25);
    pg.rect(6, al - al * 0.22, a - 12, al * 0.19, 4, 4, 10, 10);

    // Capó trasero (parte alta en la imagen)
    pg.fill(220, 50, 50);
    pg.rect(6, 4, a - 12, al * 0.19, 10, 10, 4, 4);

    // Parabrisas delantero (abajo en imagen = de frente al jugador)
    pg.fill(70, 110, 200, 210);
    pg.rect(10, al - al * 0.40, a - 20, al * 0.19, 4);

    // Ventana trasera (arriba)
    pg.fill(60, 100, 190, 170);
    pg.rect(10, al * 0.08, a - 20, al * 0.17, 4);

    // Ventanas laterales
    pg.fill(65, 105, 195, 180);
    pg.rect(10, al * 0.29, a - 20, al * 0.23, 3);

    // Faros delanteros ABAJO (vienen hacia el jugador — blanco/amarillo brillante)
    pg.fill(255, 255, 200);
    pg.ellipse(14, al - 12, 14, 8);
    pg.ellipse(a - 14, al - 12, 14, 8);

    // Faros traseros ARRIBA (rojo oscuro)
    pg.fill(180, 30, 30);
    pg.ellipse(14, 12, 14, 8);
    pg.ellipse(a - 14, 12, 14, 8);

    // Rayas negras deportivas en el capó/maletero
    pg.stroke(0, 0, 0, 180);
    pg.strokeWeight(3);
    pg.line(a * 0.38, 6, a * 0.38, al * 0.22);
    pg.line(a * 0.62, 6, a * 0.62, al * 0.22);
    pg.noStroke();

    // Ruedas
    pg.fill(25, 25, 25);
    pg.rect(0, 10, 10, 22, 3);
    pg.rect(a - 10, 10, 10, 22, 3);
    pg.rect(0, al - 32, 10, 22, 3);
    pg.rect(a - 10, al - 32, 10, 22, 3);

    // Aros
    pg.fill(130, 130, 130);
    pg.ellipse(5, 21, 6, 12);
    pg.ellipse(a - 5, 21, 6, 12);
    pg.ellipse(5, al - 21, 6, 12);
    pg.ellipse(a - 5, al - 21, 6, 12);

    pg.endDraw();
    pg.save(sketchPath("data/coche_enemigo.png"));
  }

  // ──────────────────────────────────────────
  //  Cono de tráfico naranja
  //  44 × 56 px — vista cenital / ligeramente inclinada
  // ──────────────────────────────────────────
  void generarCono() {
    int sprW = 44;
    int sprH = 56;
    PGraphics pg = createGraphics(sprW, sprH);
    pg.beginDraw();
    pg.clear();

    float w = sprW;
    float h = sprH;

    // Sombra
    pg.noStroke();
    pg.fill(0, 0, 0, 50);
    pg.ellipse(w/2 + 2, h - 6, w * 0.55, h * 0.15);

    // Base gris
    pg.fill(150, 150, 150);
    pg.rect(w * 0.1, h - h * 0.22, w * 0.8, h * 0.2, 3);
    // Borde blanco de la base
    pg.stroke(220, 220, 220);
    pg.strokeWeight(1);
    pg.noFill();
    pg.rect(w * 0.1, h - h * 0.22, w * 0.8, h * 0.2, 3);
    pg.noStroke();

    // Cuerpo naranja del cono (triángulo)
    pg.fill(230, 85, 15);
    pg.triangle(w/2, 4, w * 0.05, h - h * 0.22, w * 0.95, h - h * 0.22);

    // Gradiente simulado: franja lateral izquierda más oscura
    pg.fill(180, 60, 10, 120);
    pg.triangle(w/2, 4, w * 0.05, h - h * 0.22, w/2, h - h * 0.22);

    // Banda reflectante blanca
    float yBanda1 = h * 0.42;
    float anchoBanda1 = w * 0.52;
    pg.fill(255, 255, 255, 230);
    pg.beginShape();
    float proporcion1 = (yBanda1 - 4) / (h - h * 0.22 - 4);
    float xIzqBanda1  = w/2 - (w/2 - w * 0.05) * proporcion1;
    float proporcion2 = (yBanda1 + h * 0.10 - 4) / (h - h * 0.22 - 4);
    float xIzqBanda2  = w/2 - (w/2 - w * 0.05) * proporcion2;
    pg.vertex(xIzqBanda1, yBanda1);
    pg.vertex(w - xIzqBanda1, yBanda1);
    pg.vertex(w - xIzqBanda2, yBanda1 + h * 0.10);
    pg.vertex(xIzqBanda2, yBanda1 + h * 0.10);
    pg.endShape(CLOSE);

    // Punta del cono (naranja más oscuro)
    pg.fill(190, 65, 10);
    pg.triangle(w/2, 4, w/2 - 5, 4 + h * 0.16, w/2 + 5, 4 + h * 0.16);

    // Punto brillante en la punta
    pg.fill(255, 200, 100, 200);
    pg.ellipse(w/2, 6, 5, 5);

    pg.endDraw();
    pg.save(sketchPath("data/cono.png"));
  }
}
