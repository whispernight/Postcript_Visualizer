This program has been coded in Ada95 languaje.
As its name says, its a postcript visualizer.


Explanation (Spanish):


Un documento PostScript, en realidad, es un pequeño programa que le dice a una máquina qué, cómo y dónde imprimir, paso a paso. Los documentos PostScript se destinan a imprimirse en aparatos PostScript, es decir, en aparatos que tienen un dispositivo interno capaz de descifrar el código que reciben y convertirlo en simples puntos de impresión (aquí imprimo, aquí no, aquí sí, aquí también, etc…). 
Para ser adaptable, PostScript es un lenguaje de los denominados "interpretados". Es decir, no le habla directamente a la máquina, sino que necesita un procesador (un dispositivo físico o un programa residente en el ordenador) que actúe como intérprete traductor entre el código PostScript universal y la máquina. Eso es lo que se llama "intérprete PostScript".
De hecho, el lenguaje PostScript es tan "universal" que su forma más sencilla son simples instrucciones escritas como textos (siguiendo, eso sí, una sintaxis muy rigurosa). Básicamente un fichero PostScript contiene instrucciones que, traducidas al lenguaje humano, dicen cosas del tipo: traza un círculo de 3 cm  de radio, dibuja una línea de 4,5 cm. en un ángulo de 45 grados, etc…
Por lo que nuestro programa es un "simple intérprete PostScript ", debe traducir estás instrucciones hasta llegar a la impresión en pantalla de la mismas.


Pruebas: Contains all the test and results done to the code.

Documentacion: Contains a memory explaining the code.

Codigo: Contains the code of the program.

Author: Angel Alferez Aroca