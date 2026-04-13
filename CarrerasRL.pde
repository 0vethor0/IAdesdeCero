// ============================================================
//  CarrerasRL.pde  —  Punto de entrada principal
//  Aprendizaje por Refuerzo Evolutivo: Carreras de Autos 2D
//  Paradigma: Algoritmo Genético + Red Neuronal (desde cero)
//  Entorno: Processing 4  |  800×600  |  Java-mode
// ============================================================

Simulacion simulacion;
GeneradorSprites generadorSprites;

void setup() {
  size(800, 600);
  frameRate(60);
  textFont(createFont("Arial", 14, true));

  // Paso 1: generar y guardar sprites en /data/
  generadorSprites = new GeneradorSprites();
  generadorSprites.generarTodos();

  // Paso 2: iniciar simulación con población de 10 coches IA
  simulacion = new Simulacion(10);
}

void draw() {
  simulacion.actualizar();
  simulacion.dibujar();
}

void keyPressed() {
  // Tecla R: reiniciar simulación completa
  if (key == 'r' || key == 'R') {
    simulacion = new Simulacion(10);
  }
  // Tecla +/-: ajustar velocidad de simulación
  if (key == '+') frameRate(min(120, frameRate + 10));
  if (key == '-') frameRate(max(10, frameRate - 10));
}
