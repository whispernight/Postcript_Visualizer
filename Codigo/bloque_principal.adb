-------------------------------------------------------------------------  
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------                              
--  010248; Roberto López Masiá; roberto.lopez.masia@hotmail.com       --
--  040289; Andres Gómez Fasbender; fass_centauri@hotmail.com          --
--  050007; Ángel Alférez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------
--  Este módulo exporta dos procedimientos que sirven para ocultar o cerrar
--  la ventana destinada a la visualización del archivo postscript.
--
--  Su principal función es leer el fichero postscript cogiendo elemento
--  a elemento evaluando cada uno y llevando a cabo la acción correspondiente.
-- -------------------------------------------------------------------------

with Bloque_Grafico;
use Bloque_Grafico;
--WITH JEWL.Simple_Windows;
--USE  JEWL.Simple_Windows;
with Bloque_Preparar_Operador;
use Bloque_Preparar_Operador;
with Ada.Text_Io;
use Ada.Text_Io;
with Pilas;
with Ada.Unchecked_Deallocation;

package body Bloque_Principal is


   --  ***********************************************************************
   --  ----------------- Declaración de tipos para la pila -------------------
   --  ***********************************************************************

   type Puntero_Codigo is access Iterador_Elementos.Iterador; 
   --  Puntero a Iterador

   procedure Libera_Puntero is 
   new Ada.Unchecked_Deallocation (
      Object => Iterador_Elementos.Iterador, 
      Name   => Puntero_Codigo);
   --  Procedimiento para liberar Puntero_Iterador

   type Objeto_Pila is 
         (Operando_Pila, 
          Codigo,        
          Bool_Pila,     
          Palabra_Pila,  
          Ninguno); 


   --  Tipos que se podrán encontrar en la pila
   --   Definicion de la pila y de los tipos que se almacenan en ella (de forma similar a ITERADOR)

   type Elemento_Pila
      (Tipo : Objeto_Pila := Ninguno) is
   record
      case Tipo is
         when Operando_Pila =>
            Num : Float;
         when Codigo =>
            Cod : Puntero_Codigo := null;
         when Bool_Pila =>
            Bool : Boolean;
         when Palabra_Pila =>
            Pal : Texto;
         when Ninguno =>
            null;
      end case;
   end record;
   --  Elemento_Pila es un registro variante, según que tipo tendremos
   --  un campo distinto

   package Pila_Elementos is new Pilas (Tipo_Elemento => Elemento_Pila);

   --  PRE: Cierto z es el último caracter de la palabra cogida anteriormente
   --  POST: Coge del fichero el siguiente elemento significativo del archivo
   --        postscript. Omite los comentarios
   --
   --   DATO => Pal:string X long:Natural

   procedure Coger (
         Fichero : in out File_Type; 
         A       : in out Dato;      
         Z       : in out Character  ); 
   procedure Coger (
         Fichero : in out File_Type; 
         A       : in out Dato;      
         Z       : in out Character  ) is 

      C       : Character := ' ';  
      Termina : Boolean   := False;  

   begin
      A.Long := 0;

      -- Evaluamos el caracter "z" de entrada si "z"= { or} then a=["{",1] or a=["}", 1]
      if Z = '}' or Z = '{' then
         Termina := True;
         A.Long := 1;
         A.Pal (1) := Z;
         C := '?';
         Z := '?';
      end if;

      -- Saltamos los espacios en blanco
      while not End_Of_File (Fichero) and C = ' ' loop
         Get (Fichero, C);
      end loop;
      loop
         -- Si encontramos un comentario, eliminamos toda la linea
         if C = '%' then
            while not End_Of_File (Fichero) and
                  not End_Of_Line (Fichero) loop
               Get (Fichero, C);
            end loop;
            if End_Of_File (Fichero) then
               Termina := True;
               exit;
            else
               Get (Fichero, C);
            end if;
         else
            exit;
         end if;
      end loop;
      -- Sino es un comentario sera un elemento util
      while (C /= ' ') and (Termina = False) loop
         A.Long := A.Long + 1;
         A.Pal (A.Long) := C;
         if End_Of_Line (Fichero) or End_Of_File (Fichero) or C = '{'
               or C = '/' or C = '}' or C = '(' then
            Termina := True;
         else
            Get (Fichero, C);
            Z := C;
         end if;
         if C = '}' or C = '{' then
            Termina := True;
         end if;
      end loop;

   end Coger;


   --  PRE: Nos hemos encontrado un '(' en el fichero
   --  POST: Coge una cadena de caracteres del fichero
   --        hasta encontrarse un ')'

   --recordatorio: TEXTO=[Tx:String, Long:Natural]

   procedure Coger_Txt (
         Fichero : in out File_Type; 
         A       : in out Texto      ); 
   procedure Coger_Txt (
         Fichero : in out File_Type; 
         A       : in out Texto      ) is 
      C : Character := '?';  
   begin
      A.Long := 0;
      loop
         Get (Fichero, C);
         if C = ')' then
            exit;
         else
            A.Long := A.Long + 1;
            A.Txt (A.Long) := C;
         end if;
      end loop;
   end Coger_Txt;

   --  PRE: Cierto
   --  POST: Cierra el frame iniciado en el modulo de pintado
   procedure Cerrar is 
   begin
      Pclose;
   end Cerrar;

   --  PRE: Cierto
   --  POST: Oculta el frame iniciado en el modulo de pintado
   procedure Ocultar is 
   begin
      Phide;
   end Ocultar;

   --  PRE: Data no es ni un operador de control ni una definición
   --  POST: Procesa la información de data, si es un operando lo introduce
   --        en la pila, si es un operador este se evalua y se toman
   --        (y se dejan) los argumentos necesarios de la pila.
   --        Si ha existido algún error durante el proceso se da un valor
   --        a numerror distinto de cero.
   --        Los posibles valores son :
   --
   --   0     No hay error.
   --   1     Se ha encontrado un dato inválido
   --         no es un operando ni un operador postscript.
   --   2     Intento de acceder a una pila vacía.
   --   3     Se encontraron operandos de tipo inesperado.
   --   4     Se intenta trazar un camino nuevo sin haber establecido origen.
   --   5     Se intenta acceder a la pila de estados gráficos cuando esta vacía.
   procedure Procesar (
         Data     : in     Dato;                
         Pila     : in out Pila_Elementos.Pila; 
         Numerror :    out Integer              ); 
   procedure Procesar (
         Data     : in     Dato;                
         Pila     : in out Pila_Elementos.Pila; 
         Numerror :    out Integer              ) is 
      Elem1,  
      Elem2  : Elemento_Pila;  
      Errorp : Boolean;  
      Count  : Integer;  
   begin
      --Sacamos el numero de elementos que tiene la pila
      Count := Pila_Elementos.Num_Elementos (Pila);
      --inicializamos numerror como 0 (sin errores)
      Numerror := 0;
      if Data.Long = 0 then
         null;
         --si DATA es un numero, lo apilamos
      elsif Es_Numero (Data) then
         Elem1 := (Operando_Pila, Valor (Data));
         Pila_Elementos.Apilar (Pila, Elem1);
         --si el texto contenido en DATA es "newpath" salto a la funcion newpath
      elsif Match (Data, "newpath") then
         New_Path;
         --moveto necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos moveto
      elsif Match (Data, "moveto") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Moveto (Elem2.Num, Elem1.Num);
            end if;
         end if;
         -- rmoveto necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos rmoveto (que puede dar error), si rmoveto a generado
         --error---> "errorp=TRUE", tendremos un error 4
      elsif Match (Data, "rmoveto") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Rmoveto (Elem2.Num, Elem1.Num, Errorp);
               if Errorp then
                  Numerror := 4;
               end if;
            end if;
         end if;
         --lineto necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos lineto (que puede dar error), si lineto a generado
         --error---> "errorp=TRUE", tendremos un error 4
      elsif Match (Data, "lineto") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Lineto (Elem2.Num, Elem1.Num, Errorp);
               if Errorp then
                  Numerror := 4;
               end if;
            end if;
         end if;
         --rlineto necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos rlineto (que puede dar error), si rlineto a generado
         --error---> "errorp=TRUE", tendremos un error 4
      elsif Match (Data, "rlineto") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Rlineto (Elem2.Num, Elem1.Num, Errorp);
               if Errorp then
                  Numerror := 4;
               end if;
            end if;
         end if;
         --si el texto contenido de DATA coincide con "closepath" procesamos closepath
      elsif Match (Data, "closepath") then
         Close_Path;
         --si el texto contenido de DATA coincide con "stroke" procesamos stroke
      elsif Match (Data, "stroke") then
         Stroke;
         --rotate necesita 1 paramtro, por lo que en la pila debe haber camo minimo 1 elemento
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos rotate
      elsif Match (Data, "rotate") then
         if Count < 1 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Rotate (Elem1.Num);
            end if;
         end if;
         --scale necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos scale
      elsif Match (Data, "scale") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Scale (Elem2.Num, Elem1.Num);
            end if;
         end if;
         --show necesita 1 paramtro, por lo que en la pila debe haber camo minimo 1 elemento
         --sino error 2; teniendo que ser éstos de tipo "palabra_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos chow (lo llamamos asi, porque "show" es palablra
         --reservada del lenguaje ADA)
      elsif Match (Data, "show") then
         if Count < 1 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Palabra_Pila then
               Numerror := 3;
            else
               Chow (Elem1.Pal.Txt (1 .. Elem1.Pal.Long));
            end if;
         end if;
         --setlinewidth necesita 1 paramtro, por lo que en la pila debe haber camo minimo 1 elemento
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos setlinewidth
      elsif Match (Data, "setlinewidth") then
         if Count < 1 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Set_Width (Elem1.Num);
            end if;
         end if;
         --setgray necesita 1 paramtro, por lo que en la pila debe haber camo minimo 1 elemento
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos setgray
      elsif Match (Data, "setgray") then
         if Count < 1 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Set_Gray (Elem1.Num);
            end if;
         end if;
         --translate necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien procesamos translate
      elsif Match (Data, "translate") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Translate (Elem2.Num, Elem1.Num);
            end if;
         end if;
         --si el texto contenido de DATA coincide con "gsave" procesamos gsave
      elsif Match (Data, "gsave") then
         Gsave;
         --si el texto contenido de DATA coincide con "grestore" procesamos grestore
      elsif Match (Data, "grestore") then
         Grestore (Errorp);
         if Errorp then
            Numerror := 5;
         end if;
         --def necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo==>Elem1="codigo",Elem2="Palabra_Pila",
         --sino Error 3, en caso de que todo vaya bien procesamos def
      elsif Match (Data, "def") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);  -- Iterador
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);  -- Nombre def
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Codigo or
                  Elem2.Tipo /= Palabra_Pila then
               Numerror := 3;
            else
               Guardar (Elem1.Cod.All, Elem2.Pal.Txt, Elem2.Pal.Long);
            end if;
         end if;
         --si el texto contenido de DATA coincide con "showpage" procesamos showpage
      elsif Match (Data, "showpage") then
         Showpage;
         --add necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien apilamos [operando_pila, Elem1+Elem2]
      elsif Match (Data, "add") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Pila_Elementos.Apilar (Pila,
                  (Operando_Pila, Elem2.Num + Elem1.Num));
            end if;
         end if;
         --sub necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien apilamos [operando_pila, Elem2-Elem1]
      elsif Match (Data, "sub") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Pila_Elementos.Apilar (Pila,
                  (Operando_Pila, Elem2.Num - Elem1.Num));
            end if;
         end if;
         --mul necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien apilamos [operando_pila, Elem2·Elem1]
      elsif Match (Data, "mul") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Pila_Elementos.Apilar (Pila,
                  (Operando_Pila, Elem2.Num * Elem1.Num));
            end if;
         end if;
         --div necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien apilamos [operando_pila, Elem2/Elem1]
      elsif Match (Data, "div") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Pila_Elementos.Apilar (Pila,
                  (Operando_Pila, Elem2.Num / Elem1.Num));
            end if;
         end if;
         --idiv necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien apilamos [operando_pila, Integer(Elem2)/Elem1]  (con casting)
      elsif Match (Data, "idiv") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Pila_Elementos.Apilar (Pila,
                  (Operando_Pila,
                     Float (Integer (Elem2.Num) / Integer (Elem1.Num))));
            end if;
         end if;
         --mod necesita 2 paramtros, por lo que en la pila debe haber camo minimo 2 elementos
         --sino error 2; teniendo que ser éstos de tipo "operando_pila", sino Error 3, en caso
         --de que todo vaya bien apilamos [operando_pila, Integer(Elem2) mod Elem1]
      elsif Match (Data, "mod") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               Pila_Elementos.Apilar (Pila,
                  (Operando_Pila,
                     Float (Integer (Elem2.Num) MOD Integer (Elem1.Num))));
            end if;
         end if;
         --Vaciamos la pila, si la cima de la pila es de tipo codigo se elimina ése elemento tambien
         --de la tabla de iteradores
      elsif Match (Data, "clear") then
         while not (Pila_Elementos.Es_Vacia (Pila)) loop
            Pila_Elementos.Cima (Pila, Elem1);
            if Elem1.Tipo = Codigo then
               Iterador_Elementos.Destruir (Elem1.Cod.All);
               Libera_Puntero (Elem1.Cod);
            end if;
            Pila_Elementos.Desapilar (Pila);
         end loop;
         --dup necesita 1 parametro en la pila sino error 2, copiamos ese elemento (en elem1) y lo
         --volvemos a meter en la pila de modo que queda dupicado en la pila
      elsif Match (Data, "dup") then
         if Count < 1 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Apilar (Pila, Elem1);
         end if;
         --exch necesita 2 parametros en la pila sino error 2, los desapilamos (en elem1 y elem2)
         --y los volvemos a apilar en orden inverso
      elsif Match (Data, "exch") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Apilar (Pila, Elem1);
            Pila_Elementos.Apilar (Pila, Elem2);
         end if;
         --pop necesita 1 parametro en la pila sino error 2, miramos la cima de la pila (elem1)
         --lo desapilamos y en caso de que sea de tipo codigo, tambien lo eliminamos de la tabla
         --de iteradores
      elsif Match (Data, "pop") then
         if Count < 1 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            if Elem1.Tipo = Codigo then
               Iterador_Elementos.Destruir (Elem1.Cod.All);
               Libera_Puntero (Elem1.Cod);
            end if;
            Pila_Elementos.Desapilar (Pila);
         end if;
         --roll necesita 2 parametros en la pila sino error 2, desapilamos las parametros en elem1
         --y elem2 debiendo ser éstos de tipo "operando_pila" sino error 3
         --si el numero de elementos que quedan en la pila es menor a (2+Elem2.num) error 2,
         --si todo va bien rotamos la pila en funcion de elem1 y elem2 (con casting a integer)
      elsif Match (Data, "roll") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);  -- j
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);  -- n
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               if Count < (2 + Integer (Elem2.Num)) then
                  Numerror := 2;
               else
                  Pila_Elementos.Rotar (Pila,
                     Integer (Elem2.Num),
                     Integer (Elem1.Num));
               end if;
            end if;
         end if;
         --eq necesita 2 parametros en la pila sino error 2, desapilamos en elem1 y elem2 y miramos
         --si son del mismo tipo apilando en pila [bool_pila, TRUE] si lo son y tienen el mismo
         --valor y [bool_pila, FALSE] si no lo son o no tiene el mismo valor
      elsif Match (Data, "eq") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Elem2.Tipo then
               Pila_Elementos.Apilar (Pila, (Bool_Pila, False));
            else
               case Elem1.Tipo is
                  when Bool_Pila =>
                     Pila_Elementos.Apilar (Pila,
                        (Bool_Pila, (Elem1.Bool = Elem2.Bool)));
                  when Operando_Pila =>
                     Pila_Elementos.Apilar (Pila,
                        (Bool_Pila, (Elem1.Num = Elem2.Num)));
                  when Codigo =>
                     Pila_Elementos.Apilar (Pila,
                        (Bool_Pila, (Elem1.Cod = Elem2.Cod)));
                  when Palabra_Pila =>
                     Pila_Elementos.Apilar (Pila,
                        (Bool_Pila, (Elem1.Pal = Elem2.Pal)));
                  when Ninguno =>
                     null;
               end case;
            end if;
         end if;
         --ne necesita 2 parametros en la pila sino error 2, desapilamos en elem1 y elem2 y miramos
         --si NO son del mismo tipo apilando en pila [bool_pila, TRUE] si son  de tipo distinto
         --en caso de ser del mismo tipo, miramos si su valor es distinto, en tal caso apilamos
         --[bool_pila, TRUE], si su valor es igual [bool_pila, FALSE]
      elsif Match (Data, "ne") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Elem2.Tipo then
               Pila_Elementos.Apilar (Pila, (Bool_Pila, True));
            else
               case Elem1.Tipo is
                  when Bool_Pila =>
                     Pila_Elementos.Apilar (Pila,
                        (Bool_Pila, (not (Elem1.Bool = Elem2.Bool))));
                  when Operando_Pila =>
                     Pila_Elementos.Apilar (Pila,
                        (Bool_Pila, (not (Elem1.Num = Elem2.Num))));
                  when Codigo =>
                     Pila_Elementos.Apilar (Pila,
                        (Bool_Pila, (not (Elem1.Cod = Elem2.Cod))));
                  when Palabra_Pila =>
                     Pila_Elementos.Apilar (Pila,
                        (Bool_Pila, (not (Elem1.Pal = Elem2.Pal))));
                  when Ninguno =>
                     null;
               end case;
            end if;
         end if;
         --gt necesita 2 parametros en la pila sino error 2, desapilamos en elem1 y elem2 y miramos
         --si son del tipo "operando_pila" sino error 3
         --en caso de ser del mismo tipo, miramos si elem2.num > elem1.num si es asi apilamos
         --[bool_pila, TRUE], en caso cantrario [bool_pila, FALSE]
      elsif Match (Data, "gt") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               if Elem2.Num > Elem1.Num then
                  Pila_Elementos.Apilar (Pila, (Bool_Pila, True));
               else
                  Pila_Elementos.Apilar (Pila, (Bool_Pila, False));
               end if;
            end if;
         end if;
         --ge necesita 2 parametros en la pila sino error 2, desapilamos en elem1 y elem2 y miramos
         --si son del tipo "operando_pila" sino error 3
         --en caso de ser del mismo tipo, miramos si elem2.num >= elem1.num si es asi apilamos
         --[bool_pila, TRUE], en caso cantrario [bool_pila, FALSE]
      elsif Match (Data, "ge") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               if Elem2.Num >= Elem1.Num then
                  Pila_Elementos.Apilar (Pila, (Bool_Pila, True));
               else
                  Pila_Elementos.Apilar (Pila, (Bool_Pila, False));
               end if;
            end if;
         end if;
         --lt necesita 2 parametros en la pila sino error 2, desapilamos en elem1 y elem2 y miramos
         --si son del tipo "operando_pila" sino error 3
         --en caso de ser del mismo tipo, miramos si elem2.num < elem1.num si es asi apilamos
         --[bool_pila, TRUE], en caso cantrario [bool_pila, FALSE]
      elsif Match (Data, "lt") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               if Elem2.Num < Elem1.Num then
                  Pila_Elementos.Apilar (Pila, (Bool_Pila, True));
               else
                  Pila_Elementos.Apilar (Pila, (Bool_Pila, False));
               end if;
            end if;
         end if;
         --le necesita 2 parametros en la pila sino error 2, desapilamos en elem1 y elem2 y miramos
         --si son del tipo "operando_pila" sino error 3
         --en caso de ser del mismo tipo, miramos si elem2.num <= elem1.num si es asi apilamos
         --[bool_pila, TRUE], en caso cantrario [bool_pila, FALSE]
      elsif Match (Data, "le") then
         if Count < 2 then
            Numerror := 2;
         else
            Pila_Elementos.Cima (Pila, Elem1);
            Pila_Elementos.Desapilar (Pila);
            Pila_Elementos.Cima (Pila, Elem2);
            Pila_Elementos.Desapilar (Pila);
            if Elem1.Tipo /= Operando_Pila or
                  Elem2.Tipo /= Operando_Pila then
               Numerror := 3;
            else
               if Elem2.Num <= Elem1.Num then
                  Pila_Elementos.Apilar (Pila, (Bool_Pila, True));
               else
                  Pila_Elementos.Apilar (Pila, (Bool_Pila, False));
               end if;
            end if;
         end if;
         --sino ha sido ninguna de las operaciones anteriores error 1
      else
         Numerror := 1;
      end if;

   end Procesar;


   --  PRE: Cierto
   --  POST: Procesa un trozo de código postscript contenido en un iterador
   --        Si se trata de un bucle stop pasa a ser cierto cuando encontramos
   --        la sentencia "exit"
   --        error devuelve el número de error encontrado. Si no hubo ninguno
   --        entonces error 0
   procedure Leer_Iterador (
         I     : in out Iterador_Elementos.Iterador; 
         Pila  : in out Pila_Elementos.Pila;         
         Stop  : in out Boolean;                     
         Error :    out Integer                      ); 
   procedure Leer_Iterador (
         I     : in out Iterador_Elementos.Iterador; 
         Pila  : in out Pila_Elementos.Pila;         
         Stop  : in out Boolean;                     
         Error :    out Integer                      ) is 

      Elem     : Elemento;  
      Auxi     : Iterador_Elementos.Iterador;  
      Puntero  : Puntero_Codigo              := null;  
      C        : Integer                     := 0;  
      Contador : Integer;  
      Elem1,  
      Elem2,  
      Elem3    : Elemento_Pila;  

   begin
      --ponemos el campo del interdor ACTUAL = Primero
      Iterador_Elementos.Iniciar (I);
      --creamos una tabla de iteradores auxiliar
      Iterador_Elementos.Crear_Iterador (Auxi);
      --condicion de parada
      Stop := False;
      --error de salida (inicializado a correcto)
      Error := 0;
      loop
         --OPERANDO
         --hacemos una copia del primer elemento de la tabla para trabajar con él (elem)
         Elem := Iterador_Elementos.Dato_Actual (I);
         --si Elem es de tipo "operando" apilamos en pila como [Operando_pila, Elem.num]
         if Elem.Tipo = Operando then
            Pila_Elementos.Apilar (Pila, (Operando_Pila, Elem.Num));

            --DEFINICION
            --si Elem es de tipo "Definicion" asignamos a AUXI el iterador de la definicion
            --y llamamos a Leer_iterador para procesar el iterador AUXI
         elsif Elem.Tipo = Definicion then
            Iterador_Elementos.Asignar (Auxi, Consultar (Elem.Def));
            Leer_Iterador (Auxi, Pila, Stop, Error);

            --TEXT
            --si Elem es de tipo "text" lo apilamos como [palabra_pila, elem.tx]
         elsif Elem.Tipo = Text then
            Pila_Elementos.Apilar (Pila, (Palabra_Pila, Elem.Tx));

            --sino es ninguna de las anteriores es un OPERADOR
         else
            --si Elem es "{" entonces tendremos que construir un iterador (auxi) con todo lo
            --almacenado dentro de las llaves, llevando la cuenta del valanceo de las llaves (c)
            if Elem.Dat.Pal (1) = '{' then
               C := 1;
               Iterador_Elementos.Crear_Iterador (Auxi);
               loop
                  Iterador_Elementos.Siguiente (I);
                  Elem := Iterador_Elementos.Dato_Actual (I);
                  if Elem.Tipo = Operador then
                     if Elem.Dat.Pal (1) = '{' then
                        C := C + 1;
                     elsif Elem.Dat.Pal (1) = '}' then
                        C := C - 1;
                     end if;
                     if C = 0 then
                        exit;
                     else
                        Iterador_Elementos.Insertar_Dato (Elem, Auxi);
                     end if;
                  else
                     Iterador_Elementos.Insertar_Dato (Elem, Auxi);
                  end if;
               end loop;
               --hacemos una copia del iterador Auxi que contiene todo lo que se encuentra entre
               --llaves en "puntero", liberamos Auxi y apilamos [codigo, puntero] y una vez
               --apilado el codigo puntero=NULL
               Puntero := new Iterador_Elementos.Iterador;
               Iterador_Elementos.Asignar (Puntero.All, Auxi);
               Iterador_Elementos.Crear_Iterador (Auxi);
               Pila_Elementos.Apilar (Pila, (Codigo, Puntero));
               Puntero := null;
            else

               --EXIT
               --en el caso de que elem.dat sea "exit" terminamos
               if Match (Elem.Dat, "exit") then
                  Stop := True;
                  exit;

                  --LOOP
                  --si elem.dat es "loop", tendremos que construir un iterador (auxi) con todo lo
                  --que contiene el bucle, para ello simplemente asignamos a auxi el siguiente
                  --elemento almacenado en la pila, llamando a Leer_iterador con Auxi hasta
                  --encontrar que stop=TRUE
               elsif Match (Elem.Dat, "loop") then
                  Pila_Elementos.Cima (Pila, Elem1);
                  Iterador_Elementos.Asignar (Auxi, Elem1.Cod.All);
                  loop
                     Leer_Iterador (Auxi, Pila, Stop, Error);
                     if Stop then
                        exit;
                     end if;
                  end loop;
                  Iterador_Elementos.Destruir (Auxi);
                  Libera_Puntero (Elem1.Cod);
                  Pila_Elementos.Desapilar (Pila);

                  --REPEAT
                  --cogemos el primer y segundo elemento de la pila (elem1 y elem2), siendo el
                  --numero de repeticiones elem2.num, y elem1 sera un puntero que señale al
                  --codigo que debemos repetir (se lo asignaremos a AUXI), llamando tantas veces
                  --como se selicite a Leer_iterador, destruiremos auxi, liberamos el puntero y
                  --deasapilamos 2 veces
               elsif Match (Elem.Dat, "repeat") then
                  Pila_Elementos.Cima (Pila, Elem1);
                  Pila_Elementos.Segundo (Pila, Elem2);
                  Contador := Integer (Elem2.Num);
                  Iterador_Elementos.Asignar (Auxi, Elem1.Cod.All);
                  while Contador /= 0 loop
                     Leer_Iterador (Auxi, Pila, Stop, Error);
                     Contador := Contador - 1;
                     if Stop then
                        Contador := 0;
                     end if;
                  end loop;
                  Iterador_Elementos.Destruir (Auxi);
                  Libera_Puntero (Elem1.Cod);
                  Pila_Elementos.Desapilar (Pila);
                  Pila_Elementos.Desapilar (Pila);

                  --IF
                  --cogemos el primer y segundo elemento de la pila (elem1 y elem2), elem1 sera
                  --un puntero que señale al codigo que debemos procesar (se lo asignaremos a AUXI)
                  --elem2 sera la condicion booleana, en caso de que se cumpla, procesaremos el
                  --codigo señalado por Auxi llamando a Leer_iterador,destruiremos auxi,
                  --liberamos el puntero y deasapilamos 2 veces
               elsif Match (Elem.Dat, "if") then
                  Pila_Elementos.Cima (Pila, Elem1);  --  iterador
                  Pila_Elementos.Segundo (Pila, Elem2);  --  booleano
                  Iterador_Elementos.Asignar (Auxi, Elem1.Cod.All);
                  if Elem2.Bool then
                     Leer_Iterador (Auxi, Pila, Stop, Error);
                  end if;
                  Iterador_Elementos.Destruir (Auxi);
                  Libera_Puntero (Elem1.Cod);
                  Pila_Elementos.Desapilar (Pila);
                  Pila_Elementos.Desapilar (Pila);

                  --IFELSE
                  --cogemos el primer y segundo y el tercer elemento de la pila (elem1, elem2 y elem3)
                  --elem3 sera la condicion booleana, elem2 señala al codigo del "IF" y elem1 al codigo
                  --del "ELSE", de forma que si se cumple la condicion booleana procesimamos elem2 y
                  --sino el codigo de elem1, asignadoselo a Auxi y llamando a Leer_iterador
                  --destruimos iteradores, liberamos punteros y deasapilamos 3 veces
               elsif Match (Elem.Dat, "ifelse") then
                  Pila_Elementos.Cima (Pila, Elem1);  --  iteradorF
                  Pila_Elementos.Segundo (Pila, Elem2);  --  iteradorT
                  Pila_Elementos.Tercero (Pila, Elem3);  --  booleano
                  if Elem3.Bool then
                     Iterador_Elementos.Asignar (Auxi, Elem2.Cod.All);
                     Leer_Iterador (Auxi, Pila, Stop, Error);
                  else
                     Iterador_Elementos.Asignar (Auxi, Elem1.Cod.All);
                     Leer_Iterador (Auxi, Pila, Stop, Error);
                  end if;
                  Iterador_Elementos.Destruir (Elem1.Cod.All);
                  Libera_Puntero (Elem1.Cod);
                  Iterador_Elementos.Destruir (Elem2.Cod.All);
                  Libera_Puntero (Elem2.Cod);
                  Pila_Elementos.Desapilar (Pila);
                  Pila_Elementos.Desapilar (Pila);
                  Pila_Elementos.Desapilar (Pila);

                  --si no es ninguna de las anteriores procesamos

               else
                  Procesar (Elem.Dat, Pila, Error);
               end if;
            end if;
         end if;
         --si hay mas elementos en la tabla de iteradores avanzamos al siguiente elemento
         if Iterador_Elementos.Hay_Siguiente (I) then-----------------------------------------------------------------
            Iterador_Elementos.Siguiente (I);
            --si no hay mas elementos en la tabla de iteradores, hemos terminado
         else
            exit;
         end if;
         --si error es distinto a 0 se produjo un error, por tanto salimos
         if Error /= 0 then
            exit;
         end if;
      end loop;
      --cuando hemos terminado de Leer el iterador Actual=Primero
      Iterador_Elementos.Iniciar (I);
   end Leer_Iterador;
















   procedure Leer_Postscript_Aux (
      Entrada : in out File_Type;
      I       : in out Iterador_Elementos.Iterador;
         Error   : in out Integer ) is 
            
      Pal1     : Dato;  
      B        : Character;    
      A        : Integer                     := 0;  
      Contador : Integer;  
      Stop     : Boolean                     := False;     
      Puntero  : Puntero_Codigo              := null;  
      Elem1,  
      Elem2,  
      Elem3    : Elemento_Pila;  
      T        : Texto;  
      Pila     : Pila_Elementos.Pila;

   begin
      
      Pila_Elementos.Crear_Vacia (Pila);
      
