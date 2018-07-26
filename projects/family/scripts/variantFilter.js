function accept(ctx) {

  // Only select sets that intersect
  if (ctx.hasAttribute("set")) {
    var settype = ctx.getAttributeAsString("set", "")
    if (settype != "Intersection") {
      // if settype is not Intersection : REJECT
      return false;
    }
  }
  
  // Now look through the sample genotypes
  // if parents genotype is homvar : REJECT
  p1 = ctx.getGenotype("9018.P1") 
  if (p1 == null || p1.isHom()) return false;
 
  // if parents genotype is homvar : REJECT
  p2 = ctx.getGenotype("9019.P2") 
  if (p2 == null || p1.isHom()) return false;

  c1 = ctx.getGenotype("9017.C1") 
  if (c1 == null) return false;
 
  // if parents genotype is homvar : REJECT
  c2 = ctx.getGenotype("9020.C2") 
  if (c2 == null) return false;

  if (c1.sameGenotype(c2)) return false;

      //    // if NOT Het return false;
      //    if(!g.isHet()) return false;
      //    // for any other sample , check it is HomRef or NoCall
      //    if(!(g.isHomRef() || g.isNoCall()))  return false;
  return true;
}

accept(variant);
