-- -------------------------------------------------------------------
--  pilas.adb - TAD Pila

--  Copyright (C) 2002 por D. Cabeza, A. Herranz y G. Puebla

--  Autores: Daniel Cabeza <dcabeza@fi.upm.es>
--           Ángel Herranz <aherranz@fi.upm.es>
--           Germán Puebla <german@fi.upm.es>

--  Este programa es software libre. Puede redistribuirlo y/o
--  modificarlo bajo los términos de la Licencia Pública General de
--  GNU según es publicada por la Free Software Foundation, bien de la
--  versión 2 de dicha Licencia o bien (según su elección) de
--  cualquier versión posterior.

--  Este programa se distribuye con la esperanza de que sea útil, pero
--  SIN NINGUNA GARANTÍA, incluso sin la garantía MERCANTIL implícita
--  o sin garantizar la CONVENIENCIA PARA UN PROPÓSITO PARTICULAR.
--  Véase la Licencia Pública General de GNU para más detalles.

--  Debería haber recibido una copia de la Licencia Pública General
--  junto con este programa. Si no ha sido así, escriba a la Free
--  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, EEUU
-- -------------------------------------------------------------------

-------------------------------------------------------------------
--  USO DEL PAQUETE
--  - Las variables del tipo Pila deben ser inicializadas con la
--    operacion Crear_Vacia.
--  - Con el objetivo de no desperdiciar memoria, cuando se
--    sabe que el CONTENIDO de una pila "P" no se va a
--    utilizar más, se debe LIBERAR LA MEMORIA utilizada por
--    "P" llamando a la operacion "Destruir (P)". Obsérvese
--    que a partir de ese momento la variable "P" puede volver
--    a utilizarse sin problema alguno siendo su valor el de
--    la pila vacía.
-------------------------------------------------------------------

generic

   type Tipo_Elemento is private;

package Pilas is

   -------------------------------------------------------------------
   --  DOMINIO
   --    TIPO Pila = CPilaVacia
   --              | CPila (Tipo_Elemento x Pila)
   --    INVARIANTE: (A) p EN Pila. Es_Estructura (p)
   --  NOTA: Es_Estructura es un predicado que pretende informar
   --  al usuario de ciertas propiedades de cualquier TAD
   --  implementado con punteros (ver el TAD Lista).
   type Pila is limited private;
   type componente is limited private;
   -------------------------------------------------------------------
   --  Para indicar que no se dispone de más memoria dinámica
   Memoria_Agotada : exception;

   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: P = CPilaVacia
   --  COMPLEJIDAD: O (1)
   procedure Crear_Vacia
     (P : out Pila);

   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: Resultado = (P = CPilaVacia)
   --  COMPLEJIDAD: O (1)
   function Es_Vacia
     (P : Pila)
      return Boolean;

   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: Resultado = Nº elementos de la pila
   --  COMPLEJIDAD: O (1)
   function Num_Elementos
     (P : Pila)
      return Integer;

   -------------------------------------------------------------------
   --  PRE: Hay al menos n elementos en la pila
   --  POST/SOL: Resultado = La misma pila pero habiendo desplazado
   --  j mod n posiciones los primeros n elementos de la pila
   procedure Rotar (P : in out Pila; n, j : in Integer);

   -------------------------------------------------------------------
   --  PRE: not Es_Vacia(P)
   --  POST/SOL: P = CPila (Elemento,_)
   --  COMPLEJIDAD: O (1)
   procedure Cima
     (P        : in     Pila;
      Elemento :    out Tipo_Elemento);

   procedure Segundo
     (P        : in     Pila;
      Elemento :    out Tipo_Elemento);
      
   procedure Tercero
     (P        : in     Pila;
      Elemento :    out Tipo_Elemento);

   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: P^sal = CPila (Elemento,P^ent)
   --  COMPLEJIDAD: O (1)
   --  EXCEPCIONES: Memoria_Agotada
   procedure Apilar
     (P        : in out Pila;
      Elemento : in     Tipo_Elemento);

   -------------------------------------------------------------------
   --  PRE: not Es_Vacia (P)
   --  POST/SOL: P^ent = CPila (_,P^sal)
   --  COMPLEJIDAD: O (1)
   procedure Desapilar
     (P : in out Pila);

   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: P^sal = CPilaVacia
   --  COMPLEJIDAD: O(N)
   --  DONDE N es el número de elementos apilados en P^ent
   procedure Destruir
     (P : in out Pila);

private
      type Componente is record
      Cima  : Tipo_Elemento;
      Resto : Pila;
      end record;


   type Pila is access Componente;

end Pilas;