put_line("Entramos en Leer_postscript_aux!!!!");
         B := '?';
      A := 0;
            
      --limpiar;
         --construiremos el iterador en funcion del texto almacenado en el fichero
      while not End_Of_File (Entrada) and not Match (Pal1, "showpage") loop
 --put_line("Entra!");
pal1.pal (1..20):= "                    ";
            --cogemos una palabra
         Coger (Entrada, Pal1, B);
Put_Line(Pal1.Pal);
--put_line("bucle ps_aux");         

       
            --si empieza por "/" sera el comienzo de una funcion propia
            if Pal1.Pal (1) = '/' then
               --cogemos la siguiente, la guardamos en t y la apilamos como [Palabra_Pila, t]
               --sera el nombre de la funcion
--put_line("Entra /");               
               Coger (Entrada, Pal1, B);
               T.Txt (1 .. Pal1.Long) := Pal1.Pal (1 .. Pal1.Long);
               T.Long := Pal1.Long;
               Pila_Elementos.Apilar (Pila, (Palabra_Pila, T));
            loop
--put_line("procesa /");
                  --empezamos a evaluar el codigo de la funcion tratada
                  Coger (Entrada, Pal1, B);
                  --valanceamos las llaves
               if Pal1.Pal (1) = '{' then
--put_line("        procesa {");
                     A := A + 1;
               elsif Pal1.Pal (1) = '}' then
