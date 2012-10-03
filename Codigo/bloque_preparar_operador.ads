-------------------------------------------------------------------------
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------
--  010248; Roberto L�pez Masi�; roberto.lopez.masia@hotmail.com       --
--  040289; Andres G�mez Fasbender; fass_centauri@hotmail.com          --
--  050007; �ngel Alf�rez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------
--
-- Descripci�n:
--    
--     Este m�dulo exporta el tipo iterador_elementos y todos los tipos
--  necesarios para su especificaci�n. Contiene operaciones auxiliares
--  para el m�dulo de procesado: reconocimiento de datos extraidos del
--  fichero postscript y construcci�n de iteradores. Es el encargado de
--  la tabla de definiciones y exporta las operaciones necesarias para
--  guardar informaci�n en esta tabla.
----------------------------------------------------------------------------

WITH Iteradores;
PACKAGE Bloque_Preparar_Operador IS

   -------------------------------
   --  Tipos para el Iterador  ----------------------------------------------
   -------------------------------

   --  Dato que se recoger� del fichero, long es el n�mero de caracteres
   --  que tiene.
   TYPE Dato IS 
      RECORD 
         Pal  : String (1 .. 20);  
         Long : Integer := 0;  
      END RECORD; 

   --  Texto que se recoger� del fichero
   TYPE Texto IS 
      RECORD 
         Txt  : String (1 .. 90);
         Long : Integer:= 0;  
      END RECORD; 

   --  tipos posibles dentro de nuestro operador (iteradores) 
   TYPE Objeto IS (Operador, Operando, Definicion, Text, Ninguno); 
   
   --  Hacemos un registro variable con los operadores y 
   --  lo que ser�a sus traducci�n palabra, numero, nada ...
   --  Con todo esta informaci�n podemos almacenar las definiciones 
   --  del fichero postscript para luego poder almacenarlo en la tabla
   TYPE Elemento 
         (Tipo : Objeto := Ninguno) IS 
      RECORD 
      CASE Tipo IS 
         WHEN Operador =>
            Dat : Dato; 
         WHEN Operando =>
            Num : Float;  
         WHEN Definicion =>
            Def : Dato;  
         WHEN Text =>
            Tx : Texto;  
         WHEN Ninguno =>
            NULL;
      END CASE;
      END RECORD;

  PACKAGE Iterador_Elementos IS NEW Iteradores (Tipo_Elemento => Elemento);
  --  Creamos nuestros iteradores de registros variables (elementos)
  --  pudiendo almacenar cualquier informacion en nuestros iteradores
  
   ----------------------------------
   --  Operaciones sobre la tabla  ----------------------------------------------
   ----------------------------------
  
  PROCEDURE Iniciar_Tabla;
  --  PRE:Cierto 
  --  POST: Inicializar tabla vac�a
   PROCEDURE Borrar_Tabla; 
  --  Destruye todos los elementos de la tabla
  FUNCTION Consultar (
        Name : Dato ) 
    RETURN Iterador_Elementos.Iterador; 
  --  PRE: El dato debe estar en la tabla.
  --  POST: Devuelve la informaci�n asociada a la clave que se consulta
  
  PROCEDURE Guardar (
      I    : IN     Iterador_Elementos.Iterador; 
      Name : IN     String;                      
      N    : IN     Integer   
                   ); 
                   
  --  PRE:Cierto (depende del TAD tablas que usemos)
  --  POST: Inicializar tabla vac�a
  --  Almacena en la tabla la clave  (name, n) y la informaci�n asociada
  --  (el iterador i)

  

  FUNCTION Es_Def (
        D : Dato ) 
    RETURN Boolean; 
  --  Devuelve cierto si d es una clave almacenada en la tabla

  FUNCTION Es_Numero (
      D : Dato ) 
    RETURN Boolean; 
  --  Devuelve cierto si el string que contiene d
  --  contiene informaci�n num�rica
  --  Por ejemplo ser�a True si d fuera ("-300.27....", 7)

  FUNCTION Valor (
      D : Dato ) 
  RETURN Float; 
  --  PRE: es_numero (d)
  --  POST: Devuelve el valor de d como un Float

  FUNCTION Match (
      D : Dato;  
      S : String ) 
  RETURN Boolean; 
  --  Devuelve cierto si la informaci�n que contiene d
  --  coincide con el string s
  --  (palabras clave )Por ejemplo ser�a True si d fuera ("rotate....", 16)

  PROCEDURE Introducir (
      Data : IN     Dato;                       
      I    : IN OUT Iterador_Elementos.Iterador ); 
  --  Introduce el elemento correspondiente a data en el iterador i
 

END Bloque_Preparar_Operador;
