-------------------------------------------------------------------------  
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------                              
--  010248; Roberto López Masiá; roberto.lopez.masia@hotmail.com       --
--  040289; Andres Gómez Fasbender; fass_centauri@hotmail.com          --
--  050007; Ángel Alférez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------
--
--
--   Descripción:
--     Bloque que contiene las operaciones gráficas del proyecto (librería gráfica JEWL)
--     Crea la interfaz de usuario y visualiza el dibujo postscript.
--     Traduce las operaciones del fichero postscript.
--     Contiene todas las operaciones del sistema de coordenadas.
-- 
-- -------------------------------------------------------------------------
package bloque_grafico is
   Avanzar_Pagina : Natural :=0;
   Terminar_Todo : Natural := 0;
   
   procedure iniciar;
--  Muestra el interfaz gráfico en pantalla, inicia la visualización del
--  fichero postscript en blanco, salva este estado y deja de mostrarlo en
--  pantalla.

   procedure limpiar;

   procedure pclose;
--  Cierra el interfaz gráfico

   procedure phide;
--  Oculta el interfaz gráfico
--procedure terminar_aux;
   procedure terminar;
--  PRE: Se han terminado todas las operaciones en el dibujo
--  POST: Se activan el menu del interfaz gráfico y las opciones de
--  desplazar la página visualizada.

   procedure Mensaje_Error (S : in String);
--  Muestra un mensaje de error en pantalla.

   procedure new_path;
--  Inicia un nuevo camino y se espera que se establezca un origen
--  para dicho camino

   procedure moveto  (a, b : in Float);
--  Mueve sin trazar hasta (a,b) si no había un origen definido
--  para newpath se establece uno.

   procedure rmoveto  (a, b : in Float;  error : out Boolean);
--  Mueve sin trazar hasta actual + (a,b). Si aparece dentro de un
--  newpath sin origen definido la salida error será True.

   procedure lineto (a, b : in Float; error : out Boolean);
--  Mueve trazando una linea desde actual hasta (a,b)
--  Si aparece dentro de un newpath sin origen definido
--  la salida error será True.

   procedure rlineto (a, b : in Float; error : out Boolean);
--  Mueve trazando una linea desde actual hasta actual + (a,b)
--  Si aparece dentro de un newpath sin origen definido
--  la salida error será True.

   procedure close_path;
--  Cierra el último newpath trazando una línea

   procedure set_gray (a : in Float);
--  Establece el tono de gris con el que se pintarán las
--  siguientes líneas.

   procedure set_width (a : in Float);
--  Establece el grosor con el que se pintarán las
--  siguientes líneas.

   procedure stroke;
--  Salva el último camino pintado en el dibujo

   procedure showpage;
--  La visualización del archivo postscript se mostrará en pantalla

   procedure chow (S : in String);
--  Muestra la cadena String en el punto actual

   procedure translate  (a, b : in Float);
--  Pone el origen del sistema en (a,b)
--  actual también se mueve a esa posición.

   procedure rotate  (a : in Float);
--  Rota el sistema a radianes

   procedure scale  (a, b : in Float);
--  Cambia la escala actual del sistema

   procedure gsave;
--  Salva el estado gráfico en la pila de estados gráficos.

   procedure grestore (error : out Boolean);
--  Restaura el último estado gráfico guardado
--  Si la pila de estados gráficos esta vacía error = True

   procedure destruir_st;
--  Destruye la pila de estados gráficos

end bloque_grafico;