--put_line("        procesa }");
                     A := A - 1;
                  end if;
                  --si es el comienzo de la funcion o el final, no hacemos nada
                  if  (A = 1 and Pal1.Pal (1) = '{') or
                        (A = 0 and Pal1.Pal (1) = '}') then
                     null;
                  else
                     --si la palabra evaluada empieza por "("
                  if Pal1.Pal (1) = '(' then
--put_line("        procesa (");
                        --cogemos lo que hay dentro (T)
                        Coger_Txt (Entrada, T);
                        --lo introducimos en el iterador como [Text, T]
                        Iterador_Elementos.Insertar_Dato ((Text, T), I);
                        --si no comienza por "(", introducimos Pal1 en la tabla de iteradores
                     else
                        Introducir (Pal1, I);
                     end if;
                  end if;
                  --si ya hemos evaluado toda la funcion (a=0) salimos
                  if A = 0 then
                     exit;
                  end if;
               end loop;
               --apilamos el codigo de la funcion (alamacendo en I) [codigo, puntero]
               --y liberamos puntero
               Puntero := new Iterador_Elementos.Iterador;
               Iterador_Elementos.Asignar (Puntero.All, I);
               Iterador_Elementos.Crear_Iterador (I);
               Pila_Elementos.Apilar (Pila, (Codigo, Puntero));
               Puntero := null;
               --evaluamos lo que se encuentra entre llaves
         elsif Pal1.Pal (1) = '{' then
