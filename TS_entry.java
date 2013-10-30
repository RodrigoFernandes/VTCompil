import java.util.ArrayList;
/**
 * Write a description of class Paciente here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class TS_entry
{
   private String id;
   private ClasseID classe;  
   private String escopo;
   private int tipo;
   private int nElem;
   private int tipoBase;
   private TabSimb locais;


   public TS_entry(String umId,  int umTipo,  
		   int ne, int umTBase,
            String umEscopo, ClasseID umaClasse) {
      id = umId;
      tipo = umTipo;
      escopo = umEscopo;
      nElem = ne;
      tipoBase = umTBase;
      classe = umaClasse;
      locais = new TabSimb();
   }

   public TS_entry(String umId, int umTipo, String e, ClasseID classe) {
      this(umId, umTipo, -1, -1, e, classe);
   }


   public String getId() {
       return id; 
   }

   public int getTipo() {
       return tipo; 
   }
   
   public int getNumElem() {
       return nElem; 
   }

   public int getTipoBase() {
       return tipoBase; 
   }

   
   public String toString() {
       StringBuilder aux = new StringBuilder("");
        
	aux.append("Id: ");
	aux.append(id);

	aux.append("\tClasse: ");
	aux.append(classe);
	aux.append("\tEscopo: ");
	aux.append(escopo);
	aux.append("\tTipo: "); 
	aux.append(tipo2str(this.tipo)); 
    if (this.tipo == Parser.ARRAY) {
    	aux.append(" (ne: ");
	    aux.append(nElem);
    	aux.append(", tBase: ");
	    aux.append(tipo2str(this.tipoBase));
    	aux.append(")");

    }    

        ArrayList<TS_entry> lista = locais.getLista();
        for (TS_entry t : lista) {
            aux.append("\n\t");
	    aux.append(t.toString());
        }

      return aux.toString();

   }

    public String tipo2str(int tipo) {
     	switch (tipo) {
           case Parser.INT : return "int:"+ Parser.INT;
           case Parser.BOOL : return "boolean:"+ Parser.BOOL;
           case Parser.FLOAT : return "float:"+ Parser.FLOAT;
           case Parser.STRING : return "string:"+ Parser.STRING;
          case Parser.LITERAL : return "string:"+ Parser.LITERAL;  
          case Parser.VOID : return "void:"+ Parser.VOID;
           case Parser.ARRAY : return "array:"+ Parser.ARRAY;
	   default : return Integer.toString(tipo);
         }
     }



   // public void insereLocal(String id, int tp, ClasseID cl) {
   //      locais.insert(new TS_entry(id, tp, cl));
   //}

}






