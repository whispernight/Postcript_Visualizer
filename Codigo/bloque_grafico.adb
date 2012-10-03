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
with Pilas;
with Ada.Text_Io;
use Ada.Text_Io;

WITH JEWL.Simple_Windows;
USE  JEWL.Simple_Windows;
WITH Ada.Numerics.Elementary_Functions;
USE Ada.Numerics.Elementary_Functions;

PACKAGE BODY Bloque_Grafico IS

   -------------
   --  TIPOS  ------------------------------------------------------
   -------------
   Pi : CONSTANT Float := 3.141592654;  
   TYPE Coordenadas IS 
      RECORD 
         X,  
         Y : Float;  
      END RECORD; 

   --  x e y son la magnitud de la escala
   --  ang es lo rotado que estaba el sistema
   --  cuando se realizó la escala
   TYPE Escalado IS 
      RECORD 
         X,  
         Y,  
         Ang : Float;  
      END RECORD; 

   --  matriz de 2x2
   --  (a b)
   --  (c d)
   TYPE Matrizm IS 
      RECORD 
         A,  
         B,  
         C,  
         D : Float;  
      END RECORD; 

   TYPE Estado IS 
      RECORD 
         Origen,  
         Actual : Coordenadas := (0.0, 0.0);  
         Escala : Matrizm     := (1.0, 0.0, 0.0, 1.0);  
         Angulo : Float       := 0.0;  
         Grosor : Integer     := 1;  
         Color  : Float       := 0.0;  
      END RECORD; 
   --
   --  origen : origen del sistema
   --  actual : punto actual
   --  angulo : radianes que está rotado el sistema
   --  grosor : grosor de línea
   --  color : tono de gris


   --  pila auxiliar para salvar y recuperar estados gráficos
   --  necesaria para gsave y grestore
   PACKAGE Pila_Estado IS NEW Pilas (Tipo_Elemento => Estado);


   Ventana : Coordenadas := (800.0, 600.0);  
   Pagina  : Coordenadas := (595.0, 895.0);  
   --  Dimensiones del frame y del dibujo respectivamente.
   F : Frame_Type := Frame (Integer (Ventana.X), Integer (Ventana.Y), "Proyecto Visualizador de Postscript",
     'X');  
   -- Título que aparece en la ventana.
   ------------------------------------------------------------------------
   --  Frame   (Origin,      -- create a frame at the specified position
   --           Width,       -- with the specified width
   --           Height,      -- and height in pixels,
   --           Title,       -- with the specified title in the title bar,
   --           Command,     -- generating this command when it is closed,
   --           Font)        -- using this font (default: Default_Font).
   ------------------------------------------------------------------------
   Dibujo : Canvas_Type;  
   --  Declaración del frame y del dibujo
   --  Se asocian a frame todos sus valores iniciales.
   Status : Estado;  
   --  Estado gráfico del sistema.
    Showp : Boolean := False; 
   --  Booleano asociado a showpage (si es falso no se muestra la página).
   Valido : Boolean := True;  
   --  Booleano asociado a la validez del origen para newpath
   --  sino se declara un origen para empezar un camino newpath
   --  tendría un origen no valido y se daría el correspondiente error.
   Path : Coordenadas;  
   --  Coordenadas para empezar un camino con newpath.
   Pila       : Pila_Estado.Pila;  
   Pila_Ini   : Boolean          := False;  
   Count_Pila : Integer          := 0;  
   --  Pila de estados gráficos,
   --  un booleano que indica si se ha asignado algún valor a la pila o no
   --  y un contador de los elementos que hay en la pila.


   -----------------
   --  INTERFAZ   -----------------------------------------------------------
   -----------------
   -----------------------
   --  Ventanas Error  ------------------------------------------------------------
   -----------------------
   --  PRE: Cierto
   --  POST: ventanas de  mensaje de error.
   PROCEDURE Mensaje_Error (
         S : IN     String ) IS 
   BEGIN
      Show_Error (S, "Visualps: ERROR");
   END Mensaje_Error;


   --  PRE: Cierto, 
   --  POST: Devuelve el punto de origen dentro de Frame donde debería
   --        aparecer Dibujo para estar centrado.
   FUNCTION Ajustar_Pagina (
         F,              
         D : Coordenadas ) 
     RETURN Point_Type; 
   FUNCTION Ajustar_Pagina (
         F,              
         D : Coordenadas ) 
     RETURN Point_Type IS 
      P : Point_Type;  
      --  f y d son las dimensiones del Frame y del Dibujo respectivamente.
   BEGIN
      IF D.X > F.X THEN
         P.X := 0;
      ELSE
         P.X := Integer ((F.X - D.X) / 2.0);
      END IF;
      IF D.Y > F.Y THEN
         P.Y := 0;
      ELSE
         P.Y := Integer ((F.Y - D.Y) / 2.0);
      END IF;
      RETURN P;
   END Ajustar_Pagina;



   --  PRE: Cierto
   --  POST: nicia el dibujo en blanco,
   --        salva este estado y deja de mostrar el dibujo en pantalla.
   PROCEDURE Iniciar IS 
      --  Opciones del menu raiz
      M  : Menu_Type := Menu (F, "&Archivo");  
      M2 : Menu_Type := Menu (F, "&Mover");  
      M3 : Menu_Type := Menu (F, "&Autores");  
      --------------------------------------------------------------------
      --  Menu_Type   : a menu which can contain menu items and submenus.
      --  (ver. jewl-windows.ads)
      ---------------------------------------------------------------------
      --  submenus encadenados
      X : Menuitem_Type := Menuitem (M, "&Cerrar", 'X');  
      U : Menuitem_Type := Menuitem (M2, "&Avanzar", 'U');  
      W : Menuitem_Type := Menuitem (M2, "&Cabeza de pagina", 'W');  
      V : Menuitem_Type := Menuitem (M2, "&Retroceder", 'V');
      Y : Menuitem_Type := Menuitem (M2, "&Avanzar Pagina", 'Y');  

      T : Menuitem_Type := Menuitem (M3, "&Roberto López Masiá", 'T');  
      S : Menuitem_Type := Menuitem (M3, "&Andres Gómez Fasbender", 'S');
         
      R : Menuitem_Type := Menuitem (M3, "&Angel Alferez Aroca", 'R');  
   BEGIN
      Show (F, True);
      Dibujo := Canvas (F,
         Ajustar_Pagina (Ventana, Pagina),
         Integer (Pagina.X),
         Integer (Pagina.Y),
         'R');
      Save (Dibujo);
      Show (Dibujo, False);
   END Iniciar;

   procedure Limpiar is
   begin
      Erase(Dibujo);
   end Limpiar;
   

   --  PRE: Cierto
   --  POST: Termina con el frame.
   PROCEDURE Pclose IS 
   BEGIN
      Close (F);
   END Pclose;

   --  PRE: Cierto
   --  POST: El frame deja de verse en pantalla.
   -------------------------------------------------------------
   --  Hide       (Window)   -- make the window invisible.
   --  (ver. jewl-windows.ads)
   -------------------------------------------------------------
   PROCEDURE Phide IS 
   BEGIN
      Hide (F);
   END Phide;


































   --  PRE: Se han terminado todas las operaciones en el dibujo
   --  POST: Se activan el menu del frame y las opciones de desplazar
   --        el dibujo dentro de frame.
   PROCEDURE Terminar IS 
      P,  
      Q,  
      O : Point_Type;  
   BEGIN
      O := (0, 0);
      Restore (Dibujo);
      IF NOT Showp THEN
         Erase (Dibujo);
      END IF;
      Show (Dibujo, True);
      loop