--put_line("procesa {");
               A := 1;
            loop
--put_line("        procesa lo k hay dentro{");
                  Coger (Entrada, Pal1, B);
                  --calculamos el valanceo
                  if Pal1.Pal (1) = '{' then
                     A := A + 1;
                  elsif Pal1.Pal (1) = '}' then
                     A := A - 1;
                  end if;
                  --si esta valanceado no hacemos nada
                  if A = 0 and Pal1.Pal (1) = '}' then
                     null;
               else
--put_line("        procesa {    y es (");
                     if Pal1.Pal (1) = '(' then
                        Coger_Txt (Entrada, T);
                        Iterador_Elementos.Insertar_Dato ((Text, T), I);
                     else
                        Introducir (Pal1, I);
                     end if;
                  end if;

                  if A = 0 then
                     exit;
                  end if;
               end loop;
               Puntero := new Iterador_Elementos.Iterador;
               Iterador_Elementos.Asignar (Puntero.All, I);
               Iterador_Elementos.Crear_Iterador (I);
               Pila_Elementos.Apilar (Pila, (Codigo, Puntero));
               Puntero := null;

         elsif Pal1.Pal (1) = '(' then
--put_line("procesa (");
               Coger_Txt (Entrada, T);
               Pila_Elementos.Apilar (Pila, (Palabra_Pila, T));

         elsif Es_Def (Pal1) then
