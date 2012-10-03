-------------------------------------------------------------------------  
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------                              
--  010248; Roberto L�pez Masi�; roberto.lopez.masia@hotmail.com       --
--  040289; Andres G�mez Fasbender; fass_centauri@hotmail.com          --
--  050007; �ngel Alf�rez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------
--
--
--   Descripci�n:
--     Bloque que contiene las operaciones gr�ficas del proyecto (librer�a gr�fica JEWL)
--     Crea la interfaz de usuario y visualiza el dibujo postscript.
--     Traduce las operaciones del fichero postscript.
--     Contiene todas las operaciones del sistema de coordenadas.
-- 
-- -------------------------------------------------------------------------
package bloque_grafico is
   Avanzar_Pagina : Natural :=0;
   Terminar_Todo : Natural := 0;
   
   procedure iniciar;
--  Muestra el interfaz gr�fico en pantalla, inicia la visualizaci�n del
--  fichero postscript en blanco, salva este estado y deja de mostrarlo en
--  pantalla.

   procedure limpiar;

   procedure pclose;
--  Cierra el interfaz gr�fico

   procedure phide;
--  Oculta el interfaz gr�fico
--procedure terminar_aux;
   procedure terminar;
--  PRE: Se han terminado todas las operaciones en el dibujo
--  POST: Se activan el menu del interfaz gr�fico y las opciones de
--  desplazar la p�gina visualizada.

   procedure Mensaje_Error (S : in String);
--  Muestra un mensaje de error en pantalla.

   procedure new_path;
--  Inicia un nuevo camino y se espera que se establezca un origen
--  para dicho camino

   procedure moveto  (a, b : in Float);
--  Mueve sin trazar hasta (a,b) si no hab�a un origen definido
--  para newpath se establece uno.

   procedure rmoveto  (a, b : in Float;  error : out Boolean);
--  Mueve sin trazar hasta actual + (a,b). Si aparece dentro de un
--  newpath sin origen definido la salida error ser� True.

   procedure lineto (a, b : in Float; error : out Boolean);
--  Mueve trazando una linea desde actual hasta (a,b)
--  Si aparece dentro de un newpath sin origen definido
--  la salida error ser� True.

   procedure rlineto (a, b : in Float; error : out Boolean);
--  Mueve trazando una linea desde actual hasta actual + (a,b)
--  Si aparece dentro de un newpath sin origen definido
--  la salida error ser� True.

   procedure close_path;
--  Cierra el �ltimo newpath trazando una l�nea

   procedure set_gray (a : in Float);
--  Establece el tono de gris con el que se pintar�n las
--  siguientes l�neas.

   procedure set_width (a : in Float);
--  Establece el grosor con el que se pintar�n las
--  siguientes l�neas.

   procedure stroke;
--  Salva el �ltimo camino pintado en el dibujo

   procedure showpage;
--  La visualizaci�n del archivo postscript se mostrar� en pantalla

   procedure chow (S : in String);
--  Muestra la cadena String en el punto actual

   procedure translate  (a, b : in Float);
--  Pone el origen del sistema en (a,b)
--  actual tambi�n se mueve a esa posici�n.

   procedure rotate  (a : in Float);
--  Rota el sistema a radianes

   procedure scale  (a, b : in Float);
--  Cambia la escala actual del sistema

   procedure gsave;
--  Salva el estado gr�fico en la pila de estados gr�ficos.

   procedure grestore (error : out Boolean);
--  Restaura el �ltimo estado gr�fico guardado
--  Si la pila de estados gr�ficos esta vac�a error = True

   procedure destruir_st;
--  Destruye la pila de estados gr�ficos

end bloque_grafico;