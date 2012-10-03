-------------------------------------------------------------------------
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------
--  010248; Roberto López Masiá; roberto.lopez.masia@hotmail.com       --
--  040289; Andres Gómez Fasbender; fass_centauri@hotmail.com          --
--  050007; Ángel Alférez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------
--
-- Descripción:
--    
--     Este módulo exporta el tipo iterador_elementos y todos los tipos
--  necesarios para su especificación. Contiene operaciones auxiliares
--  para el módulo de procesado: reconocimiento de datos extraidos del
--  fichero postscript y construcción de iteradores. Es el encargado de
--  la tabla de definiciones y exporta las operaciones necesarias para
--  guardar información en esta tabla.
----------------------------------------------------------------------------

WITH Tablas;
--  Cargamos las tablas vistas en clase (tablas hush)

PACKAGE BODY Bloque_Preparar_Operador IS

   --  PRE: Cierto
   --  POST: devuelve cierto si a y b contienen la misma información
   FUNCTION Iguales (A,B : IN Dato ) RETURN Boolean; 
   FUNCTION Iguales (A,B : IN     Dato ) RETURN Boolean IS 
   BEGIN
      RETURN A.Pal (1 .. A.Long) = B.Pal (1 .. B.Long) AND
         A.Long = B.Long;
   END Iguales;

   --  Tamaño de la tabla
   Tamano_Tabla : Integer := 30;  

   --  Instanciación de la tabla
   PACKAGE Tabla_Elementos IS NEW Tablas (
      Tipo_Clave       => Dato,                        
      Tipo_Informacion => Iterador_Elementos.Iterador, 
      Igualdad         => Iguales,                     
      Destruir         => Iterador_Elementos.Destruir, 
      Asignacion       => Iterador_Elementos.Asignar,  
      Tamano           => Tamano_Tabla);

   --  Se crea la tabla de definiciones como variable global
   Tabla : Tabla_Elementos.Tabla;  

   --  PRE: Cierto
   --  POST: Da un valor inicial a la tabla de definiciones
   PROCEDURE Iniciar_Tabla IS 
   BEGIN
      Tabla_Elementos.Crear_Vacia (Tabla);
   END Iniciar_Tabla;

   --  PRE: Cierto
   --  POST: Destruye la tabla de definiciones
   PROCEDURE Borrar_Tabla IS 
   BEGIN
      Tabla_Elementos.Destruir_Tabla (Tabla);
   END Borrar_Tabla;

   --  PRE: Cierto
   --  POST: Guarda la información i con la clave name (1..n)
   --  en la tabla de definiciones
   PROCEDURE Guardar (
         I    : IN     Iterador_Elementos.Iterador; 
         Name : IN     String;                      
         N    : IN     Integer                      ) IS 
      D : Dato;  
   BEGIN
      D.Pal (1 .. N) := Name (1 .. N);
      D.Long := N;
      Tabla_Elementos.Almacenar (Tabla, D, I);
   END Guardar;

   --  PRE: la clave name, se encuentra en la tabla
   --  POST: Devuelve la información asociada a la clave name
   FUNCTION Consultar (
         Name : Dato ) 
     RETURN Iterador_Elementos.Iterador IS 
   BEGIN
      RETURN Tabla_Elementos.Consulta (Tabla, Name);
   END Consultar;

   --  PRE: Cierto
   --  POST: La clave d se encuentra en la tabla
   
   --  para buscar las posibles definiciones ya alamcenadas 
   FUNCTION Es_Def (
         D : Dato ) 
     RETURN Boolean IS 
   BEGIN
      RETURN Tabla_Elementos.Esta (Tabla, D);
   END Es_Def;

   --  PRE: Cierto
   --  POST: Devuelve cierto si el string contenido en d
   --  es un número
   FUNCTION Es_Numero (
         D : Dato ) 
     RETURN Boolean IS 
      Y : Boolean := True;  
   BEGIN
      IF D.Long = 0 THEN
         Y := False;
      END IF;
      FOR I IN 1 .. D.Long LOOP
         IF D.Pal (I) = '.' OR D.Pal (I) = '-' THEN
            NULL;
         ELSE
            IF NOT (D.Pal (I) >= '0' AND D.Pal (I) <= '9') THEN
               Y := False;
               EXIT;
            END IF;
         END IF;
      END LOOP;
      RETURN Y;
   END Es_Numero;

   --  PRE: es_numero (d)
   --  POST: Devuelve el valor en coma flotante que representa d
   --  Nos toca transformas el dato en coma flotante para operar 
   --  con al procesarlo posteriormente. 
   FUNCTION Valor (
         D : Dato ) 
     RETURN Float IS 
      Neg,  
      Decimal : Boolean := False;  
      Cifras  : Integer := 0;  
      K       : Integer := 1;  
      Aux     : Integer;  
      Tmp     : Float   := 0.0;  
   BEGIN
      FOR Z IN 1 .. D.Long LOOP
         IF D.Pal (Z) = '-' THEN
            Neg := True;
         ELSE
            IF D.Pal (Z) = '.' THEN
               EXIT;
            ELSE
               Cifras := Cifras + 1;
            END IF;
         END IF;
      END LOOP;
      IF Neg = True THEN
         K := 2;
      END IF;
      FOR Z IN K .. D.Long LOOP
         IF D.Pal (Z) = '.' THEN
            Decimal := True;
            Cifras := 1;
         END IF;
         IF Decimal = False THEN
            Aux := Character'Pos (D.Pal (Z)) - Character'Pos ('0');
            Tmp := Tmp + Float (Aux * (10 ** (Cifras - 1)));
            Cifras := Cifras - 1;
         END IF;
         IF Decimal = True AND D.Pal (Z) /= '.' THEN
            Aux := Character'Pos (D.Pal (Z)) - Character'Pos ('0');
            Tmp := Tmp + (Float (Aux) / Float (10 ** Cifras));
            Cifras := Cifras + 1;
         END IF;
      END LOOP;
      IF Neg = True THEN
         Tmp := Tmp * (-1.0);
      END IF;
      RETURN Tmp;
   END Valor;

   --  PRE: Cierto
   --  POST: Devuelve cierto si la información contenida en d
   --        corresponde al string s
   FUNCTION Match (
         D : Dato;  
         S : String ) 
     RETURN Boolean IS 
      Z : Boolean := True;  
   BEGIN
      IF D.Long = 0 OR (D.Long /= S'Length) THEN
         RETURN False;
      END IF;
      FOR I IN 1 .. D.Long LOOP
         IF D.Pal (I) /= S (I) THEN
            Z := False;
            EXIT;
         END IF;
      END LOOP;
      RETURN Z;
   END Match;

   --  PRE: Cierto
   --  POST: Introduce el elemento correspondiente a data en el iterador 
   --  segun el tipo que sea (case)
   PROCEDURE Introducir (
         Data : IN     Dato;                       
         I    : IN OUT Iterador_Elementos.Iterador ) IS 
   BEGIN

      IF Es_Numero (Data) THEN
         Iterador_Elementos.Insertar_Dato ((Operando, Valor (Data)), I);

      ELSIF Es_Def (Data) THEN
         Iterador_Elementos.Insertar_Dato ((Definicion, Data), I);

      ELSE
         Iterador_Elementos.Insertar_Dato ((Operador, Data), I);
      END IF;

   END Introducir;

END Bloque_Preparar_Operador;