--put_line("procesa es def");            
               Iterador_Elementos.Asignar (I, Consultar (Pal1));
               Leer_Iterador (I, Pila, Stop, Error);

            elsif Match (Pal1, "loop") then
--put_line("procesa loop");
               Pila_Elementos.Cima (Pila, Elem1);
               Iterador_Elementos.Asignar (I, Elem1.Cod.All);
               loop
                  Leer_Iterador (I, Pila, Stop, Error);
                  if Stop then
                     exit;
                  end if;
               end loop;
               Iterador_Elementos.Destruir (I);
               Libera_Puntero (Elem1.Cod);
               Pila_Elementos.Desapilar (Pila);

            elsif Match (Pal1, "repeat") then

--Put_Line("procesa repeat");
               Pila_Elementos.Cima (Pila, Elem1);
               Pila_Elementos.Segundo (Pila, Elem2);
               Contador := Integer (Elem2.Num);
               Iterador_Elementos.Asignar (I, Elem1.Cod.All);
            while Contador /= 0 loop
--put_line("        procesa interior repeat");
                  Leer_Iterador (I, Pila, Stop, Error);
                  Contador := Contador - 1;
                  if Stop then
                     Contador := 0;
                  end if;
               end loop;
               Iterador_Elementos.Destruir (I);
               Libera_Puntero (Elem1.Cod);
               Pila_Elementos.Desapilar (Pila);
               Pila_Elementos.Desapilar (Pila);

         elsif Match (Pal1, "if") then