put_line("bloque grafico");
         if (Avanzar_Pagina /= 0) then
            exit;
         end if;
         CASE Next_Command IS
            when 'X' =>
               terminar_todo := 1;
               Close (F);
               EXIT;
            WHEN 'V' =>
               P := Start_Point (Dibujo);
               Q := End_Point (Dibujo);
               P.Y := Q.Y - 5;
               O.Y := O.Y + 5;
               Set_Origin (Dibujo, O);
            WHEN 'W' =>
               --p := Start_Point (dibujo);
               Q := End_Point (Dibujo);
               --p.X := (400);
               --p.Y := (400);
               O.X := (100);
               O.Y := (0);
               Set_Origin (Dibujo, O);
            WHEN 'U' =>
               P := Start_Point (Dibujo);
               Q := End_Point (Dibujo);
               P.Y := Q.Y + 5;
               O.Y := O.Y - 5;
               Set_Origin (Dibujo, O);
            when 'Y' =>
               --Leer_Postscript_Aux (Entrada, pila, I, Error);
               Avanzar_Pagina :=1;
               Erase(Dibujo);
               delay 0.1;
               exit;

            WHEN OTHERS =>
               NULL;
         END CASE;
         --  Mover el dibujo con el raton.  
         --  hacemos una traslación del sistema, del punto de origen
         --  al que se pincha.        
         IF Mouse_Down (Dibujo) THEN
            P := Start_Point (Dibujo);
            WHILE Mouse_Down (Dibujo) LOOP
               NULL;
            END LOOP;
            Q := End_Point (Dibujo);
            P.X := Q.X - P.X;
            P.Y := Q.Y - P.Y;
            O.X := O.X + P.X;
            O.Y := O.Y + P.Y;
            Set_Origin (Dibujo, O);
         END IF;
      end loop;
      --avanzar_pagina := 0;
   END Terminar;




   -------------------------------
   --  Sistema de coordenadas   --------------------------------------------------
   --  A mano (Algebra lineal)  --
   -------------------------------

   --  PRE: Cierto
   --  POST: Devuelve la matriz que "distorsiona" el espacio según
   --        en que ángulo y con que escala se haya realizado.
   FUNCTION Calcularm (
         E : Escalado ) 
     RETURN Matrizm; 
   FUNCTION Calcularm (
         E : Escalado ) 
     RETURN Matrizm IS 
   BEGIN
      RETURN ((E.X * ((Cos (E.Ang)) ** 2) +
            E.Y * ((Sin (E.Ang)) ** 2)),
         ((E.X - E.Y) * Cos (E.Ang) * Sin (E.Ang)),
         ((E.X - E.Y) * Cos (E.Ang) * Sin (E.Ang)),
         (E.X * ((Sin (E.Ang)) ** 2) +
            E.Y * ((Cos (E.Ang)) ** 2)));
   END Calcularm;

   --  PRE: Cierto
   --  POST: Devuelve la matriz resultado de multiplicar
   --        A por B.
   FUNCTION Multiplicarm (
         A,          
         B : Matrizm ) RETURN Matrizm; 
   FUNCTION Multiplicarm (
         A,          
         B : Matrizm ) RETURN Matrizm IS 
   BEGIN
      RETURN ((A.A * B.A + A.B * B.C),
         (A.A * B.B + A.B * B.D),
         (A.C * B.A + A.D * B.C),
         (A.C * B.B + A.D * B.D));
   END Multiplicarm;

   --  PRE: Cierto
   --  POST: Devuelve las coordenadas del punto p si rotamos
   --        el sistema (status.angulo) radianes.
   FUNCTION Pos (
         P : Coordenadas ) 
     RETURN Coordenadas; 
   FUNCTION Pos (
         P : Coordenadas ) 
     RETURN Coordenadas IS 
   BEGIN
      RETURN ((P.X * Cos (Status.Angulo) - P.Y * Sin (Status.Angulo)),
         (P.X * Sin (Status.Angulo) + P.Y * Cos (Status.Angulo)));
   END Pos;

   --  PRE: Cierto
   --  POST: Aplica la matriz status.escala al punto p para obtener
   --        las coordenadas de ese punto en el sistema actual.
   FUNCTION Mover (
         P : Coordenadas ) 
     RETURN Coordenadas; 
     
   FUNCTION Mover (
         P : Coordenadas ) 
     RETURN Coordenadas IS 
   BEGIN
      RETURN ((Status.Escala.A * P.X + Status.Escala.B * P.Y),
         (Status.Escala.C * P.X + Status.Escala.D * P.Y));
   END Mover;

   --  PRE: Cierto
   --  POST: Devuelve las coordenadas del punto una vez que se le han aplicado
   --        todas las translaciones, movimientos y cambios de escala asociados
   --        al sistema de coordenadas actual.
   FUNCTION Ajustar (
         P : Coordenadas ) 
     RETURN Coordenadas; 
   FUNCTION Ajustar (
         P : Coordenadas ) 
     RETURN Coordenadas IS 
      Q : Coordenadas;  
   BEGIN
      Q := Pos (P);
      Q := Mover (Q);
      Q.X := Q.X + Status.Origen.X;
      Q.Y := Pagina.Y - (Q.Y + Status.Origen.Y);
      RETURN Q;
   END Ajustar;

   --  PRE: Cierto
   --  POST: Devuelve el punto p en formato (Int, Int).
   FUNCTION Fint (
         P : Coordenadas ) 
     RETURN Point_Type; 
   FUNCTION Fint (
         P : Coordenadas ) 
     RETURN Point_Type IS 
   BEGIN
      RETURN (Integer (P.X), Integer (P.Y));
   END Fint;

   --  PRE: Cierto
   --  POST: Devuelve la suma de las coordenadas de dos puntos.
   FUNCTION Sumar (
         A,              
         B : Coordenadas ) 
     RETURN Coordenadas; 
   FUNCTION Sumar (
         A,              
         B : Coordenadas ) 
     RETURN Coordenadas IS 
   BEGIN
      RETURN (A.X + B.X, A.Y + B.Y);
   END Sumar;

   --  PRE: Cierto
   --  POST: Devuelve el tono de gris asociado a n.
   FUNCTION Colorear (
         N : Float ) 
     RETURN Colour_Type; 
   FUNCTION Colorear (
         N : Float ) 
     RETURN Colour_Type IS 
      Aux : Float;  
   BEGIN
      Aux := N;
      IF N >= 1.0 THEN
         Aux := 1.0;
      END IF;
      IF N <= 0.0 THEN
         Aux := 0.0;
      END IF;
      RETURN (Integer (255.0 * Aux),
         Integer (255.0 * Aux),
         Integer (255.0 * Aux));
   END Colorear;

   
   -----------------------------
   -- Construcción de caminos --------------------
   ------------------------------

   --  PRE: Cierto
   --  POST: Valido pasa a ser falso.
   --        Esta condición se estudiará para poner origen a newpath.
   --        Restaura el dibujo a su estado anterior, si el anterior camino
   --        no tenía un stroke no se mostrará en dibujo
   PROCEDURE New_Path IS 
   BEGIN
      Restore (Dibujo);
      Valido := False;
   END New_Path;

   --  PRE: Cierto
   --  POST: Pone actual en (a,b)
   --        Si valido es falso, inicia el camino (path) en (a,b).
   PROCEDURE Moveto (
         A,               
         B : IN     Float ) IS 
   BEGIN
      IF Valido = False THEN
         Path := (A, B);
         Valido := True;
      END IF;
      Status.Actual := (A, B);
   END Moveto;

   --  PRE: Cierto
   --  POST: Pone actual en actual + (a,b).
   PROCEDURE Rmoveto (
         A,                     
         B     : IN     Float;  
         Error :    OUT Boolean ) IS 
   BEGIN
      IF Valido = False THEN
         Error := True;
      ELSE
         Status.Actual := Sumar (Status.Actual, (A, B));
         Error := False;
      END IF;
   END Rmoveto;

   --  PRE: Cierto
   --  POST: Da un error si se ha iniciado un nuevo camino
   --        pero este todavía no tiene origen.
   --        Si el origen es valido pinta una linea en dibujo
   --        desde actual hasta (a,b).
   PROCEDURE Lineto (
         A,                     
         B     : IN     Float;  
         Error :    OUT Boolean ) IS 
   BEGIN
      Set_Pen (Dibujo, Colorear (Status.Color), Status.Grosor);
      IF Valido = False THEN
         Error := True;
      ELSE
         Draw_Line (Dibujo, Fint (Ajustar (Status.Actual)),
            Fint (Ajustar ((A, B))));
         Status.Actual := (A, B);
         Error := False;
      END IF;
   END Lineto;

   --  PRE: Cierto
   --  POST: Da un error si se ha iniciado un nuevo camino
   --        pero este todavía no tiene origen.
   --        Si el origen es valido pinta una linea en dibujo
   --        desde actual hasta actual + (a,b).
   PROCEDURE Rlineto (
         A,                     
         B     : IN     Float;  
         Error :    OUT Boolean ) IS 
   BEGIN
      Set_Pen (Dibujo, Colorear (Status.Color), Status.Grosor);
      IF Valido = False THEN
         Error := True;
      ELSE
         Draw_Line (Dibujo, Fint (Ajustar (Status.Actual)),
            Fint (Ajustar (Sumar (Status.Actual, (A, B)))));
         Status.Actual := Sumar (Status.Actual, (A, B));
         Error := False;
      END IF;
   END Rlineto;

   --  PRE: Cierto
   --  POST: Si hay un origen valido de un camino iniciado por newpath
   --        traza una linea desde actual hasta path en dibujo.
   --        Si no hay un origen valido pone valido a True para
   --        poder iniciar otros caminos más adelante.
   PROCEDURE Close_Path IS 
   BEGIN
      IF Valido = False THEN
         Valido := True;
      ELSE
         Draw_Line (Dibujo, Fint (Ajustar (Status.Actual)),
            Fint (Ajustar (Path)));
         Status.Actual := Path;
      END IF;
   END Close_Path;

   -----------------------------
   --  Operadores de pintado --------------------
   ----------------------------
   --  PRE: Cierto
   --  POST: Pone status.color con el tono de gris correspondiente
   PROCEDURE Set_Gray (
         A : IN     Float ) IS 
   BEGIN
      Status.Color := A;
   END Set_Gray;

   --  PRE: Cierto
   --  POST: Pone status.grosor con el grosor correspondiente.
   PROCEDURE Set_Width (
         A : IN     Float ) IS 
   BEGIN
      Status.Grosor := Integer (A);
   END Set_Width;

   --  PRE: Cierto
   --  POST: Se salva el dibujo actual
   PROCEDURE Stroke IS 
   BEGIN
      Save (Dibujo);
   END Stroke;

   ----------------------
   --  Mostrar imagen   -------------------------
   -----------------------
   --  PRE: Cierto
   --  POST: El booleano showp pasa a ser True, la página se imprimirá
   --        en pantalla
   PROCEDURE Showpage IS 
   begin
      --limpiar;-----------------------------------------------------------------------------------------------------------------------NUEVO EN PRUEBAS
      Showp := True;
   END Showpage;

   --  PRE: Cierto
   --  POST: El booleano showp pasa a ser True, la página se imprimirá
   --        en pantalla
   --        texto
   PROCEDURE Chow (
         S : IN     String ) IS 
   begin
      
      Restore (Dibujo);
      Draw_Text (Dibujo,
         Fint (Ajustar (Status.Actual)),
         S);
      Save (Dibujo);
   END Chow;
   -------------------
   --  Movimientos  --------------------------------------------------
   --------------------
   --  PRE: Cierto
   --  POST: Pone el origen del sistema en (a,b)
   --        actual también se mueve a esa posición.
   PROCEDURE Translate (
         A,               
         B : IN     Float ) IS 
   BEGIN
      Status.Origen := (A, B);
      Status.Actual := (0.0, 0.0);
   END Translate;

   --  PRE: Cierto
   --  POST: Rota el sistema a radianes segun el dato a
   PROCEDURE Rotate (
         A : IN     Float ) IS 
   BEGIN
      Status.Angulo := Status.Angulo + ((A / 180.0) * Pi);
      IF Status.Angulo > (2.0 * Pi) THEN
         Status.Angulo := Status.Angulo - (2.0 * Pi);
      END IF;
   END Rotate;

   --  PRE: Cierto
   --  POST: Realiza un escalado sobre el sistema
   --        Calcula la nueva matriz (status.escala)
   --        que distorsiona el espacio
   PROCEDURE Scale (
         A,               
         B : IN     Float ) IS 
   BEGIN
      Status.Escala := Multiplicarm (Status.Escala,
         Calcularm ((A, B, Status.Angulo)));
   END Scale;
   ---------------------------------------
   --  Manejo de la pila Estados Gráficos -------------------
   ---------------------------------------
   --  PRE: Cierto
   --  POST: Salva el estado gráfico en la pila de estados gráficos.
   PROCEDURE Gsave IS 
   BEGIN
      IF NOT Pila_Ini THEN
         Pila_Estado.Crear_Vacia (Pila);
         Pila_Ini := True;
      END IF;
      Pila_Estado.Apilar (Pila, Status);
      Count_Pila := Count_Pila + 1;
   END Gsave;

   --  PRE: Cierto
   --  POST: Restaura el último estado gráfico guardado
   --        Si la pila de estados gráficos esta vacía
   --        se genera el error correspondiente.
   PROCEDURE Grestore (
         Error :    OUT Boolean ) IS 
   BEGIN
      IF Count_Pila = 0 THEN
         Error := True;
      ELSE
         Pila_Estado.Cima (Pila, Status);
         Pila_Estado.Desapilar (Pila);
         Count_Pila := Count_Pila - 1;
         Error := False;
      END IF;
   END Grestore;

   --  PRE: Se ha terminado de dibujar el archivo postscript
   --  POST: Destruye la pila de estados gráficos
   PROCEDURE Destruir_St IS 
   BEGIN
      Pila_Estado.Destruir (Pila);
   END Destruir_St;

END Bloque_Grafico;
