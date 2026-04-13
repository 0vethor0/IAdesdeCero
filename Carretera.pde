// ============================================================
//  Carretera.pde  —  Motor de la carretera
//  2 carriles, scroll vertical infinito, bordes de césped,
//  líneas divisorias animadas sincronizadas con la velocidad
// ============================================================

class Carretera {

  // Dimensiones de la carretera (centrada horizontalmente)
  // Cada carril = ancho del coche (36px) + margen lateral (20px) = 56px × 2 carriles
  float anchoCarril     = 56;
  float anchoCarretera  = 112;   // 56 × 2 carriles
  float xIzquierda;     // borde izquierdo de la carretera
  float xDerecha;       // borde derecho

  // Centros de cada carril (usado por coches para posicionarse)
  float xCentroCarrilIzq;
  float xCentroCarrilDer;

  // Scroll de la carretera
  float desplazamientoScroll = 0;
  float longitudMarca        = 40;   // longitud de cada raya central
  float espacioMarca         = 30;   // espacio entre rayas
  float longitudBorde        = 20;   // rayas de borde laterales

  // ──────────────────────────────────────────
  //  Constructor
  // ──────────────────────────────────────────
  Carretera() {
    xIzquierda        = (width - anchoCarretera) / 2.0;
    xDerecha          = xIzquierda + anchoCarretera;
    // Centro de cada carril = borde + mitad del ancho del carril
    xCentroCarrilIzq  = xIzquierda + anchoCarril * 0.5;
    xCentroCarrilDer  = xIzquierda + anchoCarril * 1.5;
  }

  // ──────────────────────────────────────────
  //  Actualizar posición del scroll
  // ──────────────────────────────────────────
  void actualizar(float velocidad) {
    desplazamientoScroll += velocidad;
    float periodoCiclo = longitudMarca + espacioMarca;
    if (desplazamientoScroll > periodoCiclo)
      desplazamientoScroll -= periodoCiclo;
  }

  // ──────────────────────────────────────────
  //  Dibujar toda la carretera
  // ──────────────────────────────────────────
  void dibujar() {
    dibujarCesped();
    dibujarAsfalto();
    dibujarBordesLaterales();
    dibujarLineaCentral();
    dibujarMarcasLaterales();
  }

  void dibujarCesped() {
    // Franja izquierda de césped
    noStroke();
    fill(34, 139, 34);
    rect(0, 0, xIzquierda, height);

    // Franja derecha de césped
    rect(xDerecha, 0, width - xDerecha, height);

    // Arbustos decorativos (estáticos, solo visuales)
    fill(20, 100, 20);
    dibujarArbustos(xIzquierda * 0.5, 40);
    dibujarArbustos(xDerecha + (width - xDerecha) * 0.5, 40);
  }

  void dibujarArbustos(float xCentro, float separacion) {
    int cantArbustos = ceil(height / separacion) + 2;
    float offsetY = desplazamientoScroll % separacion;
    for (int i = -1; i < cantArbustos; i++) {
      float yArbusto = i * separacion + offsetY;
      ellipse(xCentro, yArbusto, 28, 22);
    }
  }

  void dibujarAsfalto() {
    noStroke();
    fill(55, 55, 55);
    rect(xIzquierda, 0, anchoCarretera, height);

    // Textura sutil más oscura en los laterales del asfalto
    fill(45, 45, 45);
    rect(xIzquierda, 0, 8, height);
    rect(xDerecha - 8, 0, 8, height);
  }

  void dibujarBordesLaterales() {
    // Líneas amarillas sólidas en los bordes de la carretera
    stroke(230, 200, 50);
    strokeWeight(3);
    line(xIzquierda + 4, 0, xIzquierda + 4, height);
    line(xDerecha   - 4, 0, xDerecha   - 4, height);
    strokeWeight(1);
  }

  void dibujarLineaCentral() {
    // Línea central discontinua blanca entre los 2 carriles
    float xCentro   = (xIzquierda + xDerecha) / 2.0;
    float periodoCiclo = longitudMarca + espacioMarca;
    int cantMarcas  = ceil(height / periodoCiclo) + 2;

    stroke(255, 255, 255, 200);
    strokeWeight(2.5);

    for (int i = -1; i < cantMarcas; i++) {
      float yInicio = i * periodoCiclo + desplazamientoScroll;
      float yFin    = yInicio + longitudMarca;
      line(xCentro, yInicio, xCentro, yFin);
    }
    strokeWeight(1);
  }

  void dibujarMarcasLaterales() {
    // Rayas blancas cortas en los bordes interiores de cada carril
    float periodoCiclo = (longitudBorde + espacioMarca * 0.5);
    int cantMarcas  = ceil(height / periodoCiclo) + 2;
    // Posicionar marcas al 15% desde cada borde (proporcional al carril estrecho)
    float xMarcaIzq = xIzquierda + anchoCarril * 0.15;
    float xMarcaDer = xDerecha   - anchoCarril * 0.15;

    stroke(255, 255, 255, 60);
    strokeWeight(1);

    for (int i = -1; i < cantMarcas; i++) {
      float yInicio = i * periodoCiclo + desplazamientoScroll * 0.7;
      float yFin    = yInicio + longitudBorde;
      line(xMarcaIzq, yInicio, xMarcaIzq, yFin);
      line(xMarcaDer, yInicio, xMarcaDer, yFin);
    }
  }

  // ──────────────────────────────────────────
  //  Utilitario: retorna el X del centro
  //  de un carril dado su índice (0 = izq, 1 = der)
  // ──────────────────────────────────────────
  float obtenerXCarril(int numeroCarril) {
    if (numeroCarril == 0) return xCentroCarrilIzq;
    return xCentroCarrilDer;
  }

  // ──────────────────────────────────────────
  //  Utilitario: determinar en qué carril está
  //  una coordenada X dada
  // ──────────────────────────────────────────
  int obtenerCarrilDesdeX(float x) {
    float xCentro = (xIzquierda + xDerecha) / 2.0;
    return (x < xCentro) ? 0 : 1;
  }
}