--put_line("procesa if");
               Pila_Elementos.Cima (Pila, Elem1);  --  iterador
               Pila_Elementos.Segundo (Pila, Elem2);  --  booleano
               Iterador_Elementos.Asignar (I, Elem1.Cod.All);
               if Elem2.Bool then
                  Leer_Iterador (I, Pila, Stop, Error);
               end if;
               Iterador_Elementos.Destruir (I);
               Libera_Puntero (Elem1.Cod);
               Pila_Elementos.Desapilar (Pila);
               Pila_Elementos.Desapilar (Pila);

         elsif Match (Pal1, "ifelse") then
--put_line("procesa {ifelse");
               Pila_Elementos.Cima (Pila, Elem1);  --  iteradorF
               Pila_Elementos.Segundo (Pila, Elem2);  --  iteradorT
               Pila_Elementos.Tercero (Pila, Elem3);  --  booleano
               if Elem3.Bool then
                  Iterador_Elementos.Asignar (I, Elem2.Cod.All);
                  Leer_Iterador (I, Pila, Stop, Error);
               else
                  Iterador_Elementos.Asignar (I, Elem1.Cod.All);
                  Leer_Iterador (I, Pila, Stop, Error);
               end if;
               Iterador_Elementos.Destruir (Elem1.Cod.All);
               Libera_Puntero (Elem1.Cod);
               Iterador_Elementos.Destruir (Elem2.Cod.All);
               Libera_Puntero (Elem2.Cod);
               Pila_Elementos.Desapilar (Pila);
               Pila_Elementos.Desapilar (Pila);
               Pila_Elementos.Desapilar (Pila);

         else
