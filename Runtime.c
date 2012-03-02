#include "Garbage_Collector.c"

word box_fixnum(word w){return BOX(w);}
word unbox_fixnum(word w){return UNBOX(w);}

Block* cons(word car, word cdr){
  Wagon *w = object_allocate(0, car, cdr);
  return &(w->cell);
}

Block * cons_null(){
  return cons(0,0);
}

word null(){ return 0x0;}

int is_null(word * p) {return (p == NULL)?1:0;}
int is_pair(word * p) {return IS_HEADER((word)p);}
int is_number(word * p) {return IS_FIXNUM((word) p);}

void setcar_ptr(Block *b, word val){b->car = val;}
void setcdr_ptr(Block *b, word val){b->cdr = val;}
void setcar(Block *b, word val){b->car = BOX(val);}
void setcdr(Block *b, word val){b->cdr = BOX(val);}

word getcar_ptr(Block *b) {return b->car;}
word getcdr_ptr(Block *b) {return b->cdr;}
word getcar(Block *b) {return UNBOX(b->car);}
word getcdr(Block *b) {return UNBOX(b->cdr);}
