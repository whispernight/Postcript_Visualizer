-- -------------------------------------------------------------------
--  pilas.ads - TAD Pila

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
--  Utilizamos una cadena enlazada simple para implementar la pila
-------------------------------------------------------------------

with Ada.Unchecked_Deallocation;

package body Pilas is

   -------------------------------------------------------------------

   -------------------------------------------------------------------
   procedure Libera_Memoria is
     new Ada.Unchecked_Deallocation (Object => Componente,
                                     Name => Pila);

   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: P = CPilaVacia
   --  COMPLEJIDAD: O (1)
   procedure Crear_Vacia
     (P : out Pila)
   is
   begin
      P := null;
   end Crear_Vacia;

   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: Resultado = (P = CPilaVacia)
   --  COMPLEJIDAD: O (1)
   function Es_Vacia
     (P : Pila)
      return Boolean is
   begin
      return P = null;
   end Es_Vacia;

   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: Resultado = Nº elementos de la pila
   function Num_Elementos
     (P : Pila)
      return Integer is
   begin
      if P /= null then return 1 + Num_Elementos (P.all.Resto);
      else return 0;
      end if;
   end Num_Elementos;

   -------------------------------------------------------------------
   --  PRE: Hay al menos n elementos en la pila
   --  POST/SOL: Resultado = La misma pila pero habiendo desplazado
   --  j mod n posiciones los primeros n elementos de la pila
   procedure Rotar (P : in out Pila; n, j : in Integer) is
      count : Integer;
      Ref1, Ref2, Ref3 : Pila;
   begin
      count := j rem n;
      Ref1 := P;
      Ref2 := P;
      Ref3 := P;
      for i in 1 .. (n - count - 1) loop
         Ref1 := Ref1.all.Resto;
--  Ref1 apuntando al elemento que va a quedar el último
      end loop;
      
      for i in 1 .. (n - 1) loop
         Ref2 := Ref2.all.Resto;
--  Ref2 apuntando al último elemento de la pila
      end loop;

      P := Ref1.all.Resto;
      Ref1.all.Resto := Ref2.all.Resto;
      Ref2.all.Resto := Ref3;
      
   end Rotar;
   -------------------------------------------------------------------
   --  PRE: not Es_Vacia (P)
   --  POST/SOL: P = CPila (Elemento,_)
   --  COMPLEJIDAD: O (1)
   procedure Cima
     (P        : in     Pila;
      Elemento :    out Tipo_Elemento)
   is
   begin
      pragma Assert (P /= null, "Intento de acceder cima de pila vacia");
      Elemento := P.all.Cima;
   end Cima;

   procedure Segundo
     (P        : in     Pila;
      Elemento :    out Tipo_Elemento)
   is
   begin
      pragma Assert (P /= null, "Intento de acceder cima de pila vacia");
      pragma Assert (P.all.Resto /= null,
      "Intento de acceder al segundo elemento de una pila con un elemento");
      Elemento := P.all.Resto.all.Cima;
   end Segundo;
   
   procedure Tercero
     (P        : in     Pila;
      Elemento :    out Tipo_Elemento)
   is
   begin
      pragma Assert (P /= null, "Intento de acceder cima de pila vacia");
      pragma Assert (P.all.Resto /= null,
      "Intento de acceder al segundo elemento de una pila con un elemento");
      pragma Assert (P.all.Resto /= null,
      "Intento de acceder al tercer elemento de una pila con dos elementos");
      Elemento := P.all.Resto.all.Resto.all.Cima;
   end Tercero;
   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: P^sal = CPila (Elemento,P^ent)
   --  COMPLEJIDAD: O (1)
   --  EXCEPCIONES: Memoria_Agotada
   procedure Apilar
     (P        : in out Pila;
      Elemento : in     Tipo_Elemento)
   is
   begin  -- Apilar
      P := new Componente'(Cima  => Elemento,
                               Resto => P);
   exception
      when Storage_Error =>
         raise Memoria_Agotada;
   end Apilar;

   -------------------------------------------------------------------
   --  PRE: not Es_Vacia (P)
   --  POST/SOL: P^ent = CPila (_,P^sal)
   --  COMPLEJIDAD: O (1)
   procedure Desapilar
     (P : in out Pila)
   is
      Viejo : Pila;
   begin -- Desapilar
      pragma Assert (P /= null, "Intento de desapilar una pila vacia");
      Viejo := P;
      P := P.all.Resto;
      Libera_Memoria (Viejo);
   end Desapilar;

   -------------------------------------------------------------------
   --  PRE: Cierto
   --  POST/SOL: P^sal = CPilaVacia
   --  COMPLEJIDAD: O (n)
   --  DONDE n es el número de elementos apilados en P^ent
   procedure Destruir
     (P : in out Pila)
   is
      Viejo : Pila;
   begin  -- Destruir
      while P /= null loop
         Viejo := P;
         P := P.all.Resto;
         Libera_Memoria (Viejo);
      end loop;
   end Destruir;

end Pilas;