--put_line("procesa operacion");
                  Procesar (Pal1, Pila, Error);
            end if;
            if Error /= 0 then
               exit;
            end if;

      end loop;

      --si todo a terminadp bien, terminamos
--      if Error = 0 then
--         terminar;------------------------------------------------------------------------------------------------------------------
--      end if;
      --destruimos la pila
      Pila_Elementos.Destruir (Pila);
--      Destruir_St;
--      Pila_Estado.Crear_Vacia();
--pal1.pal (1..20):= "                    ";
--      cerrar;

--Coger (Entrada, Pal1, B);
--put_line(Pal1.pal);
   end Leer_Postscript_aux;






















   --  PRE: Cierto
   --  POST: Ejecuta el programa postscript y se reproduce en pantalla.
   --        En caso de no ser un archivo postscript o de haber
   --        errores cierra el archivo

   procedure Leer_Postscript (
      Fichero : in     String;
      Entrada : in out File_Type; 
         Error   : in out Integer ) is
            
      --Pila     : Pila_Elementos.Pila; 
      I        : Iterador_Elementos.Iterador;        
      B        : Character;  
      C        : String (1 .. 4);  
      A        : Integer                     := 0;   
   begin
      --iniciamos la tabla, creamos el iterador, creamos la pila y abrimos el archivo
      Iniciar_Tabla;
      Iterador_Elementos.Crear_Iterador (I);
      --Pila_Elementos.Crear_Vacia (Pila);
      Open (Entrada, In_File, Fichero);

      --cogemos la cabecera del fichero
      while (not End_Of_File (Entrada)) and (not End_Of_Line (Entrada))
            and (A /= 4) loop
         Get (Entrada, B);
         A := A + 1;
         C (A) := B;
      end loop;
      --si la cabecera no coresponde con la de un archivo PS, soltamos el mensaje de error
      if C /= "%!PS" then
         Error := 5;
      else
         Iniciar;
         Leer_Postscript_Aux (Entrada, I, Error);
         if Error = 0 then
            Terminar;
         end if;   
         loop
            if End_Of_File (Entrada) and Avanzar_Pagina /=0 then
               error :=8;
               exit;
            end if;   
Put_Line("hemos dado a avanzar pagina");
            if Avanzar_Pagina /=0 then
               --Put_Line("hemos dado a avanzar pagina");
               avanzar_pagina := 0;
               Leer_Postscript_Aux (Entrada, I, Error);
               if Error = 0 then 
Put_Line("entramos en terminar");
                  if End_Of_File (Entrada) and Avanzar_Pagina /=0 then
                     Error :=8;
                  end if;    
                  Terminar;
-- Put_line("sale de terminar");                   
            end if;
            end if; 
            if Terminar_Todo /=0 or error /=0 then
               exit;
            end if;
         end loop;
      end if;
      Destruir_St;
      Borrar_Tabla;

      --cerramos el archivo
      Close (Entrada);
   
   exception
      when Name_Error => Put_Line ("fichero no encontrado!"); Error := 7;
      when Use_Error => Put_Line ("El fichero especificado ya esta abierto!");
      when others => Put ("Ha habido una excepcion no reconocida!");
         
   end Leer_Postscript;
   

end Bloque_Principal;